// (c) AumzDA, LLC
// All rights reserved.
//

#include <string>
#include <string.h>
#include "vhpi_user.h"


// architecture "execution" callback
PLI_VOID azTranslateVhdlPkg_to_Sv(const vhpiCbDataT *)
{
  // get the handle to root
  vhpiHandleT iPkgInst = vhpi_iterator(vhpiPackInsts, NULL);
  vhpiHandleT hPkgContents;
  vhpiHandleT iPkgStmt;
  vhpiHandleT hPkgStmt;
  vhpiHandleT hCnstType;
  const char *azPkgNameVhdl;
  char azPkgNameSv [100];
  char azPkgFileNameSv [100];
  const char *cnstName;
  const char *cnstTypeName;
  vhpiValueT value;
  FILE *azSvPkgFptr;

  if (iPkgInst) {
    vhpi_printf ("Found Pkg \n");
    while (hPkgContents = vhpi_scan (iPkgInst)) {
      // vhpi_printf ("Inside Pkg %s\n", vhpi_get_str (vhpiFullNameP, hPkgContents));

      azPkgNameVhdl = vhpi_get_str (vhpiNameP, hPkgContents);

      if ( (0 == strncmp(azPkgNameVhdl, "standard", sizeof("standard") - 1) ) ||
           (0 == strncmp(azPkgNameVhdl, "textio", sizeof("textio") - 1)   ) ||
           (0 == strncmp(azPkgNameVhdl, "TEXTIO", sizeof("TEXTIO") - 1)   ) ||
           (0 == strncmp(azPkgNameVhdl, "fpuvm_apps_pkg", sizeof("fpuvm_apps_pkg") - 1)   ) ||
           (0 == strncmp(azPkgNameVhdl, "std_logic_1164", sizeof("std_logic_1164") - 1)   ) ||
           (0 == strncmp(azPkgNameVhdl, "ieee", sizeof("ieee") - 1)    ) ) {
        
      } 
      else {

        vhpi_printf ("Inside USER Pkg %s\n", vhpi_get_str (vhpiFullNameP, hPkgContents));
        strcpy (azPkgNameSv, "sv_");
        strcat (azPkgNameSv, azPkgNameVhdl);

        strcpy (azPkgFileNameSv, azPkgNameSv);
        strcat (azPkgFileNameSv, ".sv");
        vhpi_printf ("Creating SystemVerilog USER Pkg %s\n", azPkgNameSv);

        azSvPkgFptr = fopen(azPkgFileNameSv,"w");
        fprintf (azSvPkgFptr, "// FP-UVM - UVM for FPGAs app \n");
        fprintf (azSvPkgFptr, "// Automatically generated from VHDL Package: %s \n",
            azPkgNameVhdl);
        fprintf (azSvPkgFptr, "package %s; \n",
            azPkgNameSv);

        iPkgStmt = vhpi_iterator (vhpiConstDecls, hPkgContents);
        if (iPkgStmt) {
          // vhpi_printf ("Constant Decl \n");
          while (hPkgStmt = vhpi_scan (iPkgStmt)) {
            cnstName = vhpi_get_str (vhpiNameP, hPkgStmt);
            value.format = vhpiIntVal;
            cnstTypeName = vhpi_get_str (vhpiKindStrP, hPkgStmt);
            vhpi_get_value (hPkgStmt, &value);

            fprintf (azSvPkgFptr, "  parameter %s = %d;\n",
                cnstName, value.value.intg);
          }
        }

        iPkgStmt = vhpi_iterator (vhpiTypes, hPkgContents);
        if (iPkgStmt) {
          vhpi_printf ("Type Decl \n");
          while (hPkgStmt = vhpi_scan (iPkgStmt)) {
            cnstName = vhpi_get_str (vhpiNameP, hPkgStmt);
            value.format = vhpiIntVal;
            cnstTypeName = vhpi_get_str (vhpiKindStrP, hPkgStmt);
            vhpi_get_value (hPkgStmt, &value);
            vhpi_printf ("Found RECORD: %s %d\n",
                cnstName, value.value.intg);
          }
        }

        fprintf (azSvPkgFptr, "endpackage : %s \n\n",
            azPkgNameSv);
        fprintf (azSvPkgFptr, "import %s::* \n\n",
            azPkgNameSv);
        fclose (azSvPkgFptr);
      }
    }

    vhpi_printf ("\n\n********************************************************************************\n\n");
    vhpi_printf ("Thanks for using FP-UVM VHDL-2-SystemVerilog Package translator app \n");
    vhpi_printf ("Converted VHDL package named: %s to SV package named: %s \n",
        azPkgNameVhdl, azPkgNameSv);
    vhpi_printf ("Include the below SystemVerilog package file in your project/file-list \n to build on UVM testbench for VHDL \n\t\"%s\"\n",
        azPkgFileNameSv);
    vhpi_printf ("\n\n********************************************************************************\n\n");
  } else {
    vhpi_printf ("Unable to find Pkg \n");
  }

}



// registration function
/*
PLI_VOID azRegisterPkgGenApp_vhpi()
{
  vhpiForeignDataT azVhpiForeignData;
  azVhpiForeignData.kind = vhpiArchFK;
  azVhpiForeignData.libraryName = "vhpi";
  azVhpiForeignData.modelName = "az_fp_uvm_vhdl_sv_pkg_app";
  azVhpiForeignData.elabf = 0;
  azVhpiForeignData.execf = azTranslateVhdlPkg_to_Sv;
  vhpi_register_foreignf(&azVhpiForeignData);
}
*/

// registration function
PLI_VOID azRegisterPkgGenApp_vhpi_fn()
{
  vhpiForeignDataT azVhpiForeignData;
  azVhpiForeignData.kind = vhpiFuncF;
  azVhpiForeignData.libraryName = "vhpi";
  azVhpiForeignData.modelName = "az_fpuvm_vhdl_to_sv_pkg_app";
  azVhpiForeignData.elabf = 0;
  azVhpiForeignData.execf = azTranslateVhdlPkg_to_Sv;
  vhpi_register_foreignf(&azVhpiForeignData);
}

// pre-defined VHPI registration table
PLI_VOID(*vhpi_startup_routines[])() =
{
  // azRegisterPkgGenApp_vhpi, 
  azRegisterPkgGenApp_vhpi_fn,
  0
};


