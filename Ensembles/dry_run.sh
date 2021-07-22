#!/bin/bash

# This script is an example of running a function 
# and logging output every hour for 36 hours
rm -f output.txt
echo -e "test long run sleep script\n" > output.txt
START="$(date +%s)"
url=/gws/nopw/j04/swift/public/requests/SWIFT_TB3/july_dryrun/
old_nofolders=$(ls -d ${url}*/ | wc -l)
for i in $(seq  1 600)
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
    new_dir=$(ls -td -- ${url}/*/ | head -n 1 | cut -d'/' -f10)
    #new_dir=$(ls -td -- ${url}*/ | head -n 1 | cut -d'/' -f2) 
    date=$(echo $new_dir | cut -d'T' -f1)
    hr=$(echo $new_dir | cut -d'T' -f2)
    hr=$(echo $hr | cut -d'0' -f1)
    echo hr is ${hr} >> output.txt
    echo new dir is ${new_dir} >>output.txt
    ./test.sh -d "${date}" -t "${hr}"
    fi
    old_nofolders=$(ls -d $url/*/ | wc -l)
 done
