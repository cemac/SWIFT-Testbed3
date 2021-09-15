#!/bin/bash

# This script is the SWIFT TestBed3 workflow script for the autogeneration of
# Ensembles ppts.
# At 0000 and 12000 hours the global mogreps run is performed and at 0300 and 1500
# a convection permitting model is run at 0300 and 1500 on the metoffice machines and
# a plotting_suite is run and with a rsync job moving plots to jasmin
#
# This script searches for those plots to apprear on jasmin, once the plots begin to
# arrive the script will wait untill all plots are on jasmin before selected the requested
# plots for ensembles wg and put them into an autogenerated ppt via the globalppt.sh and
# cpppt.sh scripts which call plotgrabber.sh
#
# Requirements python with the packages from swift_tb3.yml and pngquant (outlined in install.sh)
#
# Create an output.txt file to log progres
# Remove old output.txt file
rm -f output.txt
echo -e "Running Automated WorkFlow For Ensembles Swift TestBed3\n" > output.txt
START="$(date +%s)" # Grab start time to report how much time has past
# url can be set to the path on jasmin where the metoffice plots will appear or
# the url of the public folder (plot)
url=/gws/nopw/j04/swift/public/requests/SWIFT_TB3/WEEK2_13_19_Sep
# Find starting number of folders in root directory
old_nofolders=$(ls -d ${url}/* | wc -l)
#old_nofolders=0
# for iterations of 5 mins
# 48 hours = 576
# 1 week = 2016
# 2 weeks = 4032
for i in $(seq  1 2016)
 do
    # sleep for 5 mins
    sleep $((60*5))
    # Calculate total time in mins script has been running
    END="$(date +%s)"
    DURATION=$[ ${END} - ${START} ]
    # how long in hours
    DURATION=$(($DURATION/(60)))
    echo -e "${DURATION} mins have past" >> output.txt
    no_folders=$(ls -d ${url}/*/ | wc -l)
    # Is there a new folder?
    if [[ ! ${no_folders} = ${old_nofolders} ]];
	   then
       echo new folder found >> output.txt
       echo $(ls -td -- ${url}/*/ | head -n 1 ) >> output.txt
      # list most recent directory
      new_dir=$(ls -td -- ${url}/*/ | head -n 1 | cut -d'/' -f10)
      # Extract the date from folder name
      date=$(echo $new_dir | cut -d'T' -f1)
      # Extract hour from folder name
      hr=$(echo $new_dir | cut -d'T' -f2)
      # 0000Z is hard to extract just 00 so force it
      if [[ "${hr}" = "0000Z" ]]; then
       hr=00
      else
  	     hr=$(echo $hr | cut -d'0' -f1)
      fi
      echo hr is "${hr}" >> output.txt
      echo new dir is "${new_dir}" >>output.txt
      # New folder has been identified but no ppts generated
      pptsdone="N"
      globalpptsdone="N"
      cppptsdone="N"
      # Over the next 12 hours find when the folders are full
      for i in $(seq  1 144)
        do
        # Split into global and cp
      	no_filesglobal=$(ls ${url}/${new_dir}/mo-g/ | wc -l)
      	no_files=$(ls ${url}/${new_dir}/* | wc -l)
        # If the total number of files found is less than the expected amount
        # keep sleeping
      	if (( ${no_files} < 46600  )); then
      	   sleep $((60*5))
	   echo waiting for files
      	fi
        # Check global file number and if global ppts have been generated
        if (( ${no_filesglobal} > 31800 )); then
	    if [[ "${globalpptsdone}" = "N" ]]; then
        		echo nearly all global files found wait 5 mins then run
        		sleep $((60*5))
        		echo all files found, start ppt gen
        		./test_global2.sh -d "${date}" -t "${hr}"
			echo "global ppts generated"  >>output.txt
			# set globalpptsdone to y to prevent this code from exectuing again
        		globalpptsdone='Y'
      	    fi
      	fi
        # Check CP number of files and if CP ppt has been generated
    	  no_filescp=$(ls ${url}/${new_dir}/km8p8_ra2t/ | wc -l)
    	  if (( ${no_filescp} > 14780 )); then
    	    if [[ "${cppptsdone}" = "N" ]]; then
        		echo nearly all CP files found wait 5 mins then run
        		sleep $((60*5))
        		echo all CP files found, start ppt gen
        		./test_cp2.sh -d "${date}" -t "${hr}"
			echo "cp ppt generated"  >>output.txt
			# prevent this section of code from generating again
        		cppptsdone='Y'
    	    fi
    	  fi
        done
    # Set a new number of oldfolers
    old_nofolders=$(ls -d $url/*/ | wc -l)
    fi

  done
