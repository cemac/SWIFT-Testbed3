#!/bin/bash -
#title          :installtestbed.sh
#description    :This script installs the swift Testbed3
#author         :CEMAC - Helen
#date           :20210326
#version        :1.0
#usage          :./installtestbed.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================
echo "downloading submodules"
# install submodules
git submodule init
git submodule update --init --recursive
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod 755 Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
# create and activate virtual environment
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda create --name swift_tb3
conda activate
conda install -c conda-forge --file requirements.txt -y
echo "set up complete"
