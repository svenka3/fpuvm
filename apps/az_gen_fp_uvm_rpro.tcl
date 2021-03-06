
# --------------------------------------------------------------------------------
#
# [Name]     
#   az_gen_fp_uvm_rpro.tcl
#
# [Version]  
#   1.0
#
# [Abstract]
#   Create SystemVerilog Interface for given RTL TOP level
#
# [Procedure]
#   fp_uvm_gen
#
#  # --------------------------------------------------------------------------------

namespace eval az_gen_ns {
  variable in_port_names_l []
  variable out_port_names_l []
  variable inout_port_names_l []
  variable az_dut_name
  variable az_clk_name
  variable az_rst_name
}

proc dump_header { LOG } {
  puts $LOG "/********************************************"
  puts $LOG "* FPUVM App: UVM for FPGAs"
  puts $LOG "* Automatically generated by FPUVM Riviera App "
  puts $LOG "* Visit http://fp-uvm.blogspot.com for more "
  set t [clock seconds]
  set format_str [clock format $t -format "%Y-%m-%d %H:%M:%S"]
  puts $LOG "* Generated on   : $format_str"
  puts $LOG "********************************************/ \n\n"
}


proc wsplit {string sep} {
    set first [string first $sep $string]
    if {$first == -1} {
      return [list $string]
    } else {
      set tmp_l [string length $sep]
      set left [string range $string 0 [expr {$first-1}]]
      set right [string range $string [expr {$first+$tmp_l}] end]
      return [concat [list $left] [wsplit $right $sep]]
    }
}

proc az_gen_sv_intf {LOG top_mod clk_name rst_name } {
  set mod_name      $top_mod
  puts $LOG "// Generating SystemVerilog interface for module: $mod_name"
  puts $LOG "// ---------------------------------------------------------"

  set in_ports [find object -in -list -path /$top_mod *]
  set out_ports [find object -out -list -path /$top_mod *]
  set inout_ports [find object -inout -list -path /$top_mod *]
  set total_num_ports [expr [llength $in_ports] + [llength $out_ports] + [llength $inout_ports]]

  # Create INPUT port name & size
  # set in_port_names_l []
  set in_port_sizes_l []
  foreach item $in_ports {
    set port_des [describe $item]
    set tmp_s [split $item /]
    set tmp_last_val_index [expr [llength $tmp_s] - 1]
    set tmp_port_name [lindex $tmp_s $tmp_last_val_index]
    lappend ::az_gen_ns::in_port_names_l $tmp_port_name

    set tmp_s [wsplit $port_des "\n"]
    set tmp1_s [lindex $tmp_s 0]
    if {[string match *Net* $tmp1_s]} {
      set tmp2_s [wsplit $tmp1_s Net]
      puts "Found Net"
    } elseif {[string match *Logic* $tmp1_s]} {
      set tmp2_s [wsplit $tmp1_s Logic]
      puts "Found Logic"
    } else {
      set tmp2_s [wsplit $tmp1_s Net]
      puts "Found UNKNOWN datatype for port $tmp_port_name treating as Net"
    }
      
    set tmp_last_val_index [expr [llength $tmp2_s] - 1]
    set tmp_port_size [lindex $tmp2_s $tmp_last_val_index]
    # echo "SV: $tmp_port_size"
    if {$tmp_port_size == ""} {
      #echo "Single bit"
      set tmp_port_size { }
    }
    lappend in_port_sizes_l $tmp_port_size
    echo "IN: $tmp_port_name $tmp_port_size"
  }
  # Create OUTPUT port name & size
  set out_port_sizes_l []
  foreach item $out_ports {
    set port_des [describe $item]
    set tmp_s [split $item /]
    set tmp_last_val_index [expr [llength $tmp_s] - 1]
    set tmp_port_name [lindex $tmp_s $tmp_last_val_index]
    lappend ::az_gen_ns::out_port_names_l $tmp_port_name

    set tmp_s [wsplit $port_des "\n"]
    set tmp1_s [lindex $tmp_s 0]

    set found_net [string match *Net* $tmp1_s]

    if {$found_net == 1} {
      set tmp2_s [wsplit $tmp1_s Net]
    } elseif {[string match *Logic* $tmp1_s]} {
      set tmp2_s [wsplit $tmp1_s Logic]
    } else {
      set tmp2_s [wsplit $tmp1_s Register]
    }
    set tmp_last_val_index [expr [llength $tmp2_s] - 1]
    set tmp_port_size [lindex $tmp2_s $tmp_last_val_index]
    # echo "SV: $tmp_port_size"
    if {$tmp_port_size == ""} {
      #echo "Single bit"
      set tmp_port_size { }
    }
    lappend out_port_sizes_l $tmp_port_size
    echo "OUT: $tmp_port_name $tmp_port_size"
  }

  # Create INOUT port name & size
  set inout_port_sizes_l []
  foreach item $inout_ports {
    set port_des [describe $item]
    set tmp_s [split $item /]
    set tmp_last_val_index [expr [llength $tmp_s] - 1]
    set tmp_port_name [lindex $tmp_s $tmp_last_val_index]
    lappend ::az_gen_ns::inout_port_names_l $tmp_port_name

    set tmp_s [wsplit $port_des "\n"]
    set tmp1_s [lindex $tmp_s 0]
    if {[string match *Net* $tmp1_s]} {
      set tmp2_s [wsplit $tmp1_s Net]
      puts "Found Net"
    } elseif {[string match *Logic* $tmp1_s]} {
      set tmp2_s [wsplit $tmp1_s Logic]
      puts "Found Logic"
    } else {
      set tmp2_s [wsplit $tmp1_s Net]
      puts "Found UNKNOWN datatype for port $tmp_port_name treating as Net"
    }
    set tmp_last_val_index [expr [llength $tmp2_s] - 1]
    set tmp_port_size [lindex $tmp2_s $tmp_last_val_index]
    # echo "SV: $tmp_port_size"
    if {$tmp_port_size == ""} {
      #echo "Single bit"
      set tmp_port_size { }
    }
    lappend inout_port_sizes_l $tmp_port_size
    echo "INOUT: $tmp_port_name $tmp_port_size"
  }



  #puts "Start INTF gen"

  set intf_hdr [format "interface %s_if (input logic %s);" $mod_name $clk_name]
  puts $LOG "$intf_hdr"

  set num_in_ports [llength $::az_gen_ns::in_port_names_l]
  set cur_port_num 0
  #puts "in: $num_in_ports"
  while { $cur_port_num < $num_in_ports } { 
    set port_name [lindex $::az_gen_ns::in_port_names_l $cur_port_num]
    #puts "IN: port: $port_name"

    if {$port_name == $clk_name} {
      # Skip clk signal
      incr cur_port_num
      continue
    }
    set port_size [lindex $in_port_sizes_l $cur_port_num]
    set intf_hdr [format "  logic %s %s;" $port_size $port_name]
    puts $LOG "$intf_hdr"
    incr cur_port_num
  }
        
  set num_out_ports [llength $::az_gen_ns::out_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_out_ports } { 
    set port_name [lindex $::az_gen_ns::out_port_names_l $cur_port_num]
    set port_size [lindex $out_port_sizes_l $cur_port_num]
    set intf_hdr [format "  logic %s %s;" $port_size $port_name]
    puts $LOG "$intf_hdr"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  set num_inout_ports [llength $::az_gen_ns::inout_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_inout_ports } { 
    set port_name [lindex $::az_gen_ns::inout_port_names_l $cur_port_num]
    set port_size [lindex $inout_port_sizes_l $cur_port_num]
    set intf_hdr [format "  logic %s %s;" $port_size $port_name]
    puts $LOG "$intf_hdr"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  puts $LOG "  // End of interface signals "
  puts $LOG "\n\n  // Start of clocking block definition "

  # All interface signals declared

  # Start clocking block generation
  set cb_line "  clocking drv_cb @(posedge $clk_name);" 
  puts $LOG "$cb_line"
  set cur_port_num 0
  while { $cur_port_num < $num_in_ports } { 
    set port_name [lindex $::az_gen_ns::in_port_names_l $cur_port_num]
    if {$port_name == $clk_name} {
      # Skip clk signal
      incr cur_port_num
      continue
    }
    set cb_line [format "    output %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  set num_out_ports [llength $::az_gen_ns::out_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_out_ports } { 
    set port_name [lindex $::az_gen_ns::out_port_names_l $cur_port_num]
    set cb_line [format "    input %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  set num_inout_ports [llength $::az_gen_ns::inout_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_inout_ports } { 
    set port_name [lindex $::az_gen_ns::inout_port_names_l $cur_port_num]
    set cb_line [format "    inout %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
   # End of while  -- clocking block gen
  set cb_line [format "  endclocking : drv_cb"]
  puts $LOG "$cb_line"
  puts $LOG "  // End of clocking block definition "
  puts $LOG "  "


  # Start monitor clocking block generation
  set cb_line "  clocking mon_cb @(posedge $clk_name);" 
  puts $LOG "$cb_line"
  set cur_port_num 0
  while { $cur_port_num < $num_in_ports } { 
    set port_name [lindex $::az_gen_ns::in_port_names_l $cur_port_num]
    if {$port_name == $clk_name } {
      # Skip clk signal
      incr cur_port_num
      continue
    }
    set cb_line [format "    input %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  set num_out_ports [llength $::az_gen_ns::out_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_out_ports } { 
    set port_name [lindex $::az_gen_ns::out_port_names_l $cur_port_num]
    set cb_line [format "    input %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
        
  set num_inout_ports [llength $::az_gen_ns::inout_port_names_l]
  set cur_port_num 0
  while { $cur_port_num < $num_inout_ports } { 
    set port_name [lindex $::az_gen_ns::inout_port_names_l $cur_port_num]
    set cb_line [format "    input %s;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
   # End of while  -- clocking block gen
  set cb_line [format "  endclocking : mon_cb"]
  puts $LOG "$cb_line"
  puts $LOG "  // End of clocking block definition "
  # End of clocking block generation
  
  puts $LOG "\n  // Start of init_signals task \n"
  # Start init_signals generation
  set intf_hdr [format "  task init_signals ();"]
  puts $LOG "$intf_hdr"
  set cur_port_num 0
  while { $cur_port_num < $num_in_ports } { 
    set port_name [lindex $::az_gen_ns::in_port_names_l $cur_port_num]
    if {$port_name == $clk_name} {
      # Skip clk signal
      incr cur_port_num
      continue
    }
    set cb_line [format "    %s = 0;" $port_name]
    set cb_line [format "    drv_cb.%s <= 0;" $port_name]
    puts $LOG "$cb_line"
    set cur_port_num [expr $cur_port_num + 1]
  }
  set intf_hdr [format "  endtask : init_signals"]
  puts $LOG "$intf_hdr"
        

  puts $LOG ""
  set intf_hdr [format "endinterface : %s_if" $mod_name]
  puts $LOG "$intf_hdr"

}



proc az_gen_fp_uvm_top_mod {LOG top_mod if_fname clk_name rst_name } {
  set mod_name      $top_mod
  puts $LOG "// Generating FPUVM top module for DUT: $mod_name"
  puts $LOG "// ---------------------------------------------------------"
#  puts $LOG "`include \"$if_fname\""
  set class_hdr [format "`include \"%s_if.sv\"" $top_mod]
  puts $LOG "$class_hdr"
  set class_hdr [format "`include \"%s_fp_uvm_test.sv\"" $top_mod]
  puts $LOG "$class_hdr"

  set class_hdr [format "module fp_uvm_%s;" $top_mod]
  puts $LOG "$class_hdr"
  puts $LOG "  timeunit 1ns;"
  puts $LOG "  timeprecision 1ns;"
  puts $LOG "  parameter CLK_PERIOD = 10;"
  puts $LOG ""
  puts $LOG "  // Simple clock generator"
  puts $LOG "  bit $clk_name ;"
  puts $LOG "  always # (CLK_PERIOD/2) $clk_name <= ~$clk_name;"
  puts $LOG ""
  puts $LOG "  // Interface instance"
  set if_inst_name [format "%s_if_0" $top_mod]
  set mod_line [format "%s_if %s (.*);" $top_mod $if_inst_name]
  puts $LOG "  $mod_line"
  puts $LOG ""
  puts $LOG "  // Connect TB clk to Interface instance clk"
  puts $LOG ""
  set total_num_ports [expr [llength $::az_gen_ns::in_port_names_l] + [llength $::az_gen_ns::out_port_names_l] + [llength $::az_gen_ns::inout_port_names_l]]

  set all_ports_l []
  foreach item $::az_gen_ns::in_port_names_l {
    lappend all_ports_l  $item
  }
  foreach item $::az_gen_ns::out_port_names_l {
    lappend all_ports_l  $item
  }
  foreach item $::az_gen_ns::inout_port_names_l {
    lappend all_ports_l  $item
  }
  set total_num_ports [llength $all_ports_l]

  puts $LOG "  // DUT instance"
  set mod_line [format "%s %s_0 (" $top_mod $top_mod]
  puts $LOG "  $mod_line"
  set tmp_iter 1
  foreach item $all_ports_l {
    if {$tmp_iter < $total_num_ports} {
      set mod_line [format "    .%s(%s.%s)," $item $if_inst_name $item]
    } else {
      set mod_line [format "    .%s(%s.%s)" $item $if_inst_name $item]
    }
    puts $LOG $mod_line
    incr tmp_iter
  }
  puts $LOG "  );"
  puts $LOG ""
  puts $LOG ""
  puts $LOG "  // Using FPUVM"
  set mod_line [format "%s_test %s_test_0;" $top_mod $top_mod]
  puts $LOG "  $mod_line" 
  puts $LOG "  initial begin : fp_uvm_test"
  set mod_line [format "  %s_test_0 = new ();" $top_mod]
  puts $LOG "  $mod_line" 
  puts $LOG "    // Connect virtual interface to physical interface"
  set mod_line [format "%s_test_0.vif = %s_if_0;" $top_mod $top_mod]
  puts $LOG "    $mod_line"
  puts $LOG "    // Kick start standard UVM phasing"
  puts $LOG "    run_test ();"
  puts $LOG "  end : fp_uvm_test"
  set mod_line [format "endmodule : fp_uvm_%s" $top_mod]
  puts $LOG "$mod_line"
  puts $LOG ""
}


proc az_gen_fp_uvm_test {LOG top_mod rst_sig_name } {
  set mod_name      $top_mod
  puts $LOG "// Generating FPUVM Test for module: $mod_name"
  puts $LOG "// ---------------------------------------------------------"
  puts $LOG "" 
  puts $LOG "// Automatically generated from FPUVM app "
  puts $LOG "// Thanks for using FPUVM see http://fp-uvm.blogspot.com for more"
  puts $LOG "" 
  puts $LOG "import uvm_pkg::*;"
  puts $LOG "`include \"fp_uvm_macros.svh\""
  puts $LOG "// Import FPUVM Package"   
  puts $LOG "import fp_uvm_pkg::*;"
  puts $LOG ""
  puts $LOG "// Use the base class provided by the FPUVM"
  set class_hdr [format "class %s_test extends fp_uvm_base_test;" $top_mod]
  puts $LOG "$class_hdr"
  puts $LOG "  // Create a handle to the actual interface"
  set class_hdr [format "  virtual %s_if vif;" $top_mod]
  puts $LOG ""
  puts $LOG "$class_hdr"
  set class_hdr [format "  task reset;" $top_mod]
  puts $LOG "$class_hdr"
  puts $LOG "     `fp_uvm_display (\"Start of reset\")"
  puts $LOG "     `fp_uvm_display (\"Fill in your reset logic here \")"
  puts $LOG "     this.vif.drv_cb.$rst_sig_name <= 1'b0;"
  puts $LOG "     this.vif.init_signals();"
  puts $LOG "     repeat (5) @ (this.vif.drv_cb);"
  puts $LOG "     this.vif.drv_cb.$rst_sig_name <= 1'b1;"
  puts $LOG "     repeat (1) @ (this.vif.drv_cb);"
  puts $LOG "    `fp_uvm_display (\"End of reset\")"
  puts $LOG "  endtask : reset"
  puts $LOG ""
  puts $LOG "  task main ();"
  puts $LOG "    `fp_uvm_display (\"Start of main\", UVM_MEDIUM)"
  puts $LOG "    `fp_uvm_display (\"Fill in your main logic here \")"
  puts $LOG "    // this.vif.drv_cb.inp_1 <= 1'b0;"
  puts $LOG "    // this.vif.drv_cb.inp_2 <= 'haa;"
  puts $LOG "    repeat (50) @ (this.vif.drv_cb);"
  puts $LOG "    `fp_uvm_display (\"End of main\")"
  puts $LOG "  endtask : main"
  puts $LOG ""
  set class_hdr [format "endclass : %s_test" $top_mod]
  puts $LOG "$class_hdr"
  puts $LOG ""
}

proc az_gen_fp_uvm_rvra_do { LOG top_mod} {
  set mod_name $top_mod
  puts $LOG "#clear the console"
  puts $LOG "clear"
  puts $LOG ""
  puts $LOG "# create project library and make sure it is empty"
  puts $LOG "alib work"
  puts $LOG "#adel -all"
  puts $LOG ""
  set rvra_log [format "transcript file fp_uvm_%s_rvra.log" $top_mod]
  puts $LOG "$rvra_log"
  puts $LOG "# compile project's source file (alongside the UVM library)"
  set rvra_log [format "alog \$UVMCOMP -msg 0 -dbg ../fp_uvm/fp_uvm_pkg.sv +incdir+../fp_uvm %s_fp_uvm_top.sv" $top_mod]

  puts $LOG "$rvra_log"
  puts $LOG ""
  puts $LOG ""
  puts $LOG "# run simulation"
  set run_do [format "asim +access +rw  \$UVMSIM fp_uvm_%s +UVM_VERBOSITY=UVM_FULL" $top_mod]
  puts $LOG "$run_do"
  set run_file [format "wave -rec sim:/fp_uvm_%s/* \nrun -all" $top_mod]
  puts $LOG "$run_file"
  set $LOG ""
}  

proc fp_uvm_gen {} {
  ##########################
  # main function for fp_uvm_gen
  ##########################

  az_get_dut_top
  set top_mod $::az_gen_ns::az_dut_name
  set clk_name $::az_gen_ns::az_clk_name 
  set rst_name $::az_gen_ns::az_rst_name 

  set op_if_fname [format "%s_if.sv" $top_mod]
  set op_top_fname [format "%s_fp_uvm_top.sv" $top_mod]
  set op_test_fname [format "%s_fp_uvm_test.sv" $top_mod]
  set op_run_do "fpuvm_run_rvra.do"

  set IF_FPTR [open $op_if_fname "w"]
  set TOP_FPTR [open $op_top_fname "w"]
  set TEST_FPTR [open $op_test_fname "w"]
  set DO_FPTR [open $op_run_do "w"]

  dump_header $IF_FPTR 
  dump_header $TOP_FPTR 
  dump_header $TEST_FPTR 

  az_gen_sv_intf $IF_FPTR $top_mod $clk_name $rst_name
  az_gen_fp_uvm_top_mod $TOP_FPTR $top_mod $op_if_fname $clk_name $rst_name 
  az_gen_fp_uvm_test $TEST_FPTR $top_mod $rst_name
  az_gen_fp_uvm_rvra_do $DO_FPTR $top_mod

  close $IF_FPTR
  close $TOP_FPTR
  close $TEST_FPTR
  close $DO_FPTR

  puts "Successfully generated FPUVM TB & Test for module: $top_mod "
  puts "See file: $op_if_fname for SystemVerilog Interface "
  puts "See file: $op_test_fname for FPUVM Test "
  puts "See file: $op_top_fname for FPUVM code"
  puts "Thanks for using FPUVM App "
  puts "Visit http://fp-uvm.blogspot.com for more "
}

proc az_get_dut_top {} {
  puts -nonewline "Enter top module (DUT) name: "
  flush stdout
  set dut_name [gets stdin]

  puts -nonewline "Enter clock signal name: "
  flush stdout
  set clk_name [gets stdin]

  puts -nonewline "Enter reset signal name: "
  flush stdout
  set rst_name [gets stdin]

  puts "Found: $dut_name"
  set ::az_gen_ns::az_dut_name $dut_name
  set ::az_gen_ns::az_clk_name $clk_name
  set ::az_gen_ns::az_rst_name $rst_name

}

