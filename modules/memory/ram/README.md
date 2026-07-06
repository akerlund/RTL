# RAM Primitives

FuseSoC core: `akerlund::memory_ram:0`

This core contains synchronous RAM primitives:

| Module | Behavior |
| --- | --- |
| `ram_sp` | Single-port read-first RAM. When read and write use the same address in one enabled cycle, the old word is presented and the new word is stored. |
| `ram_sp_bw` | Byte-write version of `ram_sp`; `enable` gates both read and write. |
| `ram_sdp` | Simple dual-port RAM with a write port and a read port. Same-address read/write behavior follows the target memory primitive and should not be relied on without external avoidance. |
| `ram_sdp_bw` | Byte-write version of `ram_sdp`. |
| `ram_sdp2c` | Dual-clock simple dual-port RAM. Simulation drives X on a same-address read/write collision to make CDC collisions visible. |
| `ram_tdp` | True dual-port read-first RAM. Simulation drives X on same-address write/write collisions. |
| `ram_tdp_bw` | Byte-write version of `ram_tdp`. |

All width parameters must be greater than zero. Memory contents are not reset or
initialized by these primitives.
