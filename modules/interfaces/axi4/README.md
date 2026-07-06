# AXI4 Interface

FuseSoC core: `akerlund::axi4_if:0`

`axi4_if` is a reduced AXI4 interface used by the local AXI modules and VIP. It
keeps ID, address, length, size, burst, data, strobe, response, valid, ready,
and last signals. It intentionally omits lock, cache, protection, QoS, region,
and user sideband signals.

The interface provides `master`, `slave`, and `monitor` modports. Width
parameters must be greater than zero, and `DATA_WIDTH_P` must be byte-aligned.
