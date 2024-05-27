
module liteic_addr_decoder
#(
    parameter                          ADDR_WIDTH  = 16,
    parameter                          NUM_REGIONS = 1,
    parameter bit [ ADDR_WIDTH-1 : 0 ] REGION_BASE [ NUM_REGIONS ] = '{ default: '0 },
    parameter bit [ ADDR_WIDTH-1 : 0 ] REGION_SIZE [ NUM_REGIONS ] = '{ default: 1 }
)(
    input  logic [ ADDR_WIDTH-1  : 0 ] addr_i,         // address to decode
    output logic [ NUM_REGIONS-1 : 0 ] rgn_select_o,   // region select
    output logic                       illegal_addr_o  // illegal address flag
);

for (genvar gi = 0; gi < NUM_REGIONS; gi++) begin : addr_region_range
    assign rgn_select_o[gi] = ( addr_i >=  REGION_BASE[gi]                    ) &&
                              ( addr_i <  (REGION_BASE[gi] + REGION_SIZE[gi]) );
end

assign illegal_addr_o = ~|( rgn_select_o );

endmodule