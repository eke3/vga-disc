`timescale 1ns / 1ps

module top_rectangle(
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic VGA_HS,
    output logic VGA_VS,
    input logic CLK100MHZ
);

    logic rgb_ [2:0];
    logic [3:0] vga_rgb_ [2:0];
    logic hsync_, vsync_, blank_;
    logic [9:0] pos_h_, pos_v_;

    vga_sync vga_sync_inst(
        .clk(CLK100MHZ),
        .hsync(hsync_),
        .vsync(vsync_),
        .hcount(pos_h_),
        .vcount(pos_v_),
        .pix_clk(),
        .blank(blank_)
    );

    vga_rectangle vga_rectangle_inst(
        .red(rgb_[0]),
        .green(rgb_[1]),
        .blue(rgb_[2]),
        .pos_h(pos_h_),
        .pos_v(pos_v_),
        .blank(blank_),
        .clk(CLK100MHZ)
    );

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin
            bit_replicator_1to4 bit_replicator_1to4_inst(
                .in(rgb_[i]),
                .out(vga_rgb_[i])
            );
        end
    endgenerate

    assign VGA_R = vga_rgb_[0];
    assign VGA_G = vga_rgb_[1];
    assign VGA_B = vga_rgb_[2];
    assign VGA_HS = hsync_;
    assign VGA_VS = vsync_;

endmodule

