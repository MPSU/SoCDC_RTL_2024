module liteic_master_node_write
    import liteic_pkg::IC_NUM_SLAVE_SLOTS;
    import liteic_pkg::IC_AWADDR_WIDTH;
    import liteic_pkg::IC_WDATA_WIDTH;
    import liteic_pkg::IC_BRESP_WIDTH;
    import liteic_pkg::IC_INVALID_ADDR_RESP;
    import liteic_pkg::IC_WR_CONNECTIVITY;
    import liteic_pkg::IC_SLAVE_REGION_BASE;
    import liteic_pkg::IC_SLAVE_REGION_SIZE;
(
    input logic                                    clk_i,
    input logic                                    rstn_i,
    
    // interconnect axi interface
    axi_lite_if                                    mst_axil,

    // interconnect crossbar matrix
    input  logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_w_reqst_rdy_i,
    output logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_w_reqst_val_o,
    output logic [     IC_WDATA_WIDTH-1      : 0 ] cbar_w_reqst_data_o,

    input  logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_aw_reqst_rdy_i,
    output logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_aw_reqst_val_o,
    output logic [    IC_AWADDR_WIDTH-1      : 0 ] cbar_aw_reqst_data_o,

    input  logic [ IC_BRESP_WIDTH-1          : 0 ] cbar_resp_data_i [ IC_NUM_SLAVE_SLOTS ],
    input  logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_resp_val_i,
    output logic [ IC_NUM_SLAVE_SLOTS-1      : 0 ] cbar_resp_rdy_o
);


//-------------------------------------------------------------------------------
// localparams
//-------------------------------------------------------------------------------

// Find count of already connected slave slots in interconnect
function int unsigned count_slave_slots();
    count_slave_slots = 0;
    for(int i = 0; i < IC_NUM_SLAVE_SLOTS; i++) begin
        if(IC_WR_CONNECTIVITY[i])
            count_slave_slots++;
    end
endfunction

// get n-th non-zero position in connectivity vector
function int unsigned get_connectivity_idx(int n);
    int connectivity_idx;
    connectivity_idx = 0;
    for(int i = 0; i < IC_NUM_SLAVE_SLOTS; i++) begin
        if(IC_WR_CONNECTIVITY[i]) begin
            if (connectivity_idx == n)
                return i;
            else
                connectivity_idx++;
        end
    end
endfunction

// Determine node's slave slots number and regions
localparam NODE_NUM_SLAVE_SLOTS  = count_slave_slots();
typedef bit [IC_AWADDR_WIDTH-1:0] ic_region_t   [IC_NUM_SLAVE_SLOTS                                ];
typedef bit [IC_AWADDR_WIDTH-1:0] node_region_t [(IC_NUM_SLAVE_SLOTS != 0) ? IC_NUM_SLAVE_SLOTS : 1];

// Convert interconnect regions to node regions considering already connected nodes in icon_top 
function node_region_t ic2node_region(ic_region_t ic_region_array);
    int node_region_idx;
    node_region_idx = 0;
    for(int ic_region_idx = 0; ic_region_idx < IC_NUM_SLAVE_SLOTS; ic_region_idx++) begin
        // Add ic's slave region to node's slave region
        // if the node has this slave in its connectivity vector
        if(IC_WR_CONNECTIVITY[ic_region_idx]) begin
            ic2node_region[node_region_idx] = ic_region_array[ic_region_idx];
            node_region_idx++;
        end
    end
endfunction

localparam node_region_t NODE_SLAVE_REGION_BASE = ic2node_region(IC_SLAVE_REGION_BASE);
localparam node_region_t NODE_SLAVE_REGION_SIZE = ic2node_region(IC_SLAVE_REGION_SIZE);
localparam NODE_SLAVE_ID_WIDTH    = $clog2(IC_NUM_SLAVE_SLOTS);

//-------------------------------------------------------------------------------
// signals & interfaces
//-------------------------------------------------------------------------------

// Handling node's connectivity to interconnect crossbar matrix
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_wready_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_wvalid_w;
logic [       IC_WDATA_WIDTH-1 : 0 ] node_wdata_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_awready_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_awvalid_w;
logic [      IC_AWADDR_WIDTH-1 : 0 ] node_awaddr_w;
logic [ IC_BRESP_WIDTH-1       : 0 ] node_bresp_w [ NODE_NUM_SLAVE_SLOTS ];
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_bvalid_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_bready_w;

// Slave ADDRs for decoder
logic [ IC_AWADDR_WIDTH-1      : 0 ] slv_awaddr_wi;

// ID of slave from decoder
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst_onehot;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst_decod_onehot;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst_decod_onehot_r;

// IDs of slave for waiting response
logic [ NODE_SLAVE_ID_WIDTH-1   : 0 ] slv_id_resp;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_resp_onehot;

// Signals from/to AXI master
logic                               mst_bready_wi;
logic                               mst_bvalid_wo;
logic [ IC_BRESP_WIDTH-1      : 0 ] mst_bresp_wo;

logic                                mst_wvalid_wi;
logic [    IC_WDATA_WIDTH-1    : 0 ] mst_wdata_wi;
logic                                mst_wready_wo;

logic                                mst_awvalid_wi;
logic [   IC_AWADDR_WIDTH-1    : 0 ] mst_awaddr_wi;
logic                                mst_awready_wo;

// Flags
logic                                illegal_addr;
logic [1:0]                          in_st;
logic [1:0]                          check;
logic                                aw_success;
logic                                w_success;
logic                                aw_success_r;
logic                                w_success_r;

//-------------------------------------------------------------------------------
// = Reconnect and combine interfaces
//-------------------------------------------------------------------------------

assign mst_awaddr_wi     = mst_axil.aw_addr;
assign mst_awvalid_wi    = mst_axil.aw_valid;
assign mst_axil.aw_ready = mst_awready_wo;

assign mst_wdata_wi      = {mst_axil.w_strb, mst_axil.w_data};
assign mst_wvalid_wi     = mst_axil.w_valid;
assign mst_axil.w_ready  = mst_wready_wo;

assign mst_axil.b_resp   = mst_bresp_wo;
assign mst_axil.b_valid  = mst_bvalid_wo;
assign mst_bready_wi     = mst_axil.b_ready;

assign slv_awaddr_wi     = mst_axil.aw_addr;

//-------------------------------------------------------------------------------
// Reconnect crossbar, if nodes has no connection
//-------------------------------------------------------------------------------

generate
// Check if node connectivity has slave slots.
// Create master node and connect it to crossbar matrix as per IC_WR_CONNECTIVITY vector
    assign  cbar_w_reqst_data_o   =  node_wdata_w;
    assign cbar_aw_reqst_data_o   = node_awaddr_w;

    for (genvar node_slv_slot_idx = 0; node_slv_slot_idx < NODE_NUM_SLAVE_SLOTS; node_slv_slot_idx++) begin
        localparam ic_slv_slot_idx = get_connectivity_idx(node_slv_slot_idx);

        if(IC_WR_CONNECTIVITY[ic_slv_slot_idx]) begin
            assign node_bvalid_w [node_slv_slot_idx]    = cbar_resp_val_i [ic_slv_slot_idx];
            assign node_bresp_w[node_slv_slot_idx]      = cbar_resp_data_i[ic_slv_slot_idx];
            assign cbar_resp_rdy_o [ic_slv_slot_idx]    = node_bready_w [node_slv_slot_idx];

            assign  node_wready_w[node_slv_slot_idx]    = cbar_w_reqst_rdy_i[ic_slv_slot_idx];
            assign  cbar_w_reqst_val_o[ic_slv_slot_idx] = node_wvalid_w[node_slv_slot_idx];
            assign node_awready_w[node_slv_slot_idx]    = cbar_aw_reqst_rdy_i[ic_slv_slot_idx];
            assign cbar_aw_reqst_val_o[ic_slv_slot_idx] = node_awvalid_w[node_slv_slot_idx];
        end
    end
endgenerate

//-------------------------------------------------------------------------------
// AXI signal management
//-------------------------------------------------------------------------------

// Define slv id, from which the request came
assign slv_id_reqst = (aw_success_r) ? slv_id_reqst_decod_onehot_r : slv_id_reqst_decod_onehot;
// The same, but onehot
assign slv_id_reqst_onehot = aw_success_r ? slv_id_reqst_decod_onehot_r : slv_id_reqst_decod_onehot;

// = W channel = //

assign node_wdata_w   = mst_wdata_wi;
assign mst_wready_wo  = (((!w_success_r) && (slv_id_reqst & node_wready_w)) || illegal_addr );
assign node_wvalid_w  = ((!w_success_r) && mst_wvalid_wi && !illegal_addr) ? slv_id_reqst_onehot : '0;

// = AW channel = //

assign node_awaddr_w  = mst_awaddr_wi;
assign mst_awready_wo = (((!aw_success_r) && (|(slv_id_reqst_decod_onehot & node_awready_w))) || illegal_addr );
assign node_awvalid_w = ((!aw_success_r) && mst_awvalid_wi && !illegal_addr) ? slv_id_reqst_decod_onehot : '0;

// = B channel = //

assign mst_bresp_wo   = (illegal_addr) ? IC_BRESP_WIDTH'(IC_INVALID_ADDR_RESP) : node_bresp_w[slv_id_resp];
assign mst_bvalid_wo  = (|(node_bvalid_w & slv_id_resp_onehot) || illegal_addr );
assign node_bready_w  = (mst_bready_wi && !illegal_addr) ? slv_id_resp_onehot : '0;

//-------------------------------------------------------------------------------
// Registers
//-------------------------------------------------------------------------------

always_ff @(posedge clk_i or negedge rstn_i)
if      (!rstn_i)                          slv_id_reqst_decod_onehot_r <= '0;
else if (mst_awvalid_wi && mst_awready_wo) slv_id_reqst_decod_onehot_r <= slv_id_reqst_decod_onehot;
else                                       slv_id_reqst_decod_onehot_r <= slv_id_reqst_decod_onehot_r;

assign aw_success  = mst_awvalid_wi && mst_awready_wo;
always_ff @(posedge clk_i or negedge rstn_i)
if      (!rstn_i)                         aw_success_r <= 'b0;
else if (mst_bvalid_wo &&  mst_bready_wi) aw_success_r <= 'b0;
else                                      aw_success_r <= aw_success_r | aw_success;

assign  w_success  =  mst_wvalid_wi &&  mst_wready_wo;
always_ff @(posedge clk_i or negedge rstn_i)
if      (!rstn_i)                         w_success_r <= 'b0;
else if (mst_bvalid_wo &&  mst_bready_wi) w_success_r <= 'b0;
else                                      w_success_r <= w_success_r | w_success;



//-------------------------------------------------------------------------------
// initializations units
//-------------------------------------------------------------------------------

// Checking the address for region ownership and issuing a region number(slave_id) as onehot and binary
liteic_addr_decoder
#(
    .ADDR_WIDTH     (IC_AWADDR_WIDTH        ),
    .NUM_REGIONS    (NODE_NUM_SLAVE_SLOTS   ),
    .REGION_BASE    (NODE_SLAVE_REGION_BASE ),
    .REGION_SIZE    (NODE_SLAVE_REGION_SIZE )
)
slave_addr_decoder (
    .addr_i           (slv_awaddr_wi             ),
    .rgn_select_o     (slv_id_reqst_decod_onehot ),
    .illegal_addr_o   (illegal_addr              )
);

// This module is used, as a converter to binary value
liteic_priority_cd #(.IN_WIDTH(IC_NUM_SLAVE_SLOTS), .OUT_WIDTH(NODE_SLAVE_ID_WIDTH)) 
slave_resp_priority_cd (
    .in     (slv_id_reqst_decod_onehot_r  ),
    .onehot (slv_id_resp_onehot           ),
    .out    (slv_id_resp                  )
); 

endmodule
