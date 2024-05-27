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
        #(10*CLK_PERIOD);
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
    // Instance: DUT
    //---------------------------------------------------------
    
    // LiteIc AXI4 instance for DV

    liteic_icon_top DUT (
        .clk_i    ( ACLK     ),
        .rstn_i   ( ARESETn  ),
        .mst_axil ( mst_axil ),
        .slv_axil ( slv_axil )
    );


    //---------------------------------------------------------
    // Routine: Connect masters
    //---------------------------------------------------------

    generate

        genvar m_cnt_dut;
        for(m_cnt_dut = 0; m_cnt_dut < MASTERS_AMOUNT; m_cnt_dut = m_cnt_dut + 1) begin
 
            // To DUT
            assign mst_axil[m_cnt_dut].ar_addr  = M_ARADDR [m_cnt_dut];
            assign mst_axil[m_cnt_dut].ar_qos   = M_ARQOS  [m_cnt_dut];
            assign mst_axil[m_cnt_dut].ar_valid = M_ARVALID[m_cnt_dut];
            assign mst_axil[m_cnt_dut].aw_addr  = M_AWADDR [m_cnt_dut];
            assign mst_axil[m_cnt_dut].aw_qos   = M_AWQOS  [m_cnt_dut];
            assign mst_axil[m_cnt_dut].aw_valid = M_AWVALID[m_cnt_dut];
            assign mst_axil[m_cnt_dut].w_data   = M_WDATA  [m_cnt_dut];
            assign mst_axil[m_cnt_dut].w_strb   = M_WSTRB  [m_cnt_dut];
            assign mst_axil[m_cnt_dut].w_valid  = M_WVALID [m_cnt_dut];
            assign mst_axil[m_cnt_dut].r_ready  = M_RREADY [m_cnt_dut];
            assign mst_axil[m_cnt_dut].b_ready  = M_BREADY [m_cnt_dut];
            
            // To VIP
            assign M_ARREADY[m_cnt_dut] = mst_axil[m_cnt_dut].ar_ready;
            assign M_RDATA  [m_cnt_dut] = mst_axil[m_cnt_dut].r_data;
            assign M_RVALID [m_cnt_dut] = mst_axil[m_cnt_dut].r_valid;
            assign M_RRESP  [m_cnt_dut] = mst_axil[m_cnt_dut].r_resp;
            assign M_AWREADY[m_cnt_dut] = mst_axil[m_cnt_dut].aw_ready;
            assign M_WREADY [m_cnt_dut] = mst_axil[m_cnt_dut].w_ready;
            assign M_BVALID [m_cnt_dut] = mst_axil[m_cnt_dut].b_valid; 
            assign M_BRESP  [m_cnt_dut] = mst_axil[m_cnt_dut].b_resp; 

        end

    endgenerate


    //---------------------------------------------------------
    // Routine: Connect slaves
    //---------------------------------------------------------

    generate

        genvar s_cnt_dut;
        for(s_cnt_dut = 0; s_cnt_dut < SLAVES_AMOUNT; s_cnt_dut = s_cnt_dut + 1) begin
 
            // To DUT
            assign slv_axil[s_cnt_dut].ar_ready = S_ARREADY[s_cnt_dut];
            assign slv_axil[s_cnt_dut].r_data   = S_RDATA  [s_cnt_dut];
            assign slv_axil[s_cnt_dut].r_valid  = S_RVALID [s_cnt_dut]; 
            assign slv_axil[s_cnt_dut].r_resp   = S_RRESP  [s_cnt_dut];
            assign slv_axil[s_cnt_dut].aw_ready = S_AWREADY[s_cnt_dut];
            assign slv_axil[s_cnt_dut].w_ready  = S_WREADY [s_cnt_dut];
            assign slv_axil[s_cnt_dut].b_valid  = S_BVALID [s_cnt_dut]; 
            assign slv_axil[s_cnt_dut].b_resp   = S_BRESP  [s_cnt_dut]; 

            // To VIP
            assign S_ARADDR [s_cnt_dut] = slv_axil[s_cnt_dut].ar_addr;
            assign S_ARVALID[s_cnt_dut] = slv_axil[s_cnt_dut].ar_valid;
            assign S_AWADDR [s_cnt_dut] = slv_axil[s_cnt_dut].aw_addr;
            assign S_AWVALID[s_cnt_dut] = slv_axil[s_cnt_dut].aw_valid;
            assign S_WDATA  [s_cnt_dut] = slv_axil[s_cnt_dut].w_data;
            assign S_WSTRB  [s_cnt_dut] = slv_axil[s_cnt_dut].w_strb;
            assign S_WVALID [s_cnt_dut] = slv_axil[s_cnt_dut].w_valid;
            assign S_RREADY [s_cnt_dut] = slv_axil[s_cnt_dut].r_ready; 
            assign S_BREADY [s_cnt_dut] = slv_axil[s_cnt_dut].b_ready; 

        end

    endgenerate


    //---------------------------------------------------------
    // Routine: Run test
    //---------------------------------------------------------

    initial begin

        // Run test
        run_test();

        // Guard from running simulation
        // after test done
        forever $stop();

    end


endmodule