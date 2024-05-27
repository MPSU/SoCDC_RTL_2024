//---------------------------------------------------------
// Module: tb_liteic_top
//---------------------------------------------------------

// Main LiteIc AXI4 testbench module

module tb_liteic_top;


    //---------------------------------------------------------
    // Imports
    //---------------------------------------------------------

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import axi4_liteic_dv_pkg::*;


    //---------------------------------------------------------
    // Signals: Clock and reset
    //---------------------------------------------------------

    logic ACLK;
    logic ARESETn;


    //---------------------------------------------------------
    // Routine: Clock and reset generation
    //---------------------------------------------------------

    initial begin
        ACLK <= 0;
        forever begin
            #(CLK_PERIOD/2) ACLK <= ~ACLK;
        end
    end

    initial begin
        ARESETn <= 0;
        // WARNING: Long reset here is used to overcome
        // issues with Xilinx registers models. Models
        // must be driven with active reset quite a long
        // time to work properly.
        #(10000*CLK_PERIOD);
        @(negedge ACLK);
        ARESETn <= 1;
    end


    //---------------------------------------------------------
    // Signals: AXI4
    //---------------------------------------------------------

    // Masters
    
    wire                                           M_AWVALID [MASTERS_AMOUNT];
    wire [  axi4_liteic_dv_pkg::ADDR_WIDTH - 1:0]  M_AWADDR  [MASTERS_AMOUNT];
    wire [                                   3:0]  M_AWQOS   [MASTERS_AMOUNT];
    wire                                           M_AWREADY [MASTERS_AMOUNT];
   
    wire                                           M_ARVALID [MASTERS_AMOUNT];
    wire [  axi4_liteic_dv_pkg::ADDR_WIDTH - 1:0]  M_ARADDR  [MASTERS_AMOUNT];
    wire [                                   3:0]  M_ARQOS   [MASTERS_AMOUNT];
    wire                                           M_ARREADY [MASTERS_AMOUNT];
  
    wire                                           M_RVALID  [MASTERS_AMOUNT];
    wire [  axi4_liteic_dv_pkg::DATA_WIDTH - 1:0]  M_RDATA   [MASTERS_AMOUNT];
    wire [                                   1:0]  M_RRESP   [MASTERS_AMOUNT];
    wire                                           M_RREADY  [MASTERS_AMOUNT];
  
    wire                                           M_WVALID  [MASTERS_AMOUNT];
    wire [axi4_liteic_dv_pkg::DATA_WIDTH   - 1:0]  M_WDATA   [MASTERS_AMOUNT];
    wire [axi4_liteic_dv_pkg::DATA_WIDTH/8 - 1:0]  M_WSTRB   [MASTERS_AMOUNT];
    wire                                           M_WREADY  [MASTERS_AMOUNT];
  
    wire                                           M_BVALID  [MASTERS_AMOUNT];
    wire [                                   1:0]  M_BRESP   [MASTERS_AMOUNT];
    wire                                           M_BREADY  [MASTERS_AMOUNT];

    // Slaves

    wire                                           S_AWVALID [SLAVES_AMOUNT];
    wire [  axi4_liteic_dv_pkg::ADDR_WIDTH - 1:0]  S_AWADDR  [SLAVES_AMOUNT];
    wire                                           S_AWREADY [SLAVES_AMOUNT];
   
    wire                                           S_ARVALID [SLAVES_AMOUNT];
    wire [  axi4_liteic_dv_pkg::ADDR_WIDTH - 1:0]  S_ARADDR  [SLAVES_AMOUNT];
    wire                                           S_ARREADY [SLAVES_AMOUNT];
  
    wire                                           S_RVALID  [SLAVES_AMOUNT];
    wire [  axi4_liteic_dv_pkg::DATA_WIDTH - 1:0]  S_RDATA   [SLAVES_AMOUNT];
    wire [                                   1:0]  S_RRESP   [SLAVES_AMOUNT];
    wire                                           S_RREADY  [SLAVES_AMOUNT];
  
    wire                                           S_WVALID  [SLAVES_AMOUNT];
    wire [axi4_liteic_dv_pkg::DATA_WIDTH   - 1:0]  S_WDATA   [SLAVES_AMOUNT];
    wire [axi4_liteic_dv_pkg::DATA_WIDTH/8 - 1:0]  S_WSTRB   [SLAVES_AMOUNT];
    wire                                           S_WREADY  [SLAVES_AMOUNT];
  
    wire                                           S_BVALID  [SLAVES_AMOUNT];
    wire [                                   1:0]  S_BRESP   [SLAVES_AMOUNT];
    wire                                           S_BREADY  [SLAVES_AMOUNT];


    //---------------------------------------------------------
    // Interfaces: DUT
    //---------------------------------------------------------
    
    // AXI4 Lite

    axi_lite_if mst_axil [ MASTERS_AMOUNT ] ();
    axi_lite_if slv_axil [ SLAVES_AMOUNT  ] ();

    // Priority (write + read)

    axi4_liteic_priority_if #(PRIORITY_WIDTH) w_priority_if [MASTERS_AMOUNT] ();
    axi4_liteic_priority_if #(PRIORITY_WIDTH) r_priority_if [MASTERS_AMOUNT] ();


    //---------------------------------------------------------
    // Instances: master
    //---------------------------------------------------------
    
    // AXI4 Masters VIP for DV

    generate

        genvar m_cnt;
        for(m_cnt = 0; m_cnt < MASTERS_AMOUNT; m_cnt = m_cnt + 1) begin

            localparam string INTF_NAME = $sformatf("AXI4_MASTER_IF_%0d", m_cnt);

            axi4_master #(
                .ADDR_WIDTH      ( axi4_liteic_dv_pkg::ADDR_WIDTH      ),
                .RDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ),
                .WDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ),
                .ID_WIDTH        ( axi4_liteic_dv_pkg::ID_WIDTH        ),
                .USER_WIDTH      ( axi4_liteic_dv_pkg::USER_WIDTH      ),
                .REGION_MAP_SIZE ( axi4_liteic_dv_pkg::REGION_MAP_SIZE ),
                .IF_NAME         (                     INTF_NAME       ) 
            ) master (
                .ACLK            ( ACLK                                ),
                .ARESETn         ( ARESETn                             ),
                .AWVALID         ( M_AWVALID  [m_cnt]                  ),
                .AWADDR          ( M_AWADDR   [m_cnt]                  ),
                .AWREADY         ( M_AWREADY  [m_cnt]                  ),
                .ARVALID         ( M_ARVALID  [m_cnt]                  ),
                .ARADDR          ( M_ARADDR   [m_cnt]                  ),
                .ARREADY         ( M_ARREADY  [m_cnt]                  ),
                .RVALID          ( M_RVALID   [m_cnt]                  ),
                .RDATA           ( M_RDATA    [m_cnt]                  ),
                .RRESP           ( M_RRESP    [m_cnt]                  ),
                .RREADY          ( M_RREADY   [m_cnt]                  ),
                .WVALID          ( M_WVALID   [m_cnt]                  ),
                .WDATA           ( M_WDATA    [m_cnt]                  ),
                .WSTRB           ( M_WSTRB    [m_cnt]                  ),
                .WREADY          ( M_WREADY   [m_cnt]                  ),
                .BVALID          ( M_BVALID   [m_cnt]                  ),
                .BRESP           ( M_BRESP    [m_cnt]                  ),
                .BREADY          ( M_BREADY   [m_cnt]                  )
            );

            // Assign AWQOS signals to priority interfaces signal
            assign M_AWQOS[m_cnt] = w_priority_if[m_cnt].prior;
            assign M_ARQOS[m_cnt] = r_priority_if[m_cnt].prior;

            // Pass priority interfaces to the resource database
            initial begin
                uvm_resource_db #( axi4_liteic_priority_vif )::
                    set("*", $sformatf("w_priority_vif[%0d]", m_cnt),
                        w_priority_if[m_cnt], null);
                uvm_resource_db #( axi4_liteic_priority_vif )::
                    set("*", $sformatf("r_priority_vif[%0d]", m_cnt),
                        r_priority_if[m_cnt], null);
            end

        end

    endgenerate


    //---------------------------------------------------------
    // Instance: slaves
    //---------------------------------------------------------
    
    // AXI4 Slaves VIP for DV

    generate

        genvar s_cnt;
        for(s_cnt = 0; s_cnt < SLAVES_AMOUNT; s_cnt = s_cnt + 1) begin

            localparam string INTF_NAME = $sformatf("AXI4_SLAVE_IF_%0d", s_cnt);

            axi4_slave #(
                .ADDR_WIDTH      ( axi4_liteic_dv_pkg::ADDR_WIDTH      ),
                .RDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ),
                .WDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ),
                .ID_WIDTH        ( axi4_liteic_dv_pkg::ID_WIDTH        ),
                .USER_WIDTH      ( axi4_liteic_dv_pkg::USER_WIDTH      ),
                .REGION_MAP_SIZE ( axi4_liteic_dv_pkg::REGION_MAP_SIZE ),
                .IF_NAME         (                     INTF_NAME       ) 
            ) slave (
                .ACLK            ( ACLK                                ),
                .ARESETn         ( ARESETn                             ),
                .AWVALID         ( S_AWVALID  [s_cnt]                  ),
                .AWADDR          ( S_AWADDR   [s_cnt]                  ),
                .AWREADY         ( S_AWREADY  [s_cnt]                  ),
                .ARVALID         ( S_ARVALID  [s_cnt]                  ),
                .ARADDR          ( S_ARADDR   [s_cnt]                  ),
                .ARREADY         ( S_ARREADY  [s_cnt]                  ),
                .RVALID          ( S_RVALID   [s_cnt]                  ),
                .RDATA           ( S_RDATA    [s_cnt]                  ),
                .RRESP           ( S_RRESP    [s_cnt]                  ),
                .RREADY          ( S_RREADY   [s_cnt]                  ),
                .WVALID          ( S_WVALID   [s_cnt]                  ),
                .WDATA           ( S_WDATA    [s_cnt]                  ),
                .WSTRB           ( S_WSTRB    [s_cnt]                  ),
                .WREADY          ( S_WREADY   [s_cnt]                  ),
                .BVALID          ( S_BVALID   [s_cnt]                  ),
                .BRESP           ( S_BRESP    [s_cnt]                  ),
                .BREADY          ( S_BREADY   [s_cnt]                  )
            );

        end

    endgenerate


    //---------------------------------------------------------
    // Define: CONNECT_*
    //---------------------------------------------------------
    
    // This defines are used to connect netlist to the VIP

    `define CONNECT_MASTER(M_IDX) \
       .\M_ARADDR[``M_IDX``] ( M_ARADDR [``M_IDX``] ), \
        .\M_ARQOS[``M_IDX``] ( M_ARQOS  [``M_IDX``] ), \
      .\M_ARVALID[``M_IDX``] ( M_ARVALID[``M_IDX``] ), \
       .\M_AWADDR[``M_IDX``] ( M_AWADDR [``M_IDX``] ), \
        .\M_AWQOS[``M_IDX``] ( M_AWQOS  [``M_IDX``] ), \
      .\M_AWVALID[``M_IDX``] ( M_AWVALID[``M_IDX``] ), \
        .\M_WDATA[``M_IDX``] ( M_WDATA  [``M_IDX``] ), \
        .\M_WSTRB[``M_IDX``] ( M_WSTRB  [``M_IDX``] ), \
       .\M_WVALID[``M_IDX``] ( M_WVALID [``M_IDX``] ), \
       .\M_RREADY[``M_IDX``] ( M_RREADY [``M_IDX``] ), \
       .\M_BREADY[``M_IDX``] ( M_BREADY [``M_IDX``] ), \
      .\M_ARREADY[``M_IDX``] ( M_ARREADY[``M_IDX``] ), \
        .\M_RDATA[``M_IDX``] ( M_RDATA  [``M_IDX``] ), \
       .\M_RVALID[``M_IDX``] ( M_RVALID [``M_IDX``] ), \
        .\M_RRESP[``M_IDX``] ( M_RRESP  [``M_IDX``] ), \
      .\M_AWREADY[``M_IDX``] ( M_AWREADY[``M_IDX``] ), \
       .\M_WREADY[``M_IDX``] ( M_WREADY [``M_IDX``] ), \
       .\M_BVALID[``M_IDX``] ( M_BVALID [``M_IDX``] ), \
        .\M_BRESP[``M_IDX``] ( M_BRESP  [``M_IDX``] ),

    `define CONNECT_MASTER_END(M_IDX) \
       .\M_ARADDR[``M_IDX``] ( M_ARADDR [``M_IDX``] ), \
        .\M_ARQOS[``M_IDX``] ( M_ARQOS  [``M_IDX``] ), \
      .\M_ARVALID[``M_IDX``] ( M_ARVALID[``M_IDX``] ), \
       .\M_AWADDR[``M_IDX``] ( M_AWADDR [``M_IDX``] ), \
        .\M_AWQOS[``M_IDX``] ( M_AWQOS  [``M_IDX``] ), \
      .\M_AWVALID[``M_IDX``] ( M_AWVALID[``M_IDX``] ), \
        .\M_WDATA[``M_IDX``] ( M_WDATA  [``M_IDX``] ), \
        .\M_WSTRB[``M_IDX``] ( M_WSTRB  [``M_IDX``] ), \
       .\M_WVALID[``M_IDX``] ( M_WVALID [``M_IDX``] ), \
       .\M_RREADY[``M_IDX``] ( M_RREADY [``M_IDX``] ), \
       .\M_BREADY[``M_IDX``] ( M_BREADY [``M_IDX``] ), \
      .\M_ARREADY[``M_IDX``] ( M_ARREADY[``M_IDX``] ), \
        .\M_RDATA[``M_IDX``] ( M_RDATA  [``M_IDX``] ), \
       .\M_RVALID[``M_IDX``] ( M_RVALID [``M_IDX``] ), \
        .\M_RRESP[``M_IDX``] ( M_RRESP  [``M_IDX``] ), \
      .\M_AWREADY[``M_IDX``] ( M_AWREADY[``M_IDX``] ), \
       .\M_WREADY[``M_IDX``] ( M_WREADY [``M_IDX``] ), \
       .\M_BVALID[``M_IDX``] ( M_BVALID [``M_IDX``] ), \
        .\M_BRESP[``M_IDX``] ( M_BRESP  [``M_IDX``] ) 

    `define CONNECT_SLAVE(S_IDX) \
        .\S_ARREADY[``S_IDX``] ( S_ARREADY[``S_IDX``] ), \
          .\S_RDATA[``S_IDX``] ( S_RDATA  [``S_IDX``] ), \
         .\S_RVALID[``S_IDX``] ( S_RVALID [``S_IDX``] ), \
          .\S_RRESP[``S_IDX``] ( S_RRESP  [``S_IDX``] ), \
        .\S_AWREADY[``S_IDX``] ( S_AWREADY[``S_IDX``] ), \
         .\S_WREADY[``S_IDX``] ( S_WREADY [``S_IDX``] ), \
         .\S_BVALID[``S_IDX``] ( S_BVALID [``S_IDX``] ), \
          .\S_BRESP[``S_IDX``] ( S_BRESP  [``S_IDX``] ), \
         .\S_ARADDR[``S_IDX``] ( S_ARADDR [``S_IDX``] ), \
        .\S_ARVALID[``S_IDX``] ( S_ARVALID[``S_IDX``] ), \
         .\S_AWADDR[``S_IDX``] ( S_AWADDR [``S_IDX``] ), \
        .\S_AWVALID[``S_IDX``] ( S_AWVALID[``S_IDX``] ), \
          .\S_WDATA[``S_IDX``] ( S_WDATA  [``S_IDX``] ), \
          .\S_WSTRB[``S_IDX``] ( S_WSTRB  [``S_IDX``] ), \
         .\S_WVALID[``S_IDX``] ( S_WVALID [``S_IDX``] ), \
         .\S_RREADY[``S_IDX``] ( S_RREADY [``S_IDX``] ), \
         .\S_BREADY[``S_IDX``] ( S_BREADY [``S_IDX``] ),

    `define CONNECT_SLAVE_END(S_IDX) \
        .\S_ARREADY[``S_IDX``] ( S_ARREADY[``S_IDX``] ), \
          .\S_RDATA[``S_IDX``] ( S_RDATA  [``S_IDX``] ), \
         .\S_RVALID[``S_IDX``] ( S_RVALID [``S_IDX``] ), \
          .\S_RRESP[``S_IDX``] ( S_RRESP  [``S_IDX``] ), \
        .\S_AWREADY[``S_IDX``] ( S_AWREADY[``S_IDX``] ), \
         .\S_WREADY[``S_IDX``] ( S_WREADY [``S_IDX``] ), \
         .\S_BVALID[``S_IDX``] ( S_BVALID [``S_IDX``] ), \
          .\S_BRESP[``S_IDX``] ( S_BRESP  [``S_IDX``] ), \
         .\S_ARADDR[``S_IDX``] ( S_ARADDR [``S_IDX``] ), \
        .\S_ARVALID[``S_IDX``] ( S_ARVALID[``S_IDX``] ), \
         .\S_AWADDR[``S_IDX``] ( S_AWADDR [``S_IDX``] ), \
        .\S_AWVALID[``S_IDX``] ( S_AWVALID[``S_IDX``] ), \
          .\S_WDATA[``S_IDX``] ( S_WDATA  [``S_IDX``] ), \
          .\S_WSTRB[``S_IDX``] ( S_WSTRB  [``S_IDX``] ), \
         .\S_WVALID[``S_IDX``] ( S_WVALID [``S_IDX``] ), \
         .\S_RREADY[``S_IDX``] ( S_RREADY [``S_IDX``] ), \
         .\S_BREADY[``S_IDX``] ( S_BREADY [``S_IDX``] )


    //---------------------------------------------------------
    // Instance: DUT
    //---------------------------------------------------------
    
    // LiteIc AXI4 instance for DV

    liteic_icon_top DUT (
        .clk_i    ( ACLK     ),
        .rstn_i   ( ARESETn  ),
        `CONNECT_MASTER    ( 0)
        `CONNECT_MASTER    ( 1)
        `CONNECT_MASTER    ( 2)
        `CONNECT_MASTER    ( 3)
        `CONNECT_MASTER    ( 4)
        `CONNECT_MASTER    ( 5)
        `CONNECT_MASTER    ( 6)
        `CONNECT_MASTER    ( 7)
        `CONNECT_MASTER    ( 8)
        `CONNECT_MASTER    ( 9)
        `CONNECT_MASTER    (10)
        `CONNECT_MASTER    (11)
        `CONNECT_MASTER    (12)
        `CONNECT_MASTER    (13)
        `CONNECT_MASTER    (14)
        `CONNECT_MASTER    (15)
        `CONNECT_MASTER    (16)
        `CONNECT_MASTER    (17)
        `CONNECT_MASTER    (18)
        `CONNECT_MASTER    (19)
        `CONNECT_SLAVE     ( 0)
        `CONNECT_SLAVE     ( 1)
        `CONNECT_SLAVE     ( 2)
        `CONNECT_SLAVE     ( 3)
        `CONNECT_SLAVE     ( 4)
        `CONNECT_SLAVE     ( 5)
        `CONNECT_SLAVE     ( 6)
        `CONNECT_SLAVE     ( 7)
        `CONNECT_SLAVE     ( 8)
        `CONNECT_SLAVE     ( 9)
        `CONNECT_SLAVE     (10)
        `CONNECT_SLAVE_END (11)
    );


    //---------------------------------------------------------
    // Routine: Run test
    //---------------------------------------------------------

    initial begin

        // Run test
        run_test();

    end


endmodule