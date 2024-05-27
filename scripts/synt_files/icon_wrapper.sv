module icon_wrapper
  import liteic_pkg::*;
(
  input logic         clk_i,
  input logic         rstn_i,

  input    [ AXI_ADDR_WIDTH-1:0 ]    M_ARADDR   [ IC_NUM_MASTER_SLOTS ],
  input    [                3:0 ]    M_ARQOS    [ IC_NUM_MASTER_SLOTS ],
  input                              M_ARVALID  [ IC_NUM_MASTER_SLOTS ],
  input    [ AXI_ADDR_WIDTH-1:0 ]    M_AWADDR   [ IC_NUM_MASTER_SLOTS ],
  input    [                3:0 ]    M_AWQOS    [ IC_NUM_MASTER_SLOTS ],
  input                              M_AWVALID  [ IC_NUM_MASTER_SLOTS ],
  input    [ AXI_DATA_WIDTH-1:0 ]    M_WDATA    [ IC_NUM_MASTER_SLOTS ],
  input    [ AXI_STRB_WIDTH-1:0 ]    M_WSTRB    [ IC_NUM_MASTER_SLOTS ],
  input                              M_WVALID   [ IC_NUM_MASTER_SLOTS ],
  input                              M_RREADY   [ IC_NUM_MASTER_SLOTS ],
  input                              M_BREADY   [ IC_NUM_MASTER_SLOTS ],
  output                             M_ARREADY  [ IC_NUM_MASTER_SLOTS ],
  output   [ AXI_DATA_WIDTH-1:0 ]    M_RDATA    [ IC_NUM_MASTER_SLOTS ],
  output                             M_RVALID   [ IC_NUM_MASTER_SLOTS ],
  output   [ AXI_RESP_WIDTH-1:0 ]    M_RRESP    [ IC_NUM_MASTER_SLOTS ],
  output                             M_AWREADY  [ IC_NUM_MASTER_SLOTS ],
  output                             M_WREADY   [ IC_NUM_MASTER_SLOTS ],
  output                             M_BVALID   [ IC_NUM_MASTER_SLOTS ],
  output   [ AXI_RESP_WIDTH-1:0 ]    M_BRESP    [ IC_NUM_MASTER_SLOTS ],

  output   [ AXI_ADDR_WIDTH-1:0 ]    S_ARADDR   [ IC_NUM_SLAVE_SLOTS ],
  output   [                3:0 ]    S_ARQOS    [ IC_NUM_SLAVE_SLOTS ],
  output                             S_ARVALID  [ IC_NUM_SLAVE_SLOTS ],
  output   [ AXI_ADDR_WIDTH-1:0 ]    S_AWADDR   [ IC_NUM_SLAVE_SLOTS ],
  output   [                3:0 ]    S_AWQOS    [ IC_NUM_SLAVE_SLOTS ],
  output                             S_AWVALID  [ IC_NUM_SLAVE_SLOTS ],
  output   [ AXI_DATA_WIDTH-1:0 ]    S_WDATA    [ IC_NUM_SLAVE_SLOTS ],
  output   [ AXI_STRB_WIDTH-1:0 ]    S_WSTRB    [ IC_NUM_SLAVE_SLOTS ],
  output                             S_WVALID   [ IC_NUM_SLAVE_SLOTS ],
  output                             S_RREADY   [ IC_NUM_SLAVE_SLOTS ],
  output                             S_BREADY   [ IC_NUM_SLAVE_SLOTS ],
  input                              S_ARREADY  [ IC_NUM_SLAVE_SLOTS ],
  input    [ AXI_DATA_WIDTH-1:0 ]    S_RDATA    [ IC_NUM_SLAVE_SLOTS ],
  input                              S_RVALID   [ IC_NUM_SLAVE_SLOTS ],
  input    [ AXI_RESP_WIDTH-1:0 ]    S_RRESP    [ IC_NUM_SLAVE_SLOTS ],
  input                              S_AWREADY  [ IC_NUM_SLAVE_SLOTS ],
  input                              S_WREADY   [ IC_NUM_SLAVE_SLOTS ],
  input                              S_BVALID   [ IC_NUM_SLAVE_SLOTS ],
  input    [ AXI_RESP_WIDTH-1:0 ]    S_BRESP    [ IC_NUM_SLAVE_SLOTS ]
);
  
  axi_lite_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH)
  ) mst_axil [ IC_NUM_MASTER_SLOTS ] ();

  axi_lite_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH)
  ) slv_axil [ IC_NUM_SLAVE_SLOTS ] ();

  generate
    genvar m_cnt_dut;
    for(m_cnt_dut = 0; m_cnt_dut < IC_NUM_MASTER_SLOTS; m_cnt_dut = m_cnt_dut + 1) begin
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


    genvar s_cnt_dut;
    for(s_cnt_dut = 0; s_cnt_dut < IC_NUM_SLAVE_SLOTS; s_cnt_dut = s_cnt_dut + 1) begin
      // To VIP
      assign S_ARADDR [s_cnt_dut] = slv_axil[s_cnt_dut].ar_addr ;
      assign S_ARQOS  [s_cnt_dut] = slv_axil[s_cnt_dut].ar_qos  ;
      assign S_ARVALID[s_cnt_dut] = slv_axil[s_cnt_dut].ar_valid;
      assign S_AWADDR [s_cnt_dut] = slv_axil[s_cnt_dut].aw_addr ;
      assign S_AWQOS  [s_cnt_dut] = slv_axil[s_cnt_dut].aw_qos  ;
      assign S_AWVALID[s_cnt_dut] = slv_axil[s_cnt_dut].aw_valid;
      assign S_WDATA  [s_cnt_dut] = slv_axil[s_cnt_dut].w_data  ;
      assign S_WSTRB  [s_cnt_dut] = slv_axil[s_cnt_dut].w_strb  ;
      assign S_WVALID [s_cnt_dut] = slv_axil[s_cnt_dut].w_valid ;
      assign S_RREADY [s_cnt_dut] = slv_axil[s_cnt_dut].r_ready ;
      assign S_BREADY [s_cnt_dut] = slv_axil[s_cnt_dut].b_ready ;
      
      // To DUT
      assign slv_axil[s_cnt_dut].ar_ready = S_ARREADY[s_cnt_dut];
      assign slv_axil[s_cnt_dut].r_data   = S_RDATA  [s_cnt_dut];
      assign slv_axil[s_cnt_dut].r_valid  = S_RVALID [s_cnt_dut];
      assign slv_axil[s_cnt_dut].r_resp   = S_RRESP  [s_cnt_dut];
      assign slv_axil[s_cnt_dut].aw_ready = S_AWREADY[s_cnt_dut];
      assign slv_axil[s_cnt_dut].w_ready  = S_WREADY [s_cnt_dut];
      assign slv_axil[s_cnt_dut].b_valid  = S_BVALID [s_cnt_dut]; 
      assign slv_axil[s_cnt_dut].b_resp   = S_BRESP  [s_cnt_dut]; 
    end
  endgenerate

//============================================================== IC instance
  liteic_icon_top ic (
    .clk_i                 ( clk_i                ),
    .rstn_i                ( rstn_i               ),
    .mst_axil              ( mst_axil             ),
    .slv_axil              ( slv_axil             )
  );
//============================================================== IC instance : end
endmodule