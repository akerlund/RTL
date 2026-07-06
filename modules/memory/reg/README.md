# Register Memory

FuseSoC core: `akerlund::memory_reg:0`

`reg_sp_rf` is a single-write-port, single-read-port register file with
asynchronous read and synchronous write. Reads reflect the addressed storage
directly; a same-address read/write in one clock cycle presents simulator and
technology dependent behavior during the write edge, so users should avoid
depending on a specific collision value unless their synthesis target defines
one.

Memory contents are intentionally uninitialized after configuration or reset.
`DATA_WIDTH_P` and `ADDR_WIDTH_P` must be greater than zero.
