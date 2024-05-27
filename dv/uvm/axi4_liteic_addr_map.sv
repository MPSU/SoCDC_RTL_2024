//---------------------------------------------------------
// Typedef: axi4_liteic_addr_map_entry_s
//---------------------------------------------------------
    
// AXI4 LiteIC address map entry
// Address map is collection of this entries

typedef struct {
    addr_map_pkg::addr_t addr;
    bit [64:0]           size;
} axi4_liteic_addr_map_entry_s;


//---------------------------------------------------------
// Typedef: axi4_liteic_addr_map
//---------------------------------------------------------
    
// AXI4 LiteIC address map

typedef axi4_liteic_addr_map_entry_s axi4_liteic_addr_map_t [];


//---------------------------------------------------------
// Field: axi4_liteic_slave_addr_map
//---------------------------------------------------------

// AXI4 LiteIC slave address map

parameter axi4_liteic_addr_map_t axi4_liteic_slave_addr_map = '{
    '{64'h000000, 64'h100000}, // {<base_address>, <size>}
    '{64'h100000, 64'h100000},
    '{64'h200000, 64'h100000},
    '{64'h300000, 64'h100000},
    '{64'h400000, 64'h100000},
    '{64'h500000, 64'h100000},
    '{64'h600000, 64'h100000},
    '{64'h700000, 64'h100000},
    '{64'h800000, 64'h100000},
    '{64'h900000, 64'h100000},
    '{64'hA00000, 64'h100000},
    '{64'hB00000, 64'h100000}
};


//---------------------------------------------------------
// Function: convert_addr_map
//---------------------------------------------------------
    
// Converts AXI4 LiteIC address map to the AXI4 VIP address map

function automatic addr_map_t convert_addr_map(
    axi4_liteic_addr_map_t liteic_addr_map
);

    // Define address map entry and address map
    addr_map_entry_s entry;
    addr_map_t       addr_map;

    // Create address map
    addr_map = addr_map_t::type_id::create("addr_map");

    // Set address mask (for AXI4 it is 4kB)
    addr_map.addr_mask = 'h0FFF;

    // For each LiteIC address map entry create
    // AXI4 VIP address map entry
    foreach(liteic_addr_map[i]) begin
        entry = {
            kind  : MAP_NORMAL,
            name  : "axi4_liteic_addr_map",
            id    : 0,
            domain: MAP_NS,
            region: 0,
            addr  : liteic_addr_map[i].addr,
            size  : liteic_addr_map[i].size,
            mem   : MEM_DEVICE
            // No 'prot', because no protection support
            // MAP_PROT_ATTR define is not passed to testbench
        };
        addr_map.add(entry);
    end

    // Return AXI4 VIP address map
    return addr_map;

endfunction