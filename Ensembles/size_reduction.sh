#!/bin/bash -
#title          :size_reduction.sh
#description    :uses pngquant to reduce file size of all png files in the
#                current folder
#author         :CEMAC - Helen
#date           :20213006
#version        :1.0
#usage          :./size_reduction.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

find . -type f -iname '*.png' -exec ../pngquant --force --quality=40-100 --skip-if-larger --strip --verbose {} --output {} \;
