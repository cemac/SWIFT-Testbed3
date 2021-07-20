#!/bin/bash

# This script is an example of running a function 
# and logging output every hour for 36 hours
rm -f output.txt
echo -e "test long run sleep script\n" > output.txt
START="$(date +%s)"
for i in $(seq  1 36)
 do 
    # sleep for 1 hour
    sleep $((60*60)) 
    END="$(date +%s)"
    DURATION=$[ ${END} - ${START} ]
    # how long in hours
    DURATION=$(($DURATION/(60*60)))
    echo -e "${DURATION} mins have past" >> output.txt
 done
