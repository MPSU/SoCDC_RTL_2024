module liteic_master_node_read
    import liteic_pkg::IC_NUM_SLAVE_SLOTS;
    import liteic_pkg::IC_ARADDR_WIDTH;
    import liteic_pkg::IC_RDATA_WIDTH;
    import liteic_pkg::IC_INVALID_ADDR_RESP;
    import liteic_pkg::IC_RD_CONNECTIVITY;
    import liteic_pkg::IC_SLAVE_REGION_BASE;
    import liteic_pkg::IC_SLAVE_REGION_SIZE;
(
    input logic                                    clk_i,
    input logic                                    rstn_i,
    
    // interconnect axi interface
    axi_lite_if                                    mst_axil,

    // interconnect crossbar matrix
    input  logic [ IC_NUM_SLAVE_SLOTS-1 : 0 ] cbar_reqst_rdy_i,
    output logic [ IC_NUM_SLAVE_SLOTS-1 : 0 ] cbar_reqst_val_o,
    output logic [ IC_ARADDR_WIDTH-1    : 0 ] cbar_reqst_data_o,

    input  logic [ IC_RDATA_WIDTH-1     : 0 ] cbar_resp_data_i [ IC_NUM_SLAVE_SLOTS ],
    input  logic [ IC_NUM_SLAVE_SLOTS-1 : 0 ] cbar_resp_val_i,
    output logic [ IC_NUM_SLAVE_SLOTS-1 : 0 ] cbar_resp_rdy_o
);


//-------------------------------------------------------------------------------
// localparams
//-------------------------------------------------------------------------------

// Find count of already connected slave slots in interconnect
function int unsigned count_slave_slots();
    count_slave_slots = 0;
    for(int i = 0; i < IC_NUM_SLAVE_SLOTS; i++) begin
        if(IC_RD_CONNECTIVITY[i])
            count_slave_slots++;
    end
endfunction

// get n-th non-zero position in connectivity vector
function int unsigned get_connectivity_idx(int n);
    int connectivity_idx;
    connectivity_idx = 0;
    for(int i = 0; i < IC_NUM_SLAVE_SLOTS; i++) begin
        if(IC_RD_CONNECTIVITY[i]) begin
            if (connectivity_idx == n)
                return i;
            else
                connectivity_idx++;
        end
    end
endfunction

// Determine node's slave slots number and regions
localparam NODE_NUM_SLAVE_SLOTS  = count_slave_slots();
typedef bit [IC_ARADDR_WIDTH-1:0] ic_region_t   [IC_NUM_SLAVE_SLOTS                                ];
typedef bit [IC_ARADDR_WIDTH-1:0] node_region_t [(IC_NUM_SLAVE_SLOTS != 0) ? IC_NUM_SLAVE_SLOTS : 1];

// Convert interconnect regions to node regions considering already connected nodes in icon_top 
function node_region_t ic2node_region(ic_region_t ic_region_array);
    int node_region_idx;
    node_region_idx = 0;
    for(int ic_region_idx = 0; ic_region_idx < IC_NUM_SLAVE_SLOTS; ic_region_idx++) begin
        // Add ic's slave region to node's slave region
        // if the node has this slave in its connectivity vector
        if(IC_RD_CONNECTIVITY[ic_region_idx]) begin
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
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_arready_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_arvalid_w;
logic [ IC_ARADDR_WIDTH-1      : 0 ] node_araddr_w;
logic [ IC_RDATA_WIDTH-1       : 0 ] node_rdata_w [ NODE_NUM_SLAVE_SLOTS ];
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_rvalid_w;
logic [ NODE_NUM_SLAVE_SLOTS-1 : 0 ] node_rready_w;

// ADDR of slave from decoder
logic [ IC_ARADDR_WIDTH-1       : 0 ] slv_araddr_wi;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst_onehot;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_reqst_onehot_r;

// Flags
logic                                 illegal_addr;
logic                                 ar_success_r;

// IDs of slave for waiting response
logic [ NODE_SLAVE_ID_WIDTH-1   : 0 ] slv_id_resp;
logic [ NODE_NUM_SLAVE_SLOTS-1  : 0 ] slv_id_resp_onehot;

// // Signals from/to AXI master
logic                               mst_rready_wi;
logic                               mst_rvalid_wo;
logic [ IC_RDATA_WIDTH-1      : 0 ] mst_rdata_wo;

logic                               mst_arvalid_wi;
logic [ IC_ARADDR_WIDTH-1     : 0 ] mst_araddr_wi;
logic                               mst_arready_wo;

//-------------------------------------------------------------------------------
// = Reconnect and combine interfaces
//-------------------------------------------------------------------------------

assign mst_axil.ar_ready = mst_arready_wo;
assign mst_arvalid_wi    = mst_axil.ar_valid;
assign mst_araddr_wi     = mst_axil.ar_addr;

assign {mst_axil.r_data, mst_axil.r_resp} = mst_rdata_wo;
assign mst_axil.r_valid                   = mst_rvalid_wo;
assign mst_rready_wi                      = mst_axil.r_ready;

assign slv_araddr_wi = mst_axil.ar_addr;

//-------------------------------------------------------------------------------
// AXI signal management
//-------------------------------------------------------------------------------

// = AR channel = //

assign node_araddr_w  = mst_araddr_wi;
assign mst_arready_wo = (ar_success_r && |(slv_id_reqst_onehot & node_arready_w) || illegal_addr );
assign node_arvalid_w = (ar_success_r && mst_arvalid_wi && !illegal_addr) ? slv_id_reqst_onehot : '0;

// = R channel = //

assign mst_rdata_wo  = (illegal_addr) ? IC_RDATA_WIDTH'(IC_INVALID_ADDR_RESP) : node_rdata_w[slv_id_resp];
assign mst_rvalid_wo = (|(node_rvalid_w & slv_id_resp_onehot) || illegal_addr );
assign node_rready_w = (mst_rready_wi && !illegal_addr) ? slv_id_resp_onehot : '0;

//-------------------------------------------------------------------------------
// Reconnect crossbar, if nodes has no connection
//-------------------------------------------------------------------------------

generate
// Check if node connectivity has slave slots.
// Create master node and connect it to crossbar matrix as per IC_RD_CONNECTIVITY vector
    assign cbar_reqst_data_o   = node_araddr_w;

    for (genvar node_slv_slot_idx = 0; node_slv_slot_idx < NODE_NUM_SLAVE_SLOTS; node_slv_slot_idx++) begin
        localparam ic_slv_slot_idx = get_connectivity_idx(node_slv_slot_idx);

        if(IC_RD_CONNECTIVITY[ic_slv_slot_idx]) begin
            assign node_arready_w[node_slv_slot_idx] = cbar_reqst_rdy_i[ic_slv_slot_idx];
            assign node_rvalid_w [node_slv_slot_idx] = cbar_resp_val_i [ic_slv_slot_idx];
            assign node_rdata_w[node_slv_slot_idx]   = cbar_resp_data_i[ic_slv_slot_idx];

            assign cbar_reqst_val_o[ic_slv_slot_idx] = node_arvalid_w[node_slv_slot_idx];
            assign cbar_resp_rdy_o [ic_slv_slot_idx] = node_rready_w [node_slv_slot_idx];
        end
    end
endgenerate

//-------------------------------------------------------------------------------
// Save id of slave, which sent the reqst
//-------------------------------------------------------------------------------

always_ff @(posedge clk_i or negedge rstn_i)
if      (!rstn_i)                         slv_id_reqst_onehot_r <= '0;
else if (mst_arvalid_wi & mst_arready_wo) slv_id_reqst_onehot_r <= slv_id_reqst_onehot;
else                                      slv_id_reqst_onehot_r <= slv_id_reqst_onehot_r;

//-------------------------------------------------------------------------------
// Flags of success transactions
//-------------------------------------------------------------------------------

always_ff @(posedge clk_i or negedge rstn_i)
if      (!rstn_i)                         ar_success_r <= '1;
else if (mst_arvalid_wi & mst_arready_wo) ar_success_r <= '0;
else if (mst_rvalid_wo  & mst_rready_wi ) ar_success_r <= '1;
else                                      ar_success_r <= ar_success_r;

//-------------------------------------------------------------------------------
// initializations units
//-------------------------------------------------------------------------------

// Checking the address for region ownership and issuing a region number(slave_id) as onehot and binary
liteic_addr_decoder
#(
    .ADDR_WIDTH     (IC_ARADDR_WIDTH        ),
    .NUM_REGIONS    (NODE_NUM_SLAVE_SLOTS   ),
    .REGION_BASE    (NODE_SLAVE_REGION_BASE ),
    .REGION_SIZE    (NODE_SLAVE_REGION_SIZE )
)
slave_addr_decoder (
    .addr_i           (slv_araddr_wi        ),
    .rgn_select_o     (slv_id_reqst_onehot  ),
    .illegal_addr_o   (illegal_addr         )
);

// This module is used, as a converter to binary value
liteic_priority_cd #(.IN_WIDTH(IC_NUM_SLAVE_SLOTS), .OUT_WIDTH(NODE_SLAVE_ID_WIDTH)) 
slave_resp_priority_cd (
    .in     (slv_id_reqst_onehot_r  ),
    .onehot (slv_id_resp_onehot     ),
    .out    (slv_id_resp            )
); 
endmodule
