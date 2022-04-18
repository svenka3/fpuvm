-- (c) AumzDA, LLC
-- All rights reserved.
--
package fpuvm_apps_pkg is
	procedure to_sv_pkg ;
  attribute foreign of to_sv_pkg : procedure is "VHPI libaz_fpuvm_app; az_fpuvm_vhdl_to_sv_pkg_app";
end package fpuvm_apps_pkg;

package body fpuvm_apps_pkg is
	procedure to_sv_pkg  is
	begin report "to_sv_pkg VHPI" severity failure; end;
end package body fpuvm_apps_pkg;

