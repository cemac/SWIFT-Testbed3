# SWIFT Testbed 3 Synoptic chart generation workflow

## Environment

Python environments managed through Anaconda and JASMIN's jaspy module
are used to provide the software environments used in this workflow.

The user running the scripts should also initialise `$SWIFT_GFS` to a
location suitable for storage of raw and pre-processed GFS data.  This
directory should also contain a file `$SWIFT_GFS/controls/namelist`
with the following format.

```
init: 2021083106
region: EA, WA, PA
fore: 003, 006, 009, 012, 015, 018, 021, 024, 027, 030, 033, 036, 039, 042, 045, 048, 051, 054, 057, 060, 063, 066, 069, 072
```

## Data acquisition via cron

GFS data is downloaded from NOAA every 6 hours.  The time selection is
based on when we expect GFS data to be available in local time (BST).

```{bash}
[tdjames1@cron1 Synoptic [main]$ crontab -l
0 5-23/6 * * * . $HOME/.bash_profile; crontamer -t 2h '$HOME/SWIFT-Testbed3/Synoptic/get_data.sh'
```

The script invoked by cron carries out the following steps:

```
# Update namelist to specify latest GFS initialisation time
/gws/nopw/j04/swift/SWIFT-Testbed3/Nowcasting/GFS_plotting/scripts/automation/edit_namelist.sh

# Get GFS data for the specified initialisation time from NOAA via HTTP
/gws/nopw/j04/swift/SWIFT-Testbed3/Synoptic/get_GFS_batch.sh
```

## Data monitoring

The script `check_GFS.sh` monitors the directory within
`$SWIFT_GFS/GFS_NWP` corresponding to the current GFS initialisation
time.  If a full batch of GFS grib2 files is available then the chart
generation workflow is triggered.  Otherwise the script sleeps 10
minutes before looping through the same process.  This script is
intended to be left running in the background on one of the JASMIN sci
machines during the testbed.  In the case of any maintenance or
downtime this process will need to be restarted.

## Chart generation workflow

The chart generation workflow is initiated by `check_GFS.sh` which
calls the script `synoptic_workflow.sh`, which in turn calls scripts
to handle the following tasks.

### Preprocessing

Python environment: jaspy

The downloaded GFS data is in grib2 format and is converted to NetCDF4
for ease of use.  Additionally, we select a subset of variables,
adjust the time format, and combine forecast data to obtain a single
file.

### Chart generation

Python environment: swift_synoptic

Creates synoptic charts for the current initialisation time and
regions and forecast times as specified in
`$SWIFT_GFS/controls/namelist`.  Note that chart types (which vary
between regions) are specified in the script.

After synoptic charts have been produced for the current
initialisation time, T-24h data (used for generating pressure
tendency) are deleted to free up disk space.

### Powerpoint generation

Python environment: swift_tb3

Combines synoptic charts into powerpoints for East Africa and West
Africa.  These files are made available via the SWIFT GWS public
folder.
