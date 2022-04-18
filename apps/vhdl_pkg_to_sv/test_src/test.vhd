-- (c) AumzDA, LLC
-- All rights reserved.
--

library ieee;
use ieee.std_logic_1164.all;

package t_pkg is
  constant ADDR_W : integer := 16;
  constant DATA_W : integer := 32;
  type a_r is record
    wdata : std_logic_vector (DATA_W downto 0);
  end record a_r;

end package t_pkg;


library ieee;
use ieee.std_logic_1164.all;

use work.t_pkg.all;
library fpuvm_lib;
use fpuvm_lib.fpuvm_apps_pkg.all;

entity test is
end entity test;

architecture testcase of test is
begin
  process
  begin
    to_sv_pkg;
    wait;
  end process;

 -- u_az_fp_uvm_vhdl_2_sv : entity work.az_fp_uvm_vhdl_2_sv;

end architecture testcase;
