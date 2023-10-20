#!/bin/bash

# Creating necessary folders needed for synthesis
source mkdir.sh

# Log file to store synthesis output
SYNTHESIS_LOG="log/synthesis.log" 


# Calling the Synthesis TCL Script
dc_shell -f syn_script.tcl | tee $SYNTHESIS_LOG
