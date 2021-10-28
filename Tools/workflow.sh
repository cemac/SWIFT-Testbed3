#!/bin/bash -
#title          :workflow.sh
#description    :
#author         :CEMAC - Helen
#date           :20213006
#version        :1.0
#usage          :./workflow.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# activate python environment
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda activate
conda activate swift_tb3

# Set some vars
# WG
WG=ensembles
tag=""
now=20211024
url=path_to/folder_name
# Best to work in separeate directory
cd $WG
# Example code checking for new folder of images to be produced
for i in $(seq  1 600)
 do
    # Calculate total time in mins script has been running
    END="$(date +%s)"
    DURATION=$[ ${END} - ${START} ]
    # how long in hours
    DURATION=$(($DURATION/(60)))
    # This line will depend on your file path (it is counting '/' to get the directory name)
    last_dir=$(ls -td -- ${url}/*/ | head -n 1 | cut -d'/' -f10)
    # Report back how much time has past
    echo -e "${DURATION} mins have past, last dir found was ${last_dir}" >> output.txt
    no_folders=$(ls -d ${url}/*/ | wc -l)
    # Is there a new folder?
    # if so then make some ppts
    if [[ ! ${no_folders} = ${old_nofolders} ]];
	   then
      # grab some plots, with a tool like plot_gabber or preprocess_GFS etc for
      # synoptic plotting work flow
      ./Ensembles/plot_grabber.sh # <req options>
      # if you used the plotgrabber the files will be in an images folder
      cd images
      # size size_reduction uses pngquant to drastically reduce file sizes
      ../size_reduction.sh
      # Take images and make ppt in predifend layout according to working group
      python ppt_gen.py --WG "ENS"
      mv SWIFT_ppt.pptx $now"_"$WG"_"$tag".pptx"
      # These steps are done in Ensembles/gen_global_ppts.sh
      # or Synoptic/synoptic_workflow.sh
    fi
    old_nofolders=$(ls -d $url/*/ | wc -l)
done
