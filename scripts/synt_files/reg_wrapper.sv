module reg_wrapper
  import liteic_pkg::*;
(
  input logic         clk_i,
  input logic         rstn_i,

  axi_lite_if.sp      mst_axil_i [ IC_NUM_MASTER_SLOTS ],
  axi_lite_if.mp      slv_axil_i [ IC_NUM_SLAVE_SLOTS  ]
);

//============================================================== default IC params
  localparam QOS_WIDTH   = 4;
//============================================================== default IC params : end

//============================================================== regs

  axi_lite_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH)
  ) mst_axil [ IC_NUM_MASTER_SLOTS ] ();

  axi_lite_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH)
  ) slv_axil [ IC_NUM_SLAVE_SLOTS ] ();
  

  // read address channel
  logic [  AXI_ADDR_WIDTH-1:0 ]  slv_ar_addr_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_ar_valid_r [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_ar_ready_r [ IC_NUM_SLAVE_SLOTS  ];
  logic [       QOS_WIDTH-1:0 ]  slv_ar_qos_r   [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_ADDR_WIDTH-1:0 ]  mst_ar_addr_r  [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_ar_valid_r [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_ar_ready_r [ IC_NUM_MASTER_SLOTS ];
  logic [       QOS_WIDTH-1:0 ]  mst_ar_qos_r   [ IC_NUM_MASTER_SLOTS ];

  // read data channel
  logic [  AXI_DATA_WIDTH-1:0 ]  slv_r_data_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_RESP_WIDTH-1:0 ]  slv_r_resp_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_r_valid_r [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_r_ready_r [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_DATA_WIDTH-1:0 ]  mst_r_data_r  [ IC_NUM_MASTER_SLOTS ];
  logic [  AXI_RESP_WIDTH-1:0 ]  mst_r_resp_r  [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_r_valid_r [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_r_ready_r [ IC_NUM_MASTER_SLOTS ];

  // write address channel
  logic [  AXI_ADDR_WIDTH-1:0 ]  slv_aw_addr_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_aw_valid_r [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_aw_ready_r [ IC_NUM_SLAVE_SLOTS  ];
  logic [       QOS_WIDTH-1:0 ]  slv_aw_qos_r   [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_ADDR_WIDTH-1:0 ]  mst_aw_addr_r  [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_aw_valid_r [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_aw_ready_r [ IC_NUM_MASTER_SLOTS ];
  logic [       QOS_WIDTH-1:0 ]  mst_aw_qos_r   [ IC_NUM_MASTER_SLOTS  ];

  // write data channel
  logic [  AXI_DATA_WIDTH-1:0 ]  slv_w_data_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_STRB_WIDTH-1:0 ]  slv_w_strb_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_w_valid_r [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_w_ready_r [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_DATA_WIDTH-1:0 ]  mst_w_data_r  [ IC_NUM_MASTER_SLOTS ];
  logic [  AXI_STRB_WIDTH-1:0 ]  mst_w_strb_r  [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_w_valid_r [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_w_ready_r [ IC_NUM_MASTER_SLOTS ];

  // write response channel
  logic [  AXI_RESP_WIDTH-1:0 ]  slv_b_resp_r  [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_b_valid_r [ IC_NUM_SLAVE_SLOTS  ];
  logic                          slv_b_ready_r [ IC_NUM_SLAVE_SLOTS  ];
  logic [  AXI_RESP_WIDTH-1:0 ]  mst_b_resp_r  [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_b_valid_r [ IC_NUM_MASTER_SLOTS ];
  logic                          mst_b_ready_r [ IC_NUM_MASTER_SLOTS ];


  genvar i;
  generate
    // master ports
    for (i=0; i<IC_NUM_SLAVE_SLOTS; i=i+1) begin
      always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
          slv_ar_addr_r   [i] <= '0;
          slv_ar_valid_r  [i] <= '0;
          slv_ar_ready_r  [i] <= '0;
          slv_ar_qos_r    [i] <= '0;

          slv_r_data_r    [i] <= '0;
          slv_r_resp_r    [i] <= '0;
          slv_r_valid_r   [i] <= '0;
          slv_r_ready_r   [i] <= '0;

          slv_aw_addr_r   [i] <= '0;
          slv_aw_valid_r  [i] <= '0;
          slv_aw_ready_r  [i] <= '0;
          slv_aw_qos_r    [i] <= '0;

          slv_w_data_r    [i] <= '0;
          slv_w_strb_r    [i] <= '0;
          slv_w_valid_r   [i] <= '0;
          slv_w_ready_r   [i] <= '0;

          slv_b_resp_r    [i] <= '0;
          slv_b_valid_r   [i] <= '0;
          slv_b_ready_r   [i] <= '0;
        end else begin
          slv_ar_addr_r   [i] <= slv_axil[i].ar_addr;
          slv_ar_valid_r  [i] <= slv_axil[i].ar_valid;
          slv_ar_ready_r  [i] <= slv_axil_i[i].ar_ready;
          slv_ar_qos_r    [i] <= slv_axil[i].ar_qos;

          slv_r_data_r    [i] <= slv_axil_i[i].r_data;
          slv_r_resp_r    [i] <= slv_axil_i[i].r_resp;
          slv_r_valid_r   [i] <= slv_axil_i[i].r_valid;
          slv_r_ready_r   [i] <= slv_axil[i].r_ready;

          slv_aw_addr_r   [i] <= slv_axil[i].aw_addr;
          slv_aw_valid_r  [i] <= slv_axil[i].aw_valid;
          slv_aw_ready_r  [i] <= slv_axil_i[i].aw_ready;
          slv_aw_qos_r    [i] <= slv_axil[i].aw_qos;

          slv_w_data_r    [i] <= slv_axil[i].w_data;
          slv_w_strb_r    [i] <= slv_axil[i].w_strb;
          slv_w_valid_r   [i] <= slv_axil[i].w_valid;
          slv_w_ready_r   [i] <= slv_axil_i[i].w_ready;

          slv_b_resp_r    [i] <= slv_axil_i[i].b_resp;
          slv_b_valid_r   [i] <= slv_axil_i[i].b_valid;
          slv_b_ready_r   [i] <= slv_axil[i].b_ready;
        end
      end

      always_comb begin
        slv_axil_i[i].ar_addr  = slv_ar_addr_r [i];
        slv_axil_i[i].ar_valid = slv_ar_valid_r[i];
        slv_axil_i[i].ar_qos   = slv_ar_qos_r  [i];
        slv_axil_i[i].r_ready  = slv_r_ready_r [i];
        slv_axil_i[i].aw_addr  = slv_aw_addr_r [i];
        slv_axil_i[i].aw_valid = slv_aw_valid_r[i];
        slv_axil_i[i].aw_qos   = slv_aw_qos_r  [i];
        slv_axil_i[i].w_data   = slv_w_data_r  [i];
        slv_axil_i[i].w_strb   = slv_w_strb_r  [i];
        slv_axil_i[i].w_valid  = slv_w_valid_r [i]; 
        slv_axil_i[i].b_ready  = slv_b_ready_r [i];
      end

      always_comb begin
        slv_axil[i].ar_ready = slv_ar_ready_r[i];
        slv_axil[i].r_data   = slv_r_data_r  [i];
        slv_axil[i].r_resp   = slv_r_resp_r  [i];
        slv_axil[i].r_valid  = slv_r_valid_r [i];
        slv_axil[i].aw_ready = slv_aw_ready_r[i];
        slv_axil[i].w_ready  = slv_w_ready_r [i];
        slv_axil[i].b_resp   = slv_b_resp_r  [i];
        slv_axil[i].b_valid  = slv_b_valid_r [i];
      end
    end

    
    // slave ports
    for (i=0; i<IC_NUM_MASTER_SLOTS; i=i+1) begin
      always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
          mst_ar_addr_r  [i] <= '0;
          mst_ar_valid_r [i] <= '0;
          mst_ar_ready_r [i] <= '0;
          mst_ar_qos_r   [i] <= '0;

          mst_r_data_r   [i] <= '0;
          mst_r_resp_r   [i] <= '0;
          mst_r_valid_r  [i] <= '0;
          mst_r_ready_r  [i] <= '0;

          mst_aw_addr_r  [i] <= '0;
          mst_aw_valid_r [i] <= '0;
          mst_aw_ready_r [i] <= '0;
          mst_aw_qos_r   [i] <= '0;

          mst_w_data_r   [i] <= '0;
          mst_w_strb_r   [i] <= '0;
          mst_w_valid_r  [i] <= '0;
          mst_w_ready_r  [i] <= '0;

          mst_b_resp_r   [i] <= '0;
          mst_b_valid_r  [i] <= '0;
          mst_b_ready_r  [i] <= '0;
        end else begin
          mst_ar_addr_r  [i] <= mst_axil_i[i].ar_addr;
          mst_ar_valid_r [i] <= mst_axil_i[i].ar_valid;
          mst_ar_ready_r [i] <= mst_axil[i].ar_ready;
          mst_ar_qos_r   [i] <= mst_axil_i[i].ar_qos;

          mst_r_data_r   [i] <= mst_axil[i].r_data;
          mst_r_resp_r   [i] <= mst_axil[i].r_resp;
          mst_r_valid_r  [i] <= mst_axil[i].r_valid;
          mst_r_ready_r  [i] <= mst_axil_i[i].r_ready;

          mst_aw_addr_r  [i] <= mst_axil_i[i].aw_addr;
          mst_aw_valid_r [i] <= mst_axil_i[i].aw_valid;
          mst_aw_ready_r [i] <= mst_axil[i].aw_ready;
          mst_aw_qos_r   [i] <= mst_axil_i[i].aw_qos;

          mst_w_data_r   [i] <= mst_axil_i[i].w_data;
          mst_w_strb_r   [i] <= mst_axil_i[i].w_strb;
          mst_w_valid_r  [i] <= mst_axil_i[i].w_valid;
          mst_w_ready_r  [i] <= mst_axil[i].w_ready;

          mst_b_resp_r   [i] <= mst_axil[i].b_resp;
          mst_b_valid_r  [i] <= mst_axil[i].b_valid;
          mst_b_ready_r  [i] <= mst_axil_i[i].b_ready;
        end
      end

      always_comb begin
        mst_axil_i[i].ar_ready = mst_ar_ready_r[i];
        mst_axil_i[i].r_data   = mst_r_data_r  [i];
        mst_axil_i[i].r_resp   = mst_r_resp_r  [i];
        mst_axil_i[i].r_valid  = mst_r_valid_r [i];
        mst_axil_i[i].aw_ready = mst_aw_ready_r[i];
        mst_axil_i[i].w_ready  = mst_w_ready_r [i];
        mst_axil_i[i].b_resp   = mst_b_resp_r  [i];
        mst_axil_i[i].b_valid  = mst_b_valid_r [i];
      end

      always_comb begin
        mst_axil[i].ar_addr  = mst_ar_addr_r [i];
        mst_axil[i].ar_valid = mst_ar_valid_r[i];
        mst_axil[i].ar_qos   = mst_ar_qos_r  [i];
        mst_axil[i].r_ready  = mst_r_ready_r [i];
        mst_axil[i].aw_addr  = mst_aw_addr_r [i];
        mst_axil[i].aw_valid = mst_aw_valid_r[i];
        mst_axil[i].aw_qos   = mst_aw_qos_r  [i];
        mst_axil[i].w_data   = mst_w_data_r  [i];
        mst_axil[i].w_strb   = mst_w_strb_r  [i];
        mst_axil[i].w_valid  = mst_w_valid_r [i]; 
        mst_axil[i].b_ready  = mst_b_ready_r [i];
      end
    end
  endgenerate
//============================================================== regs : end

//============================================================== IC instance
  liteic_icon_top ic (
    .clk_i                 ( clk_i                ),
    .rstn_i                ( rstn_i               ),
    .mst_axil              ( mst_axil             ),
    .slv_axil              ( slv_axil             )
  );
//============================================================== IC instance : end
endmodule