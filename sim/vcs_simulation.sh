#!/bin/bash

# Set the desired simulation parameters
SIMULATION_FILE="../TB/Modular_Inverse_tb.v"      # Test-bench file
OUTPUT_FILE="simulation.log"                      # Log file to store simulation output

# Set the VCS command and options
VCS_COMMAND="vcs"
VCS_OPTIONS="-R -sverilog -debug_all"

# Compile the design files
$VCS_COMMAND $VCS_OPTIONS $SIMULATION_FILE

# Run the simulation
./simv > $OUTPUT_FILE

# Display the simulation log
cat $OUTPUT_FILE
