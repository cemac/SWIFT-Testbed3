'''
POSTAGE STAMPS
Contains code for producing postage stamp plots of fields from ensembles.
'''
import config
import plotting
import constants
import numpy as np

import os
import glob
import copy
import iris
import utils
import itertools
import cube_time
import cube_utils
import cPickle as pickle
from multiprocessing import Pool
import ImageMetaTag as imt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.pyplot as plt
import matplotlib.colors as mcol
import shapely.geometry as sgeom
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from scipy.signal import convolve
from scipy.ndimage import maximum_filter
from scipy.ndimage import uniform_filter

#from memory_profiler import profile

DATETIME_FORMAT = "%Y/%m/%d %H%MZ"
DEFAULT_NUM_ROWS = 3
HORIZ_PLOT_SPACING = 0.1
VERT_PLOT_SPACING = 0.1

#TODO
# Should skip field if no valid data files found
# Maybe have list of plots for each region rather than the other way round? Then we could have different size plots, different colourbar intervals etc for each region
# At the moment, essentially just parallelising over time. Could it be more efficient to have one big parallel function that takes model, date, regions into account to0?
# Area averages, histograms, ensemble mean and signal to noise (what about colourbar intervals in latter case though). Think carefully about class design...

def get_times_from_single_time_cube(cube):
    num_times = cube_utils.get_number_of_times(cube)
    if num_times != 1:
        raise ValueError("Input cube must be a single time slice")

    # Validity time
    val_time = cube.coord("time")
    time_unit = val_time.units
    if val_time.bounds is not None:
        val_time_start = time_unit.num2date(val_time.bounds[0][0])
        val_time_start_str = val_time_start.strftime(DATETIME_FORMAT)
        val_time = time_unit.num2date(val_time.bounds[0][1])
    else:
        val_time_start = None
        val_time_start_str = None
        val_time = time_unit.num2date(val_time.points[0])       
    val_time_str = val_time.strftime(DATETIME_FORMAT)
   
    # Data time
    data_time = cube.coord("forecast_reference_time")
    data_time = time_unit.num2date(data_time.points[0])
    data_time_str = data_time.strftime(DATETIME_FORMAT)
   
    # Forecast lead time
    lead_time = cube.coord("forecast_period")
    if lead_time.bounds is not None:
        lead_time_start = lead_time.bounds[0][0]
        lead_time_start_str = "T+{0:.1f}".format(lead_time_start)
        lead_time = lead_time.bounds[0][1]
    else:
        lead_time_start = None
        lead_time_start_str = None
        lead_time = lead_time.points[0]
    lead_time_str = "T+{0:.1f}".format(lead_time)
   
    return (val_time, val_time_str, val_time_start, val_time_start_str, 
            data_time, data_time_str, lead_time, lead_time_str, 
            lead_time_start, lead_time_start_str)

def plot_title(val_time_str, val_time_start_str, lead_time_str, 
                    lead_time_start_str, data_time_str):
    if val_time_start_str is not None:
        # We have an accumulation/mean/min/max
        title = ("{0:s} to {1:s}, {2:s} to {3:s}, from {4:s}"
                 .format(val_time_start_str, val_time_str, 
                         lead_time_start_str, lead_time_str,
                         data_time_str))
    else:
        # We have an instantaneous field
        title = "{0:s}, {1:s} from {2:s}".format(val_time_str, lead_time_str, 
                                                 data_time_str) 
   
    return title

def plot_filename(plot_name, val_time_str, lead_time_str, region=None):
    val_time_str = val_time_str.replace("/", "")
    val_time_str = val_time_str.replace(" ", "_")
    lead_time_str = lead_time_str.replace("+", "")        
    if region is None:
        filename = "{0:s}_{1:s}_{2:s}".format(plot_name, val_time_str, 
                                              lead_time_str)
    else:
        filename = "{0:s}_{1:s}_{2:s}_{3:s}".format(plot_name, region, 
                                                    val_time_str, lead_time_str)
    return filename

def check_mean_period(cubes, mean_period=1):  
    '''
    Check whether cubes are time-means with the specified meaning period.

    Arguments:

    * **cubes** - an :class:`iris.cube.CubeList` of :class:`iris.cube.Cube` \
                  objects.

    Keyword arguments:

    * **mean_period** - time meaning period (in hours) to check for.

    Returns:

    * **matches_mean_period** - a list of booleans with the same length as the \
                                input cubelist, where True indicates that the \
                                corresponding cube in the cubelist is a \
                                time-mean with a meaning period matching \
                                mean_period.
    '''
    matches_mean_period = []
    # Loop over cubes in input cubelist
    for cube in cubes:
        # Check the time coordinate has bounds
        time_coord = cube.coord("time")
        if not time_coord.has_bounds():
            msg = ("Cannot determine time meaning period without "
                   "time coordinate bounds")
            print msg
            matches_mean_period.append(False)
            continue

        # Use time coordinate bounds to work out time meaning period
        time_unit = time_coord.units
        time_interval = [(end_time - start_time) for start_time, end_time
                         in time_unit.num2date(time_coord.bounds)]
        time_interval = list(set(time_interval))
        # Is there a unique meaning period?
        if len(time_interval) != 1:
            print "Could not determine a unique time meaning period"
            matches_mean_period.append(False)
            continue
        # Convert to hours
        time_interval = (time_interval[0].total_seconds() 
                         / float(constants.HOUR_IN_SECONDS))

        # Does the unique meaning period match mean_period?
        if time_interval == mean_period:
            matches_mean_period.append(True)
        else:
            matches_mean_period.append(False)

    return matches_mean_period

def load_and_process_data(data_dir, field):  
    '''
    Load model data required for a particular field.

    Arguments:

    * **data_dir** - directory where model output files (fieldsfiles or PP \
                     files) can be found.   
    * **field** - an instance of :class:`diagnostics.Field` describing the \
                  field for which data is to be loaded and processed.
   
    Returns:

    * **cube** - an :class:`iris.cube.Cube` holding the required data. If \
                 there was a problem, None is returned.
    '''
    # Get a list of fieldsfiles/PP files to read in
    file_patterns = ["{0:s}/*.pp".format(data_dir),
                     "{0:s}/*.ff".format(data_dir)]
    filelist = []
    for file_pattern in file_patterns:
        filelist.extend(glob.glob(file_pattern))
    if not filelist:
        msg = ("No valid data files found in specified "
               "directory {0:s}").format(data_dir)
        print msg    
        return None
    msg = ("Found the following data files in specified "
           "directory {0:s}:").format(data_dir)
    print msg
#    print filelist
    
    # Try to load in the data from a pickle
    all_cubes_pickle = "{0:s}/all_cubes.p".format(data_dir)
    
    if os.path.isfile(all_cubes_pickle):
        print 'Reading in data from pickle file...'
        with open(all_cubes_pickle, "rb" ) as open_pickle:
            all_cubes = pickle.load(open_pickle)
    else:
        # It is considerably quicker to load the data once into a big 
        # cubelist and extract as and when needed
        print 'Loading all data...'        
        realization_constraint = iris.Constraint(realization=lambda value: True)
        all_cubes = iris.load(filelist, realization_constraint,    
                              callback=cube_utils.realization_metadata) 

        ################################################################
        # Temporary hack 
        # Throw away T+0 data
#        constraint = iris.Constraint(forecast_period=lambda cell: cell.point>0.5)
#        all_cubes = all_cubes.extract(constraint)
        ################################################################
            
        # Pickle cubes to a file to speed up loading next time
        with open(all_cubes_pickle, "wb" ) as open_pickle:
            pickle.dump(all_cubes, open_pickle)       
    if not all_cubes:
        return None

    # Get the data required for this field
    cubes = iris.cube.CubeList()
    # This counts the minimum number of cubes needed for this field
    num_cubes_required = 0
    # This counts the maximum number of cubes there can be for this field
    max_num_cubes = 0
    # Loop over STASH diagnostics required for this field
    for stash in field.stash:
        if not stash.is_optional:
            num_cubes_required += 1
        max_num_cubes += 1

        # Extract by STASH code...
        stash_constraint = iris.AttributeConstraint(STASH=stash.code)
        # ...and by time processing...
        if field.proc_period:
            time_proc_constraint = iris.Constraint(
                cube_func=cube_time.is_hourly_mean)
        else: 
            time_proc_constraint = None

        # ...and by level
        levels = stash.levels
        if len(levels)==0:
            constraint = stash_constraint & time_proc_constraint
        elif len(levels)==1:
            level = levels[0]
            level_constraint = iris.Constraint(coord_values={
                    stash.level_type: lambda cell: 
                    (level-config.LEVEL_MATCH_TOL
                     < cell.point
                     < level+config.LEVEL_MATCH_TOL)})
            constraint = (stash_constraint & time_proc_constraint 
                          & level_constraint)
        else:
            print "Cannot deal with multi-level data"
            return None
        cubes_for_stash = all_cubes.extract(constraint, strict=False)
        
        # TODO: If there is duplication of fields in different UM 
        # output streams, Iris yields two identical cubes. This removes 
        # one of them.
        # This behaviour seems wrong; AVD have been informed
        # Once fixed, we could set strict=True in the above line
        cubes_for_stash = cube_utils.remove_duplicates(cubes_for_stash)
        if cubes_for_stash:
            cube = cubes_for_stash.extract(constraint, strict=True)      
            cubes.append(cube)

    # Check the number of cubes found is as expected
    num_cubes = len(cubes)
    if (num_cubes < num_cubes_required) or (num_cubes > max_num_cubes):
        print "Did not find required data for field."
        return None

    # If this is a time processed field, check all cubes are hourly means
    if field.proc_period:
        matches_mean_period = check_mean_period(cubes)   
        if not all(matches_mean_period):
            print "Not all required data for this field was an hourly mean."
            return None
   
    # Make sure double precision is used in subsequent calculations
    for cube in cubes:
        data = cube.lazy_data()
        cube.lazy_data(data.astype(np.float64))
              
    return cubes 

def yield_first_cube_in_cubelist_by_slice(cubelist, plot, extra_opts=None,
                                          n_slices=None):    
    if not isinstance(cubelist, iris.cube.CubeList):
        raise ValueError('Input cubelist is not an iris.cube.CubeList')

    slice_count = 0
    first_cube = cubelist[0]
    if plot.field.proc_period is None:
        # Instantaneous time slices
        for i_slc, slc in enumerate(first_cube.slices_over("time")):           
            out_tuple = (slc, cubelist, plot)
            # Append the extra_opts, if supplied
            if not extra_opts is None:
                for opt in extra_opts:
                    out_tuple = out_tuple + (opt,)
            slice_count += 1       
            yield out_tuple
            if not n_slices is None:
                if slice_count == n_slices:
                    break   
    else:
        # TODO What about if not exactly divisible by proc_period?
        num_times = len(first_cube.coord("time").points)
        num_time_groups = int(num_times / float(plot.field.proc_period))
        
        # TODO This seems slow - it is the squeeze
        # TODO Could this be implmented in a better way? See below
        # commented out code
        for i in range(num_time_groups):
            start_index = i * plot.field.proc_period
            end_index = (i + 1) * plot.field.proc_period
            # TODO Make more robust in terms of which dimension is time
            slc = first_cube[:, start_index:end_index, :, :]
            slc = cube_utils.remove_length_one_dimensions(slc)                
            out_tuple = (slc, cubelist, plot)
            # Append the extra_opts, if supplied
            if not extra_opts is None:
                for opt in extra_opts:
                    out_tuple = out_tuple + (opt,)
            slice_count += 1       
            yield out_tuple
            if not n_slices is None:
                if slice_count == n_slices:
                    break   

                #if post_stamp_plot.field.proc_period:
                #    start_lead_times = cube.coord("forecast_period").bounds[:, 0]
                #    end_lead_times = cube.coord("forecast_period").bounds[:, 1]
                #    end_indices = np.where(end_lead_times % post_stamp_plot.field.proc_period == 0)[0]
                #    end_lead_times = end_lead_times[end_indices]
                #    start_indices = np.where(np.in1d(start_lead_times, end_lead_times - post_stamp_plot.field.proc_period))[0]              
                #    start_lead_times = start_lead_times[start_indices]

def save_plot(plot_dir, filename, fileformat="png", img_tags=None, 
              db_file=None, dpi=None):
    # Create plot directory if not present      
    utils.mkdir_p(plot_dir)

    # Database file to store all image metadata in
    if db_file is None:
        db_file = "{0:s}/imt_db.db".format(plot_dir)
        
    # Now save the figure using ImageMetaTag 
    filename = "{0:s}/{1:s}".format(plot_dir, filename)
    imt.savefig(filename, img_format=fileformat, img_converter=1, 
                do_trim=True, trim_border=0, do_thumb=False, 
                img_tags=img_tags, keep_open=False, dpi=dpi, 
                logo_file=None, logo_width=40, logo_padding=0, 
                logo_pos=0, db_file=db_file) 

    return True     

def match_coords(data_cube, match_cube):
    # Build a constraint that matches all of the scalar coordinates:    
    coord_list = [coord.name() for coord in match_cube.coords()]
   
    total_constraint = None
    for coord in coord_list: 
        coord_val = match_cube.coord(coord).points
        constraint = iris.Constraint(coord_values={coord: coord_val})
        if total_constraint is None:
            total_constraint = constraint
        else:
            total_constraint = total_constraint & constraint

    return data_cube.extract(total_constraint)

def match_cubelist_to_cube(cubelist, main_cube):    
    if not isinstance(cubelist, iris.cube.CubeList):
        raise ValueError('Input cubelist is not a cubelist')
    if not isinstance(main_cube, iris.cube.Cube):
        raise ValueError('Input main_cube is not a cube')
              
    # Make sure this is a copy, as otherwise all data ends up being 
    # loaded in to the main cubelist
    work_cubelist = copy.deepcopy(cubelist)
    
    out_cubelist = iris.cube.CubeList([main_cube.copy()])
    # Now go through the other cubes in the cubelist and see if we can
    # pull out a matching cube
    got_all_cubes = True
    if len(work_cubelist) > 1:
        for cube in work_cubelist[1:]:
            # This will extract the current cube down to the scalar coords 
            # of the main_cube    
            match_cube = match_coords(cube, main_cube)            
            if match_cube is None:
                got_all_cubes = False
                break
            else:
                out_cubelist.append(match_cube)
    
    if got_all_cubes:
        return out_cubelist
    else:
        return None

def check_region_in_domain(region, cube):
    
    # Construct a polyon describing the boundary of the model
    # domain in standard lat/lon
    coord_system = iris.coord_systems.GeogCS(iris.fileformats.pp.EARTH_RADIUS)
    domain_boundary = cube_utils.get_boundary(cube, 
                                              coord_system_out=coord_system)

    # Construct a polygon describing the boundary of the 
    # plotting region
    xmin = region.extent["longitude"][0]
    xmax = region.extent["longitude"][1]
    ymin = region.extent["latitude"][0]
    ymax = region.extent["latitude"][1]

    region_boundary = sgeom.Polygon([[xmin, ymin], 
                                     [xmin, ymax], 
                                     [xmax, ymax], 
                                     [xmax, ymin]])

    # Check whether the boundary of the plotting region
    # lies fully inside that of the model domain
    if region_boundary.within(domain_boundary):
        return True, cube
    else:
        xmin = xmin + 360
        xmax = xmax + 360
        
        region_boundary = sgeom.Polygon([[xmin, ymin], 
                                     [xmin, ymax], 
                                     [xmax, ymax], 
                                     [xmax, ymin]])

        # Check whether the boundary of the plotting region
        # lies fully inside that of the model domain
        if region_boundary.within(domain_boundary):
            old_lon = cube.coord('longitude')
            new_lon = cube.coord('longitude')-360
            cube.remove_coord(old_lon)
            cube.add_dim_coord(new_lon, 2)
            return True, cube
        else:
            return False, cube

def post_stamp_plots(input_params):
    cube = input_params[0]
    cubes = input_params[1]
    plot = input_params[2]
    plot_dir = input_params[3]
    db_file = input_params[4]
    model_name = input_params[5]

    show_min_val = False
    # Is this PMSL?
    if cube.attributes["STASH"] == "m01s16i222":
        show_min_val = True

    # Find matching cubes for the main input cube
    cubes = match_cubelist_to_cube(cubes, cube)
   
    if plot.field.stash_operator:            
        # Apply specified operator to list of cubes to create a single cube
        cube = reduce(plot.field.stash_operator, cubes)
    else:
        if len(cubes) != 1:
            raise ValueError("Should be dealing with a single cube")
        else:
            cube = cubes[0]    
    
    # Apply any unit conversion factors
    if plot.field.unit_conversion_factor:
        iris.analysis.maths.multiply(cube, plot.field.unit_conversion_factor, 
                                     in_place=True)
        cube.units = plot.field.units

    # Do required time processing
    if plot.field.proc_period:
        # First add a cell method to show that cube is an hourly-mean
        cell_method = iris.coords.CellMethod("mean", coords="time",
                                             intervals="1 hour")
        if cell_method not in cube.cell_methods:
            cube.add_cell_method(cell_method)

        # Use hourly-mean to compute accumulation over desired time period
        cube = cube_time.time_process_from_hourly_mean(
            cube, plot.field.proc_period, do_accumulation=True)

        # Get rid of any dimensions of length one
        cube = cube_utils.remove_length_one_dimensions(cube)
       
    # Extract time information for this cube
    (val_time, val_time_str, val_time_start, val_time_start_str, 
     data_time, data_time_str, lead_time, lead_time_str, lead_time_start,
     lead_time_start_str) = get_times_from_single_time_cube(cube)

    # Get spatial grid
    x_coord, y_coord = cube_utils.get_spatial_coords(cube)
    x = x_coord.points
    y = y_coord.points

    # Plot set up
    num_members = cube_utils.get_number_of_members(cube)
    num_rows = DEFAULT_NUM_ROWS
    num_cols = int(np.ceil(num_members / float(num_rows)))       
    plot_grid = plt.GridSpec(num_rows, num_cols, wspace=HORIZ_PLOT_SPACING, 
                             hspace=VERT_PLOT_SPACING)
    cmap = plot.cmap
    cmap.set_under('#ffffff')
    cmap.set_over('#000000')
    if plot.intervals is not None:
        norm = mcol.BoundaryNorm(plot.intervals, cmap.N)        
    else:
        norm = None
    
    # Loop over regions
    for region in plot.regions:     
        # Check if region lies fully within model domain.
        # If not, don't make plots for this model over 
        # this region.
        region_in_domain,cube = check_region_in_domain(region, cube) 
        if not region_in_domain:
            print "Skipping region..."
            continue

        # Extract data for this region
        if region.extent is not None:
            # Construct longitude constraint
            xmin = region.extent["longitude"][0]
            xmax = region.extent["longitude"][1]
            lon_constraint = iris.Constraint(coord_values={
                    x_coord.name(): lambda cell: xmin<=cell.point<=xmax})
            # Construct latitude constraint
            ymin = region.extent["latitude"][0]
            ymax = region.extent["latitude"][1]
            lat_constraint = iris.Constraint(coord_values={
                    y_coord.name(): lambda cell: ymin<=cell.point<=ymax})
            # Do the extraction
            lat_lon_constraint = lat_constraint & lon_constraint 
            cube_regn = cube.extract(lat_lon_constraint)
            x_coord_regn, y_coord_regn = cube_utils.get_spatial_coords(cube_regn)
            x_regn = x_coord_regn.points
            y_regn = y_coord_regn.points
        else:
            cube_regn = cube
            x_regn = x
            y_regn = y
        
        # New figure
        fig = plt.figure(figsize=(plot.size["width"], plot.size["height"]))

        # Loop over ensemble members
        for i_mbr, mbr_slc in enumerate(cube_regn.slices_over("realization")):
            # Plotting
            axes = fig.add_subplot(plot_grid[np.unravel_index(i_mbr, 
                                                              [num_rows, 
                                                               num_cols])],
                                   projection=ccrs.PlateCarree())
            if plot.plot_type == "contourf":
                cs = axes.contourf(x_regn, y_regn, mbr_slc.data, intervals, 
                                   cmap=cmap, norm=norm, extend='both')
            elif plot.plot_type == "pcolormesh":
                cs = axes.pcolormesh(x_regn, y_regn, mbr_slc.data, cmap=cmap,
                                     norm=norm)
            else:
                raise ValueError("Unsupported plot type {0:s}"
                                 .format(plot.plot_type))

            if plot.add_gridlines:
                gl = axes.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, 
                                    linewidth=0.25, color='k', linestyle=':')
                gl.xformatter = LONGITUDE_FORMATTER
                gl.yformatter = LATITUDE_FORMATTER
                gl.xlabel_style = {'size': 6, 'color': 'gray'}
                gl.ylabel_style = {'size': 6, 'color': 'gray'}
                gl.xlabels_top = False
                gl.ylabels_right = False        
                if i_mbr < (num_members - num_cols):
                    gl.xlabels_bottom = False
                if i_mbr % num_cols:
                    gl.ylabels_left = False        

            if plot.add_coastlines:
                axes.coastlines(resolution='50m', color='k', linewidth=0.25)

            if region.extent is not None:
                axes.set_xlim(xmin, xmax)
                axes.set_ylim(ymin, ymax)

            member_number = mbr_slc.coord("realization").points[0]
            if show_min_val:
                axes.set_title("{0:02d}".format(member_number), fontsize=8, loc='left')
                min_val = np.round(np.min(mbr_slc.data))
                axes.set_title("min={0:d}".format(int(min_val)), fontsize=8, loc='right')
            else:
                axes.set_title("{0:02d}".format(member_number), fontsize=8)
            
        # Plot colorbar [left, bottom, width, height]  
        cbar_axes = fig.add_axes([0.91, 0.12, 0.01, 0.76])  
        cbar = plt.colorbar(cs, cax=cbar_axes, extend='both', 
                            ticks=plot.intervals, spacing='uniform', 
                            orientation='vertical')       
        cbar.set_label("{0:s} [{1:s}]".format(plot.field.long_name, 
                                              plot.field.units), 
                       rotation=270, labelpad=15)

        # Title figure 
        title = plot_title(val_time_str, val_time_start_str, lead_time_str, 
                           lead_time_start_str, data_time_str)
        plt.suptitle(title, y=0.94)

        # Image metadata tags to drive web page
        if plot.field.proc_period is not None:
            proc_period_str = "{0:d} hour".format(plot.field.proc_period)
        else:
            proc_period_str = None
        img_tags = {"plot type": "Postage stamp",
                    "field": plot.field.long_name,
                    "model": model_name,     
                    "cutout": region.long_name,
                    "validity_time": val_time_str,
                    "data_time": data_time_str,
                    "lead_time": lead_time_str,
                    "proc_period": proc_period_str,
                    "threshold": None                 
                    }
        # More general tags
        img_tags["centre"] = "Met Office"
        # TODO: Add in more?
        # img_tags["rose suite"] = suite_id
        # img_tags['plot owner'] = plot_owner
        # img_tags['plot created by'] = this_routine
            
        # Now save the figure 
        filename = plot_filename(plot.filename, val_time_str, 
                                 lead_time_str, region=region.short_name)  
   
        save_plot(plot_dir, filename, fileformat=plot.fileformat, 
                  img_tags=img_tags, db_file=db_file, dpi=plot.dpi)
   
    return True

def prob_plots(input_params):
    cube = input_params[0]
    cubes = input_params[1]
    plot = input_params[2]
    plot_dir = input_params[3]
    db_file = input_params[4]
    model_name = input_params[5]
     
    # Find matching cubes for the main input cube
    cubes = match_cubelist_to_cube(cubes, cube)
   
    if plot.field.stash_operator:            
        # Apply specified operator to list of cubes to create a single cube
        cube = reduce(plot.field.stash_operator, cubes)
    else:
        if len(cubes) != 1:
            raise ValueError("Should be dealing with a single cube")
        else:
            cube = cubes[0]    
    
    # Apply any unit conversion factors
    if plot.field.unit_conversion_factor:
        iris.analysis.maths.multiply(cube, plot.field.unit_conversion_factor, 
                                     in_place=True)
        cube.units = plot.field.units

    # Do required time processing
    if plot.field.proc_period:
        # First add a cell method to show that cube is an hourly-mean
        cell_method = iris.coords.CellMethod("mean", coords="time",
                                             intervals="1 hour")
        if cell_method not in cube.cell_methods:
            cube.add_cell_method(cell_method)

        # Use hourly-mean to compute accumulation over desired time period
        cube = cube_time.time_process_from_hourly_mean(
            cube, plot.field.proc_period, do_accumulation=True)

        # Get rid of any dimensions of length one
        cube = cube_utils.remove_length_one_dimensions(cube)
       
    # Extract time information for this cube
    (val_time, val_time_str, val_time_start, val_time_start_str, 
     data_time, data_time_str, lead_time, lead_time_str, lead_time_start,
     lead_time_start_str) = get_times_from_single_time_cube(cube)

    # Get spatial grid
    x_coord, y_coord = cube_utils.get_spatial_coords(cube)
    x = x_coord.points
    y = y_coord.points

    # Plot set up
    num_rows = 1
    num_cols = 1     
    plot_grid = plt.GridSpec(num_rows, num_cols, wspace=HORIZ_PLOT_SPACING, 
                             hspace=VERT_PLOT_SPACING)
    if plot.intervals is not None:
        norm = mcol.BoundaryNorm(plot.intervals, plot.cmap.N)
    else:
        norm = None

    # Title for plots
    title = plot_title(val_time_str, val_time_start_str, lead_time_str, 
                       lead_time_start_str, data_time_str)

    # Loop over thresholds
    for threshold in plot.thresholds:       

        # Apply threshold
        prob_slc = cube.copy(data=np.where(cube.data > threshold, 
                                                1, 0))

        av_scale = 1
        if  plot.field.long_name == "Precipitation accumulation":
            if "4.4" in model_name:
                av_scale = 19
            elif "4.5" in model_name:
                av_scale = 19
            elif "8.8" in model_name:
                av_scale = 9
            elif "2.2" in model_name:
                av_scale = 39
            elif "20" in model_name:
                av_scale = 3

        # Convolve with averaging scale to get probability of exceeding threhold at at least one location within the averaging window
        kernel = np.ones((av_scale, av_scale))
        kernel = kernel[None,:,:]
        prob_slc = prob_slc.copy(data = convolve(prob_slc.data, kernel, mode='same'))
        prob_slc = prob_slc.copy(data = np.where(prob_slc.data > 0.5, 1, 0))

        # Work out probability of exceeding threshold
        prob_slc = prob_slc.collapsed("realization", iris.analysis.MEAN)

        # Apply smoothing filter
        prob_slc = prob_slc.copy(data=uniform_filter(prob_slc.data,
                                size=av_scale, mode='nearest'))

        # Loop over regions
        for region in plot.regions:
            # Check if region lies fully within model domain.
            # If not, don't make plots for this model over 
            # this region.
            region_in_domain, prob_slc = check_region_in_domain(region, prob_slc) 
            if not region_in_domain:
                print "Skipping region..."
                continue

            # Extract data for this region
            if region.extent is not None:
                # Construct longitude constraint
                xmin = region.extent["longitude"][0]
                xmax = region.extent["longitude"][1]
                lon_constraint = iris.Constraint(coord_values={
                        x_coord.name(): lambda cell: xmin<=cell.point<=xmax})
                # Construct latitude constraint
                ymin = region.extent["latitude"][0]
                ymax = region.extent["latitude"][1]
                lat_constraint = iris.Constraint(coord_values={
                        y_coord.name(): lambda cell: ymin<=cell.point<=ymax})
                # Do the extraction
                lat_lon_constraint = lat_constraint & lon_constraint 
                prob_slc_regn = prob_slc.extract(lat_lon_constraint)
                x_coord_regn, y_coord_regn = cube_utils.get_spatial_coords(prob_slc_regn)
                x_regn = x_coord_regn.points
                y_regn = y_coord_regn.points
            else:
                prob_slc_regn = prob_slc
                x_regn = x
                y_regn = y       

                                
            # Plotting               
            fig = plt.figure(figsize=(plot.size["width"], plot.size["height"]))
            axes = fig.add_subplot(plot_grid[0, 0], 
                                   projection=ccrs.PlateCarree())
                        
            if plot.plot_type == "contourf":
                cs = axes.contourf(x_regn, y_regn, prob_slc_regn.data, 
                                   plot.intervals, cmap=plot.cmap, norm=norm)
            elif plot.plot_type == "pcolormesh":
                cs = axes.pcolormesh(x_regn, y_regn, prob_slc_regn.data, 
                                     cmap=plot.cmap, norm=norm)
            else:
                raise ValueError("Unsupported plot type {0:s}"
                                 .format(plot.plot_type))

            if plot.add_gridlines:
                gl = axes.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, 
                                    linewidth=0.25, color='k', linestyle=':')
                gl.xformatter = LONGITUDE_FORMATTER
                gl.yformatter = LATITUDE_FORMATTER
                gl.xlabel_style = {'size': 6, 'color': 'gray'}
                gl.ylabel_style = {'size': 6, 'color': 'gray'}
                gl.xlabels_top = False
                gl.ylabels_right = False     

            if plot.add_coastlines:
                axes.coastlines(resolution='50m', color='k', linewidth=0.25)

                lake_lines = cfeature.NaturalEarthFeature(category='physical',
                                            name='lakes',
                                            scale='50m', facecolor='none')#,
                                            #facecolor='lightskyblue' )

                axes.add_feature(lake_lines, color='k', linestyle='-', linewidth=0.7 )

                countries_50m = cfeature.NaturalEarthFeature('cultural','admin_0_countries','50m',facecolor='none')

                axes.add_feature(countries_50m, color='k', linestyle='--', linewidth=0.2 )

            if region.extent is not None:
                axes.set_xlim(xmin, xmax)
                axes.set_ylim(ymin, ymax)
            
            # Plot colorbar [left, bottom, width, height]  
            cbar_axes = fig.add_axes([0.92, 0.12, 0.02, 0.76])  
            cbar = plt.colorbar(cs, cax=cbar_axes, ticks=plot.intervals, 
                                spacing='uniform', orientation='vertical') 
            cbar.set_label("{0:s} > {1:d} {2:s}"
                           .format(plot.title, threshold, plot.field.units),
                           rotation=270, labelpad=15)

            # Title figure 
            axes.set_title(title)

            # Image metadata tags to drive web page
            if plot.field.proc_period is not None:
                proc_period_str = "{0:d} hour".format(plot.field.proc_period)
            else:
                proc_period_str = None
            img_tags = {"plot type": "Probability",
                        "field": plot.field.long_name,
                        "model": model_name,  
                        "cutout": region.long_name,
                        "validity_time": val_time_str,
                        "data_time": data_time_str,
                        "lead_time": lead_time_str,
                        "proc_period": proc_period_str,
                        "threshold": "{0:d} {1:s}".format(threshold, 
                                                          plot.field.units)
                        }
            # More general tags
            img_tags["centre"] = "Met Office"
            # TODO: Add in more?
            # img_tags["rose suite"] = suite_id
            # img_tags['plot owner'] = plot_owner
            # img_tags['plot created by'] = this_routine
           
            # Now save the figure
            if plot.field.units == "%":
                unit_str = "pc"
            else:
                unit_str = plot.field.units.replace(" ", "_")
            plot_name = "{0:s}_gt_{1:d}{2:s}".format(plot.filename, 
                                                     threshold, 
                                                     unit_str)
            filename = plot_filename(plot_name, val_time_str, lead_time_str,
                                     region=region.short_name)  
            save_plot(plot_dir, filename, fileformat=plot.fileformat, 
                      img_tags=img_tags, db_file=db_file, dpi=plot.dpi)
         
    return True

def percentile_plots(input_params):
    cube = input_params[0]
    cubes = input_params[1]
    plot = input_params[2]
    plot_dir = input_params[3]
    db_file = input_params[4]
    model_name = input_params[5]
     
    # Find matching cubes for the main input cube
    cubes = match_cubelist_to_cube(cubes, cube)
   
    if plot.field.stash_operator:            
        # Apply specified operator to list of cubes to create a single cube
        cube = reduce(plot.field.stash_operator, cubes)
    else:
        if len(cubes) != 1:
            raise ValueError("Should be dealing with a single cube")
        else:
            cube = cubes[0]    
    
    # Apply any unit conversion factors
    if plot.field.unit_conversion_factor:
        iris.analysis.maths.multiply(cube, plot.field.unit_conversion_factor, 
                                     in_place=True)
        cube.units = plot.field.units

    # Do required time processing
    if plot.field.proc_period:
        # First add a cell method to show that cube is an hourly-mean
        cell_method = iris.coords.CellMethod("mean", coords="time",
                                             intervals="1 hour")
        if cell_method not in cube.cell_methods:
            cube.add_cell_method(cell_method)

        # Use hourly-mean to compute accumulation over desired time period
        cube = cube_time.time_process_from_hourly_mean(
            cube, plot.field.proc_period, do_accumulation=True)

        # Get rid of any dimensions of length one
        cube = cube_utils.remove_length_one_dimensions(cube)
       
    # Extract time information for this cube
    (val_time, val_time_str, val_time_start, val_time_start_str, 
     data_time, data_time_str, lead_time, lead_time_str, lead_time_start,
     lead_time_start_str) = get_times_from_single_time_cube(cube)

    # Get spatial grid
    x_coord, y_coord = cube_utils.get_spatial_coords(cube)
    x = x_coord.points
    y = y_coord.points

    # Plot set up
    num_rows = 1
    num_cols = 1     
    plot_grid = plt.GridSpec(num_rows, num_cols, wspace=HORIZ_PLOT_SPACING, 
                             hspace=VERT_PLOT_SPACING)

    cmap = plot.cmap
    cmap.set_under('#ffffff')
    cmap.set_over('#000000')
    if plot.intervals is not None:
        norm = mcol.BoundaryNorm(plot.intervals, plot.cmap.N)
    else:
        norm = None

    # Title for plots
    title = plot_title(val_time_str, val_time_start_str, lead_time_str, 
                       lead_time_start_str, data_time_str)

    # Loop over thresholds
    for threshold in plot.thresholds:       

        # Work out value associated with percentile threshold
        perc_slc = cube.collapsed("realization", iris.analysis.PERCENTILE, percent=threshold)

        # Loop over regions
        for region in plot.regions:
            # Check if region lies fully within model domain.
            # If not, don't make plots for this model over 
            # this region.
            region_in_domain,perc_slc = check_region_in_domain(region, perc_slc) 
            if not region_in_domain:
                print "Skipping region..."
                continue

            # Extract data for this region
            if region.extent is not None:
                # Construct longitude constraint
                xmin = region.extent["longitude"][0]
                xmax = region.extent["longitude"][1]
                lon_constraint = iris.Constraint(coord_values={
                        x_coord.name(): lambda cell: xmin<=cell.point<=xmax})
                # Construct latitude constraint
                ymin = region.extent["latitude"][0]
                ymax = region.extent["latitude"][1]
                lat_constraint = iris.Constraint(coord_values={
                        y_coord.name(): lambda cell: ymin<=cell.point<=ymax})
                # Do the extraction
                lat_lon_constraint = lat_constraint & lon_constraint 
                perc_slc_regn = perc_slc.extract(lat_lon_constraint)
                x_coord_regn, y_coord_regn = cube_utils.get_spatial_coords(perc_slc_regn)
                x_regn = x_coord_regn.points
                y_regn = y_coord_regn.points
            else:
                perc_slc_regn = perc_slc
                x_regn = x
                y_regn = y       
                                
            # Plotting               
            fig = plt.figure(figsize=(plot.size["width"], plot.size["height"]))
            axes = fig.add_subplot(plot_grid[0, 0], 
                                   projection=ccrs.PlateCarree())
                        
            if plot.plot_type == "contourf":
                cs = axes.contourf(x_regn, y_regn, perc_slc_regn.data, 
                                   plot.intervals, cmap=cmap, norm=norm, extend='both')
            elif plot.plot_type == "pcolormesh":
                cs = axes.pcolormesh(x_regn, y_regn, perc_slc_regn.data, 
                                     cmap=cmap, norm=norm)
            else:
                raise ValueError("Unsupported plot type {0:s}"
                                 .format(plot.plot_type))

            if plot.add_gridlines:
                gl = axes.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, 
                                    linewidth=0.25, color='k', linestyle=':')
                gl.xformatter = LONGITUDE_FORMATTER
                gl.yformatter = LATITUDE_FORMATTER
                gl.xlabel_style = {'size': 6, 'color': 'gray'}
                gl.ylabel_style = {'size': 6, 'color': 'gray'}
                gl.xlabels_top = False
                gl.ylabels_right = False     

            if plot.add_coastlines:
                axes.coastlines(resolution='50m', color='k', linewidth=0.7)

                lake_lines = cfeature.NaturalEarthFeature(category='physical',
                                            name='lakes',
                                            scale='50m', facecolor='none')#,
                                            #facecolor='lightskyblue' )

                axes.add_feature(lake_lines, color='k', linestyle='-', linewidth=0.7 )

                countries_50m = cfeature.NaturalEarthFeature('cultural','admin_0_countries','50m',facecolor='none')

                axes.add_feature(countries_50m, color='k', linestyle='--', linewidth=0.2 )


            if region.extent is not None:
                axes.set_xlim(xmin, xmax)
                axes.set_ylim(ymin, ymax)
            
            # Plot colorbar [left, bottom, width, height]  
            cbar_axes = fig.add_axes([0.92, 0.12, 0.02, 0.76])  
            cbar = plt.colorbar(cs, cax=cbar_axes, ticks=plot.intervals, extend='both', 
                                spacing='uniform', orientation='vertical') 
#        cbar = plt.colorbar(cs, cax=cbar_axes, 
#                            ticks=plot.intervals, spacing='uniform', 
#                            orientation='vertical')       
#            cbar.set_label("{0:s} at {1:d}th percentile ({2:s})".format(plot.title, threshold, plot.field.units),
#                           rotation=270, labelpad=15)
            cbar.set_label("{0:s} at {1:d}th percentile ".format(plot.title, threshold),
                           rotation=270, labelpad=15)

            # Title figure 
            axes.set_title(title)

            # Image metadata tags to drive web page
            if plot.field.proc_period is not None:
                proc_period_str = "{0:d} hour".format(plot.field.proc_period)
            else:
                proc_period_str = None
            img_tags = {"plot type": "Percentile",
                        "field": plot.field.long_name,
                        "model": model_name,  
                        "cutout": region.long_name,
                        "validity_time": val_time_str,
                        "data_time": data_time_str,
                        "lead_time": lead_time_str,
                        "proc_period": proc_period_str,
                        "threshold": "{0:d} %".format(threshold) 
                        }
#                        "threshold": "{0:d} {1:s}".format(threshold, plot.field.units)
#                        }
            # More general tags
            img_tags["centre"] = "Met Office"
            # TODO: Add in more?
            # img_tags["rose suite"] = suite_id
            # img_tags['plot owner'] = plot_owner
            # img_tags['plot created by'] = this_routine
           
            # Now save the figure
#            if plot.field.units == "%":
#                unit_str = "pc"
#            else:
#                unit_str = plot.field.units.replace(" ", "_")
            unit_str="pc"
            plot_name = "{0:s}_eq_{1:d}{2:s}".format(plot.filename, 
                                                     threshold, 
                                                     unit_str)
            filename = plot_filename(plot_name, val_time_str, lead_time_str,
                                     region=region.short_name)  
            save_plot(plot_dir, filename, fileformat=plot.fileformat, 
                      img_tags=img_tags, db_file=db_file, dpi=plot.dpi)
         
    return True

#@profile
def postage_stamps(data_dir, dates, model_names, plot_dir, 
                   model_long_names=None, n_proc=1):
    if model_long_names is not None:
        if len(model_long_names) != len(model_names):
            raise ValueError("Must specify the same number of descriptive "
                             "names for models as there are models")
    else:
        model_long_names = len(model_names) * [None]

    ###################   
    num_slices = None
    #num_slices = 3
    ###################
                                          
    # Loop over different plot types to make
    for plot in config.PLOTS:
        print 'Producing "{0:s}" plot...'.format(plot.title)

        input_params = []
        for model_name, model_long_name in zip(model_names, model_long_names):  
            for date in dates:                
                curr_data_dir = "{0:s}/{1:%Y%m%dT%H%MZ}/{2:s}/".format(
                    data_dir, date, model_name)
                cubes = load_and_process_data(curr_data_dir, plot.field)

                curr_plot_dir = "{0:s}/{1:%Y%m%dT%H%MZ}/{2:s}".format(
                    plot_dir, date, model_name)

                # Database file to store all plot information
                db_file = ("{0:s}/imt_tmp_db_{1:%Y%m%dT%H%MZ}_{2:s}.db"
                           .format(plot_dir, date, model_name))

                extra_opts = (curr_plot_dir, db_file)
                if model_long_name is None:
                    extra_opts = extra_opts + (model_name,)
                else:
                    extra_opts = extra_opts + (model_long_name,)

                make_slices = yield_first_cube_in_cubelist_by_slice(
                    cubes, plot, extra_opts=extra_opts, n_slices=num_slices)
              
                first_cube = cubes[0]
                n_times = cube_utils.get_number_of_times(first_cube)
                n_proc_to_use = min(n_proc, n_times)
                if n_proc_to_use == 1:
                    for input_tuple in make_slices:                     
                        if plot.probability_plot:                           
                            _ = prob_plots(input_tuple)
                        elif plot.percentile_plot:                           
                            _ = percentile_plots(input_tuple)
                        else:
                            _ = post_stamp_plots(input_tuple)
                else:
                    proc_pool = Pool(n_proc_to_use) #, maxtasksperchild=1)
                    if plot.probability_plot:
                        _ = proc_pool.map(prob_plots, make_slices) #, chunksize=1)
                    elif plot.percentile_plot:
                        _ = proc_pool.map(percentile_plots, make_slices)
                    else:
                        _ = proc_pool.map(post_stamp_plots, make_slices) #, chunksize=1)
                    proc_pool.close()
                    proc_pool.join()
