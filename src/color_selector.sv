`timescale 1ns / 1ps

module color_selector (
    output logic red,
    output logic green,
    output logic blue,
    input logic [2:0] switch
);

    assign {red, green, blue} = switch;
    
endmodule