//---------------------------------------------------------
// Module: axi4_liteic_priority_if
//---------------------------------------------------------

// LiteIc AXI4 priority interface

interface axi4_liteic_priority_if #(
    parameter WIDTH = 1
);

    logic [WIDTH-1:0] prior;

endinterface