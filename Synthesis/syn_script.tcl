
########################## Define Some Variables ############################
  
set top_module Modular_Inverse
set home_path {/home/IC/Projects/Mod_inv}
                                                   
################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries           #"
puts "###########################################"

#Add the path of the libraries to the search_path variable
lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys
lappend search_path $home_path/RTL
lappend search_path $home_path/RTL/Premapped

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format verilog

read_file -format $file_format Mod_Inv.sv   


###################### Defining toplevel ###################################

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

###################### Design constraints ############################
puts "###############################################"
puts "############# Design Constraints ##############"
puts "###############################################"

# Constraints
# ----------------------------------------------------------------------------
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

set CLK_NAME CLK
set CLK_PER 15
set CLK_SETUP_SKEW 1.5
set CLK_HOLD_SKEW 0.39
set CLK_LAT 0
set CLK_RISE 0.1
set CLK_FALL 0.1

create_clock -name $CLK_NAME -period $CLK_PER -waveform "0 [expr $CLK_PER/2]" [get_ports i_clk]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK_NAME]
set_clock_transition -rise $CLK_RISE  [get_clocks $CLK_NAME]
set_clock_transition -fall $CLK_FALL  [get_clocks $CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $CLK_NAME]

####################################################################################
           #########################################################
                  #### Section 2 : Clocks Relationships ####
           #########################################################
####################################################################################



####################################################################################
           #########################################################
             #### Section 3 : #set input/output delay on ports ####
           #########################################################
####################################################################################

set in_delay  [expr 0.2*$CLK_PER]
set out_delay [expr 0.2*$CLK_PER]

#Constrain Input Paths
set_input_delay $in_delay -clock $CLK_NAME [get_port i_a]
set_input_delay $in_delay -clock $CLK_NAME [get_port i_p]


#Constrain Output Paths
set_output_delay $out_delay -clock $CLK_NAME [get_port o_R]
set_output_delay $out_delay -clock $CLK_NAME [get_port o_busy]


####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX32M -pin Y [get_port i_a]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX32M -pin Y [get_port i_p]


####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 25 [get_port o_R]
set_load 25 [get_port o_busy]


####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################

set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

####################################################################################
           #########################################################
                #### Section 8 : Area  ####
           #########################################################
####################################################################################

set_max_area 0

####################################################################################
           #########################################################
                #### Section 9 : power  ####
           #########################################################
####################################################################################



###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

compile

################## Save SDC file After compilation ########################

write_sdc -nosplit ./Constraints/${top_module}.sdc

puts "########## checks the design after compilation to ensure that all ##########"
puts "########## the cells in the design is mapped to Tech library cells #########"
puts "####### and these kind of check is meaningless before compilation step #####"

check_design  -unmapped > ./Reports/check_mapped_design_post_compile.rpt

##################### Check Timing Constraints ############################

puts "###### To check for constraint problems such as undefined clocking, ######"  
puts "#### undefined input arrival times, and undefined output constraints #####"

check_timing -multiple_clock > ./Reports/check_timing.rpt

#############################################################################
# Write out Design after initial compile
#############################################################################

write_file -format ddc -hierarchy -output ./Netlists/${top_module}.ddc
write_file -format verilog -hierarchy -output ./Netlists/${top_module}.v

############################### Reporting ##################################

#  reports dynamic and static power for the design or instance.
report_power > ./Reports/power.rpt

# Displays information about all ports showing the drive capability of input and inout ports.
report_port -verbose > ./Reports/port_info.rpt

# Check clocks information
report_clock -attributes > ./Reports/clock_info.rpt

# Report constraints.
report_constraint -all_violators -nosplit > ./Reports/constraints.rpt

# Report worst #setup analysis paths 
# -net to include nets delays in the report
# -max_paths Specifies the number of paths to report per path group 
report_timing -max_paths 10 -delay_type max -nosplit > ./Reports/timing_max.rpt
report_timing -max_paths 10 -delay_type min -nosplit > ./Reports/timing_min.rpt

# Report hierarchy
report_hierarchy -nosplit -full > ./Reports/hierarchy.rpt

# Report area
report_area > ./Reports/area.rpt


################# starting graphical user interface #######################

gui_start

#exit
