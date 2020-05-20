////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

package vip_file_functions_pkg;

  // This function returns the path to this repository's root
  function string vip_get_git_root();

    int ret;
    int mcd;

    ret = $system("git rev-parse --show-toplevel > git_root.sv"); // $system is not supported by Vivado 2019.2
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
