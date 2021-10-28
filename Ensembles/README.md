# Ensemble plots

This workflow watches for met office plots appearing checking every 5 mins for a new folder and then waits for all the plots to appear before harvesting the requested plots and putting them into reduced size powerpoint presentations available via [jasmin public html](http://gws-access.jasmin.ac.uk/public/swift/TestBed3/).

## Requirements

* anaconda to activate [swift_tb3 python environment](../swift_tb3.yml)
* [pngquant](https://pngquant.org/install.html)


## To run automation

On Jasmin clone this repository and run:

` ./ensembles_workflow.sh > /logs/logs 2> logs/err &`

If running on another machine you may need to edit the default file paths. These are all set as Variables for ease of alteration. `plot_grabber.sh` also can retrieve images via `wget`  (setting the `-j "N"` and `-u <url>` options)

## The workflow

The process of the workflow is broken down into the following steps.

1. A predetermined folder in which images from the two metoffice runs are to appear is checked every 5 mins for a new simulation folder.
2. When a new folder is found the script begins to check each run for the expected number of folders (with some leeway for some rsync failures)
3. Once the expected numbers of file have been found for a run the powerpoint generation process is triggered `gen_cp_ppt.sh` or `gen_global_ppt.sh`
4. These scripts grab the 100s of plots required out of the 40000+ images arriving to jasmin and reduce the file sizes via `size_reduction.sh` before sorting them into country/region folders
5. They then run `ppt_gen.py` to produce ppts for each country /region and run in a predetermined format before moving then ppts to a public html folder
6. Once the ppts have been generated the scripts email the script author to inform the ppts are up and viewable and these emails are forwarded to the appropriate users via outlook rules.
7. The workflow script then begins waiting for the next folder to appear.


## PowerPoint contents
