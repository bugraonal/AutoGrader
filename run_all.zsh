#!/bin/zsh

# This script will automagically will synthesize and simualte student codes. 
# You must have extracted the submission folders into a subdirectory. 
# The folder names must be in LMS format. 
# SYNOPSIS: ./run_all.zsh <FOLDER>
# <FOLDER> contains "<name>_<surname>_<number>_assignsubmission_file_" named folders
# In the current directory you must have :
# 1. synth.tcl -> This is a TCL script for ISE project creation and synthesis
# 2. patterns (optional) -> This is a simulation file containing output vectors
# 3. sim.prj -> This is a project file for ISIM; telling it what to compile
# 4. sim.tcl -> TCL script contaning ISIM commands

# Customizable parameters
TB_NAME="projectCPU2020_tb"
COPIED_FILES=(synth.tcl sim.prj sim.tcl ${TB_NAME}.v blram.v projectCPU2020_program.v)
FOLDER_PATTERN="*_file_"

# Current directory
PWD_=$(pwd)

# Export variables for ISIM
export XILINX=$HOME/tools/Xilinx/14.7/ISE_DS/ISE
export PLATFORM=lin64
export PATH=$PATH:${XILINX}/bin/${PLATFORM}
export LD_LIBRARY_PATH=${XILINX}/lib/${PLATFORM}

# Deletes the spaces in folder names
find $1 -depth -name "* *" -type d -execdir rename 's/ /_/g' "{}" \;

# The files to be copied into student folders
# It assumes the folder format is in LMS format
# You can add or remove files from here
for target in $COPIED_FILES
    find $1 -maxdepth 1 -mindepth 1 -name $FOLDER_PATTERN -exec cp $target {} \;

# Creates a folder for the logs
if ( ! [ -d $PWD_/$1/logs ] ) {
    mkdir $PWD_/$1/logs
}

# For every folder
# Run synthesis and put the errors and warnings into logs
# Run simulation and log the output
for dest in $PWD_/$1/*; do
    NAME=$(echo "$dest" | sed "s/.*[\/.*]*\///") 
    [ -d $dest ] && cd $dest && xtclsh synth.tcl | grep -E "(WARNING)|(ERROR)" > synth.log ; cp synth.log "../logs/${NAME}_synth.log";
    [ -d $dest ] && fuse -intstyle ise -incremental -o sim_exec -prj sim.prj work.${TB_NAME} && ./sim_exec -tclbatch sim.tcl > sim.log ; cp sim.log "../logs/${NAME}_sim.log";
done

# Remove the log file if it exits
if (  [ -f $PWD_/$1/logs/log ] ) {
    rm $PWD_/$1/logs/log
}

# Append all the logs into a single log file 
cd $PWD_/$1/logs
for target in ${PWD_}/$1/logs/*; do echo "${target}\n" >> log; cat $target >> log; echo "\n------------------------------------------------" >> log ; done
