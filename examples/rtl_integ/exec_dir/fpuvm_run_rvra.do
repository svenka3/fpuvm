#clear the console
clear

# create project library and make sure it is empty
alib work
#adel -all

transcript file fp_uvm_avl_flash_rvra.log
# compile project's source file (alongside the UVM library)
alog $UVMCOMP -msg 0 -dbg ../fp_uvm/fp_uvm_pkg.sv +incdir+../fp_uvm avl_flash_fp_uvm_top.sv


# run simulation
asim +access +rw  $UVMSIM fp_uvm_avl_flash +UVM_VERBOSITY=UVM_FULL
wave -rec sim:/fp_uvm_avl_flash/* 
run -all
