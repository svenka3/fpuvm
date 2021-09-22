/* 
* Copyright (c) 2004-2017 AumzDA, 
* http://www.fp-uvm.blogspot.com 
* 
* This program is part of FP-UVM at www.fp_uvm.blogspot.com
* Some portions of FP-UVM are free software.
* You can redistribute it under the terms of the 
* GNU Lesser General Public License as   
* published by the Free Software Foundation, version 3 and provided
* that this original copyright is retained intact
*
* AumzDA reserves the right to obfuscate part or full of the code
* at any point in time. You are not allowed to decrypt or reverse-engineer
* this code without explicit, written permission from the original authors
* 
* This program is distributed in the hope that it will be useful, but 
* WITHOUT ANY WARRANTY; without even the implied warranty of 
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
* Lesser General Lesser Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/


 // Protect against multiple inclusion of file
 //
`ifndef __FP_UVM_MACROS__
 `define __FP_UVM_MACROS__

`define fp_uvm_display(MSG,VERBOSITY=UVM_MEDIUM) \
   begin \
     if (uvm_report_enabled(VERBOSITY,UVM_INFO,get_name())) \
       uvm_report_info (get_name(), MSG, VERBOSITY, `uvm_file, `uvm_line); \
   end

`define fp_uvm_printf(FORMAT_MSG, VERBOSITY=UVM_MEDIUM) \
   begin \
     if (uvm_report_enabled(UVM_MEDIUM,UVM_INFO,get_name())) \
       uvm_report_info (get_name(), $sformatf FORMAT_MSG, VERBOSITY, `uvm_file, `uvm_line); \
   end


`define fp_uvm_error(MSG) \
   begin \
     if (uvm_report_enabled(UVM_NONE,UVM_ERROR,get_name())) \
       uvm_report_error (get_name(), MSG, UVM_NONE, `uvm_file, `uvm_line); \
   end

`define fp_uvm_warning(MSG) \
   begin \
     if (uvm_report_enabled(UVM_NONE,UVM_WARNING,get_name())) \
       uvm_report_warning (get_name(), MSG, UVM_NONE, `uvm_file, `uvm_line); \
   end

`define fp_uvm_fatal(MSG) \
   begin \
     if (uvm_report_enabled(UVM_NONE,UVM_FATAL,get_name())) \
       uvm_report_fatal (get_name(), MSG, UVM_NONE, `uvm_file, `uvm_line); \
   end

`define fp_uvm_rand(XN) \
   begin \
     if (!XN.randomize()) begin \
       uvm_report_warning ("RNDFLD",  $sformatf ("Failed to randmoize transaction: %s ", XN.sprint()), \
        UVM_NONE, `uvm_file, `uvm_line); \
     end \
   end



`define FP_UVM_TEST_BEGIN(TNAME) \
  class TNAME extends fp_uvm_base_test; \
  `uvm_component_utils_begin(TNAME) \
  `uvm_component_utils_end \
  function new(string name = "fp_uvm_test", uvm_component parent = null); \
    super.new(.name(name), .parent(parent)); \
  endfunction : new 


`define FP_UVM_TEST_END \
  endclass


    // Connect virtual interface to physical interface 
`define FP_UVM_SET_VIF(VIF, IF_INST) \
    uvm_config_db#(virtual VIF)::set(    \
     .cntxt(null), .inst_name("*"),               \
     .field_name("vif"), .value(IF_INST)); 

`define FP_UVM_OBJ_NEW \
  function new (string name=""); \
    super.new(name); \
  endfunction : new

`define FP_UVM_COMP_NEW \
  function new (string name="", uvm_component parent=null); \
    super.new(name, parent); \
  endfunction : new

  // Get a handle to the actual interface 
`define FP_UVM_GET_VIF(VIF) \
    if (!uvm_config_db#(virtual VIF)::get( \
      .cntxt(this), .inst_name(""), \
      .field_name("vif"), .value(vif))) begin : no_vif \
        `fp_uvm_fatal("Unable to connect virtual interface to physical interface, Make sure to use `FP_UVM_SET_VIF macro in top module") \
    end : no_vif \
    else begin : vif_connected \
      `fp_uvm_display("Successfully hooked up virtual interface") \
    end : vif_connected 


`define FP_UVM_MSET_VIF(VIF, IF_INST) \
    uvm_config_db#(virtual VIF)::set(    \
     .cntxt(null), .inst_name("*"),               \
     .field_name(`"IF_INST`"), .value(IF_INST)); 




`define FP_UVM_MGET_VIF(VIF, VIF_INST) \
    `fp_uvm_display ( \
       $sformatf("Looking for a virtual interface of type: %s name: %s", \
        `"VIF`", `"VIF_INST`")) \
    if (!uvm_config_db#(virtual VIF)::get( \
      .cntxt(this), .inst_name(""), \
      .field_name(`"VIF_INST`"), .value(VIF_INST))) begin \
        `fp_uvm_fatal("Unable to connect virtual interface to physical interface, Make sure to use `FP_UVM_SET_VIF macro in top module") \
    end  \
    else begin \
      `fp_uvm_display("Successfully hooked up virtual interface") \
    end 


`define FP_UVM_TURN_ABV_OFF(abv) \
    begin \
      static string abv_name = "ABV"; \
      `uvm_warning("ASSERTIONS",  \
        $sformatf("Turning off %s after first failure", abv_name)) \
      $assertoff (1, abv);  \
   end



`define FP_UVM_DISP_ARG(arg) `"arg`"

`define FP_UVM_WAIT(END_SIG, WDOG_VAL = FP_UVM_WDOG_DEL_IN_NS) \
  fork \
  begin \
  string msg; \
  wait (END_SIG); \
  msg = $sformatf ("Wait seen in condition: %s ", `FP_UVM_DISP_ARG(END_SIG) ); \
  `fp_uvm_display (msg); \
  end \
  begin \
  string msg; \
  #(WDOG_VAL * 1ns); \
  msg = $sformatf ("WDOG expired after waiting for: %0d %s %s", WDOG_VAL, "ns Wait condition: ", `FP_UVM_DISP_ARG(END_SIG) ); \
  `fp_uvm_error (msg); \
  end \
  join_any \
  disable fork; 


`define FP_UVM_WAIT_EV(EV_SPEC, WDOG_VAL = FP_UVM_WDOG_DEL_IN_NS) \
  fork \
  begin \
  string msg; \
  @ (EV_SPEC); \
  msg = $sformatf ("Wait seen in condition: @(%s) ", `FP_UVM_DISP_ARG(EV_SPEC) ); \
  `fp_uvm_display (msg); \
  end \
  begin \
  string msg; \
  #(WDOG_VAL * 1ns); \
  msg = $sformatf ("WDOG expired after waiting for: %0d %s @(%s)", WDOG_VAL, "ns Wait condition: ", `FP_UVM_DISP_ARG(EV_SPEC) ); \
  `fp_uvm_error (msg); \
  end \
  join_any \
  disable fork; 




`define FP_UVM_REG_DISPLAY(fp_uvm_reg) \
    begin \
      uvm_reg_data_t mirr_val, des_val; \
      mirr_val = fp_uvm_reg.get_mirrored_value(); \
      des_val = fp_uvm_reg.get(); \
      `fp_uvm_display($sformatf("%s: Mirrored_value: 0x%0x desired_value: 0x%0x", \
                 fp_uvm_reg.get_name(), mirr_val, des_val)) \
   end

`define FP_UVM_CAST(dst, src) \
  begin \
    bit ret_val; \
    ret_val = $cast (dst, src); \
    if (!ret_val) \
      `uvm_error ("FP_UVM_CAST", "Unable to $cast dst to src, check datatype compatibility") \
  end

 `define FP_UVM_VPL_INT(ARG_NAME) \
   begin \
     string fmt_str, str; \
     str = `FP_UVM_DISP_ARG (ARG_NAME); \
     fmt_str = {str, "=%0d"}; \
     void '($value$plusargs (fmt_str, ARG_NAME) ); \
     plus_args_in_code.push_back (str); \
     cov_clp_arg : cover (ARG_NAME); \
   end

`define FP_UVM_VPL_STR(ARG_NAME) \
   begin \
     string fmt_str, str; \
     str = `FP_UVM_DISP_ARG (ARG_NAME); \
     fmt_str = {str, "=%0s"}; \
     void '($value$plusargs (fmt_str, ARG_NAME) ); \
     plus_args_in_code.push_back (str); \
   end



`endif // __FP_UVM_MACROS__

