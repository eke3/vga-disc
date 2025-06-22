`timescale 1ns / 1ps

module bit_replicator_1to4 (
    input logic in,
    output logic [3:0] out
);

    assign out = {4{in}};

endmodule