package vip_file_functions_pkg;

  // This function returns the path to this repository's root
  function string get_git_root();

    int ret;
    int mcd;

    ret = $system("git rev-parse --show-toplevel > git_root.sv");
    mcd = $fopen("git_root.sv", "r");

    if (!mcd) begin
      $display("get_git_root()", $sformatf("File was NOT opened successfully: %s", "git_root.sv"));
      $stop();
    end

    void'($fscanf(mcd, "%s", get_git_root));

    ret = $system("rm git_root.sv");

  endfunction


  // This function will load any data from a file to file_buffer
  function automatic read_file_to_buffer(string file_name, ref string file_buffer [$]);

    // Multi-channel descriptor pointer to the file
    automatic int mcd = $fopen(file_name, "r");
    string line;

    file_buffer.delete();

    if (!mcd) begin
      $display("read_file_to_buffer()", $sformatf("File was NOT opened successfully: %s", file_name));
      $stop();
    end

    $display("read_file_to_buffer()", $sformatf("Reading file: (%s)", file_name));

    while (!$feof(mcd)) begin
      void'($fscanf(mcd, "%s\n", line));
      file_buffer.push_back(line);
    end

    $fclose(mcd);

  endfunction

endpackage
