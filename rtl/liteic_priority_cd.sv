module liteic_priority_cd #(
    parameter IN_WIDTH = 32,
    parameter OUT_WIDTH = $clog2(IN_WIDTH)
)(
    input  logic [IN_WIDTH-1:0]  in,
    output logic [IN_WIDTH-1:0]  onehot,
    output logic [OUT_WIDTH-1:0] out
);
 
    logic [IN_WIDTH-1:0] reversed;
    logic [IN_WIDTH-1:0] procesed;
    logic [IN_WIDTH-1:0] mask [OUT_WIDTH-1:0];

    assign procesed = (reversed & (reversed - 'b1)) ^ reversed;

    for (genvar i = 0; i < IN_WIDTH; i = i + 1) begin : reverse_position_gen
        assign reversed[i] = in[IN_WIDTH-1-i];
        assign onehot[i] = procesed[IN_WIDTH-1-i];
    end
    
    for (genvar j = 0; j < OUT_WIDTH; j = j + 1) begin : binary_out_gen
        for (genvar i = 0; i < IN_WIDTH; i = i + 1) 
            assign mask[j][i] = (i >> j) & 1;
        assign out[j] = |(onehot & mask[j]);
    end
endmodule