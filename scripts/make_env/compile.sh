# Abort on error returns
set -e
set -o pipefail

if [ "$#" -ge 1 ]; then
  echo $1
fi

echo "Compile is not here yet"
echo "RTL files:"
echo $rtl_files
echo "UVM files:"
echo $uvm_files
echo "UVM dirs:"
echo $uvm_dirs
