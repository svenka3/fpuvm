FPUVM DUT Integration app - demo
--------------------------------

Welcome to a quick demo of FPUVM with Aldec Riviera-Pro.
The intention is to show that starting from a design/RTL design 
to go to a UVM Test can be done in a matter of minutes. 
FPUVM provides an automation that's already built and it's all free, 
opensource available.

The target design is Altera on chip flash AVMM CSR controller. 
The top module name is avl_flash and there is a clock and a reset 
These are the only three things that the app needs as inputs from the user
to build a UVM test bench. Of-course you need all the DUT ports - that is 
auto-extracted from design database by this app.  Given the ports are 
already declared in the RTL there is no reason for end-users to go and 
code them manually.

Directory structure:
--------------------
README --> This file
vlog_src --> RTL design sources are stored in this directory
exec_dir --> Execution directory 
  
How to run in command-line?
--------------------------
# Change working dir
cd exec_dir
# Create work-lib
vlib work
# Compile RTL source(s)
vlog -dbg ../vlog_src/avalon_onchip_flash_avmm_csr_controller.v
# Bring up design in Riviera-Pro GUI
vsim +access+rw avl_flash &

# Inside the console window of Riviera-Pro (Bottom-left)
# Source the app code
source ../fp_uvm/apps/az_gen_fp_uvm_rpro.tcl

# Now that FPUVM app is ready to use, type fp_uvm_gen
fp_uvm_gen

# The app asks for 3 information from user
# Key-in the same as below
"Enter top module (DUT) name: "
> avl_flash
"Enter clock signal name: "
> clock
"Enter reset signal name: "
> reset_n

# The app will now query the Simulation/Elaborated DB
# and extract DUT port names, directions, widths
# It stores the above information in internal DataStructure 
# and generates following files:
# <module>_if.sv
# <module>_s_fp_uvm_top.sv
# <module>_s_fp_uvm_test.sv
#
# App also generates Do/Macro file for Riviera-Pro
# Towards the end of the integration, the app opens the Macro file in RPRO
# Execute the macro

>> Once the DO file opens, click on Tools --> Execute Macro

# That should compile RTL, FPUVM test, Interface, TopTB along with UVM libraries
# After compile, it starts asim to do elaboration & simulation
# Waveform is automatically added, click on that tab and review waves


What gets generated?
----------------------
A quick note we are at this stage just generating a simple UVM test.
It has bare minimum uvm code that is needed to integrate and test a design.
It doesn't have all your bills and whistles of UVM just yet but we believe 
you can start here and start building it from here onwards 



