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
`ifndef __FP_UVM_PKG__
 `define __FP_UVM_PKG__

import uvm_pkg::*;
`include "uvm_macros.svh"

package fp_uvm_pkg;
  import uvm_pkg::*;
  export uvm_pkg::*;
  `include "uvm_macros.svh"

  string log_id = "FP_UVM";
  parameter string FP_UVM_COPYRIGHT   = "(C) 2021 AumzDA http://www.fp-uvm.blogspot.com ";

  parameter FP_UVM_WDOG_DEL_IN_NS = 10000;


  function string get_name();
    return log_id;
  endfunction : get_name

  function void set_name(string s);
    log_id = s;
  endfunction : set_name
  
  virtual class fp_uvm_base_test extends uvm_test;
    `ifdef INCA
    timeunit 1ns;
    timeprecision 1ns;
    `endif // INCA
  
  
      extern function new (string name = "fp_uvm_test", 
                           uvm_component parent = null);
      extern virtual function void build_phase (uvm_phase phase);
      extern virtual function void end_of_elaboration_phase (uvm_phase phase);
      extern virtual task reset_phase (uvm_phase phase);
      extern virtual task reset ();
      extern virtual task main_phase (uvm_phase phase);
      pure virtual task main ();
      extern virtual function void report_header (UVM_FILE file = 0 );
  
  endclass : fp_uvm_base_test
  
  
  function fp_uvm_base_test::new (string name = "fp_uvm_test", 
                                  uvm_component parent = null);
  
        super.new (name, parent);
        $timeformat (-9, 2, " ns", 10);
  
      endfunction : new
  
  function void fp_uvm_base_test::build_phase (uvm_phase phase);
    super.build_phase (phase); 
  endfunction : build_phase 
  
  
  function void fp_uvm_base_test::end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase); 
      `ifdef SVA_2012
        $assertvacuousoff();
      `endif // SVA_2012
  endfunction : end_of_elaboration_phase 
  
  task fp_uvm_base_test::reset_phase (uvm_phase phase);
      phase.raise_objection (this);
      this.reset();
      phase.drop_objection (this);
  endtask : reset_phase 
  
  task fp_uvm_base_test::reset ();
      `uvm_warning (get_name(), "No implementation found for reset method. It is recommended to add reset driving logic to the extended class task reset; See user guide or http://www.fp-uvm.blogspot.com for more information")
  endtask : reset
  
  task fp_uvm_base_test::main_phase (uvm_phase phase);
      phase.raise_objection (this);
      `uvm_info (get_name(), "Driving stimulus via UVM", UVM_MEDIUM)
      this.main ();
      `uvm_info (get_name(), "End of stimulus", UVM_MEDIUM)
      phase.drop_objection (this);
  endtask : main_phase
  
  
    // More ideas/thoughts
    // Can we print failed assertions (once per assertion)
    //    coverage information
    //   Any assertoff control
  
  function void fp_uvm_base_test::report_header (UVM_FILE file = 0 );
    string az_rel_str;
  
    az_rel_str = $sformatf("\n----------------------------------------------------------------\n");
    az_rel_str = $sformatf({az_rel_str, 
                      "\n  ***********       IMPORTANT RELEASE NOTES         ************\n"});
    az_rel_str = $sformatf({az_rel_str, 
        "\n  You are using a version of the FP-UVM Package from AumzDA \n"});
    az_rel_str = $sformatf({az_rel_str, "  See http://www.fp-uvm.blogspot.com for more details \n"});
    az_rel_str = $sformatf({az_rel_str, "\n----------------------------------------------------------------\n"});
  
  
    `uvm_info(get_name(), $sformatf("RELNOTES \n%s", az_rel_str), UVM_NONE)
  
  endfunction : report_header 


endpackage : fp_uvm_pkg

`endif // __FP_UVM_PKG__
import fp_uvm_pkg::*;
