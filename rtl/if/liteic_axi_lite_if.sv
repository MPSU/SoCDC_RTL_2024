interface axi_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter RESP_WIDTH = 1
);
localparam STRB_WIDTH = (DATA_WIDTH + 7) / 8;

// read address channel
logic [ ADDR_WIDTH-1:0 ]  ar_addr;
logic [            3:0 ]  ar_qos;
logic                     ar_valid;
logic                     ar_ready;

// read data channel
logic [ DATA_WIDTH-1:0 ]  r_data;
logic [ RESP_WIDTH-1:0 ]  r_resp;
logic                     r_valid;
logic                     r_ready;

// write address channel
logic [ ADDR_WIDTH-1:0 ]  aw_addr;
logic [            3:0 ]  aw_qos;
logic                     aw_valid;
logic                     aw_ready;

// write data channel
logic [ DATA_WIDTH-1:0 ]  w_data;
logic [ STRB_WIDTH-1:0 ]  w_strb;
logic                     w_valid;
logic                     w_ready;

// write response channel
logic [ RESP_WIDTH-1:0 ]  b_resp;
logic                     b_valid;
logic                     b_ready;

modport sp (
    input ar_addr, ar_valid, ar_qos,   output ar_ready,
    input r_ready,                     output r_data, r_resp, r_valid,
    input aw_addr, aw_valid, aw_qos,   output aw_ready,
    input w_data, w_strb, w_valid,     output w_ready,
    input b_ready,                     output b_resp, b_valid
);

modport mp (
    output ar_addr, ar_valid, ar_qos,  input ar_ready,
    output r_ready,                    input r_data, r_resp, r_valid,
    output aw_addr, aw_valid, aw_qos,  input aw_ready,
    output w_data, w_strb, w_valid,    input w_ready,
    output b_ready,                    input b_resp, b_valid
);

modport sp_read (
    input ar_addr, ar_valid, ar_qos,   output ar_ready,
    input r_ready,                     output r_data, r_resp, r_valid
);

modport sp_write (
    input aw_addr, aw_valid, aw_qos,   output aw_ready,
    input w_data, w_strb, w_valid,     output w_ready,
    input b_ready,                     output b_resp, b_valid
);

modport mp_read (
    output ar_addr, ar_valid, ar_qos,  input ar_ready,
    output r_ready,                    input r_data, r_resp, r_valid
);

modport mp_write (
    output aw_addr, aw_valid, aw_qos,  input aw_ready,
    output w_data, w_strb, w_valid,    input w_ready,
    output b_ready,                    input b_resp, b_valid
);

endinterface
