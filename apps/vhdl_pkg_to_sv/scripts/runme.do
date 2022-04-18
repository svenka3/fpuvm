# (c) AumzDA, LLC
# All rights reserved.
#


# load procedures and variables
source $aldec/examples/commonscripts/procedures.do

# create project library and clear its contents
createWorklib fpuvm_lib
adel -all

transcript file az_comp.log

# compile project's source files
set TARGET libaz_fpuvm_app
ccomp -vhpi -o $TARGET -dbg ../vhpi_src/fpuvm_vhdl_pkg_to_sv_app.cpp
acom -dbg ../vhpi_src/fpuvm_apps_pkg.vhdl 
createWorklib work
acom -dbg ../test_src/test.vhd

# initialize simulation
asim -cdebug test


# advance simulation
run -all

# terminate simulation
endsim

