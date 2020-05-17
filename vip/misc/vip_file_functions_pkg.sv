////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

package vip_file_functions_pkg;

  // This function returns the path to this repository's root
  function string vip_get_git_root();

    int ret;
    int mcd;

    ret = $system("git rev-parse --show-toplevel > git_root.sv");
    mcd = $fopen("git_root.sv", "r");

    if (!mcd) begin
      $display("vip_get_git_root()", $sformatf("File was NOT opened successfully: %s", "git_root.sv"));
      $stop();
    end

    void'($fscanf(mcd, "%s", vip_get_git_root));

    ret = $system("rm git_root.sv");

  endfunction


  // This function will load any data from a file to file_buffer
  function automatic vip_read_file_to_buffer(string file_name, ref string file_buffer [$]);

    // Multi-channel descriptor pointer to the file
    automatic int mcd = $fopen(file_name, "r");
    string line;

    file_buffer.delete();

    if (!mcd) begin
      $display("vip_read_file_to_buffer()", $sformatf("File was NOT opened successfully: %s", file_name));
      $stop();
    end

    $display("vip_read_file_to_buffer()", $sformatf("Reading file: (%s)", file_name));

    while (!$feof(mcd)) begin
      void'($fscanf(mcd, "%s\n", line));
      file_buffer.push_back(line);
    end

    $fclose(mcd);

  endfunction

endpackage
