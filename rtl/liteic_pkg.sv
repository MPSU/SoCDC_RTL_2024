
package liteic_pkg;

    localparam            AXI_ADDR_WIDTH       = 32;
    localparam            AXI_DATA_WIDTH       = 32;
    localparam            AXI_RESP_WIDTH       = 2;
        // Determine AXI write strobe width
    localparam            AXI_STRB_WIDTH       = (AXI_DATA_WIDTH + 7) / 8; // equals to ceil(AXI_DATA_WIDTH / 8)
    
    // Define IC's internal AXI channels width
    localparam            IC_ARADDR_WIDTH      = AXI_ADDR_WIDTH;
    localparam            IC_RDATA_WIDTH       = AXI_DATA_WIDTH + AXI_RESP_WIDTH;
    localparam            IC_AWADDR_WIDTH      = AXI_ADDR_WIDTH;
    localparam            IC_WDATA_WIDTH       = AXI_DATA_WIDTH + AXI_STRB_WIDTH;
    localparam            IC_BRESP_WIDTH       = AXI_RESP_WIDTH;

    localparam            IC_NUM_MASTER_SLOTS  = 20;
    localparam            IC_NUM_SLAVE_SLOTS   = 12;
    localparam            IC_INVALID_ADDR_RESP = AXI_RESP_WIDTH'('b1);

    localparam bit [ IC_NUM_SLAVE_SLOTS-1 : 0 ]  IC_RD_CONNECTIVITY         [ IC_NUM_MASTER_SLOTS ] = '{ default: '1};
    localparam bit [ IC_NUM_SLAVE_SLOTS-1 : 0 ]  IC_WR_CONNECTIVITY         [ IC_NUM_MASTER_SLOTS ] = '{ default: '1};
    // Regions parameters of address in interconnect
    localparam bit [ AXI_ADDR_WIDTH-1 : 0 ]      IC_SLAVE_REGION_BASE       [ IC_NUM_SLAVE_SLOTS  ] = '{ 
        32'h000000, 32'h100000, 32'h200000, 32'h300000, 32'h400000, 32'h500000,
        32'h600000, 32'h700000, 32'h800000, 32'h900000, 32'hA00000, 32'hB00000
    };
    localparam bit [ AXI_ADDR_WIDTH-1 : 0 ]      IC_SLAVE_REGION_SIZE       [ IC_NUM_SLAVE_SLOTS  ] = '{ 
        32'h100000, 32'h100000, 32'h100000, 32'h100000, 32'h100000, 32'h100000,
        32'h100000, 32'h100000, 32'h100000, 32'h100000, 32'h100000, 32'h100000
    };

endpackage
