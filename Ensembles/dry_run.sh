#!/bin/bash

# This script is an example of running a function 
# and logging output every hour for 36 hours
rm -f output.txt
echo -e "test long run sleep script\n" > output.txt
START="$(date +%s)"
url=/gws/nopw/j04/swift/public/requests/SWIFT_TB3/july_dryrun/plotting_suite/
old_nofolders=$(ls -d ${url}*/ | wc -l)
old_nofolders=2
for i in $(seq  1 1000)
 do   
    # sleep for 5 mins
    sleep $((60*5)) 
    END="$(date +%s)"
    DURATION=$[ ${END} - ${START} ]
    # how long in hours
    DURATION=$(($DURATION/(60)))
    echo -e "${DURATION} mins have past" >> output.txt
    no_folders=$(ls -d ${url}/*/ | wc -l)
    if [[ ! ${no_folders} = ${old_nofolders} ]];
	then
    echo new folder found >> output.txt
    echo $(ls -d ${url}*/) >> output.txt
    new_dir=$(ls -td -- ${url}*/ | head -n 1 | cut -d'/' -f11)
    #new_dir=$(ls -td -- ${url}*/ | head -n 1 | cut -d'/' -f2) 
    date=$(echo $new_dir | cut -d'T' -f1)
    hr=$(echo $new_dir | cut -d'T' -f2)
    if [[ "${hr}" = "0000Z" ]]; then
     hr=00
    else
	hr=$(echo $hr | cut -d'0' -f1)
    fi
    echo hr is "${hr}" >> output.txt
    echo new dir is "${new_dir}" >>output.txt
    pptsdone="N"
    globalpptsdone="N"
    cppptsdone="N"
    for i in $(seq  1 200)
    do
	echo waiting for files
	no_filesglobal=$(ls ${url}/${new_dir}/mo-g/* | wc -l)
	no_files=$(ls ${url}/${new_dir}/* | wc -l)
	if (( ${no_files} < 41300  )); then
	sleep $((60*5))
	fi
	if (( ${no_filesglobal} > 28200 )); then
	    if [[ "${globalpptsdone}" = "N" ]]; then
		echo nearly all files found wait 5 mins then run
		sleep $((60*5))
		echo all files found, start ppt gen
		./test_global.sh -d "${date}" -t "${hr}"
		globalpptsdone='Y'
	    fi
	fi
	no_filescp=$(ls ${url}/${new_dir}/km8p8_ra2t/* | wc -l)
	
	if (( ${no_filescp} > 13080 )); then
	    if [[ "${cppptsdone}" = "N" ]]; then
		echo nearly all files found wait 5 mins then run
		sleep $((60*5))
		echo all files found, start ppt gen
		./test_cp.sh -d "${date}" -t "${hr}"
		cppptsdone='Y'
	    fi
	fi
    done
    fi
    old_nofolders=$(ls -d $url/*/ | wc -l)
 done
