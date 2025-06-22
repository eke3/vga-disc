`timescale 1ns / 1ps

module top (
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic VGA_HS,
    output logic VGA_VS,
    input logic CLK100MHZ,
    input logic BTNC
);

    logic clk_150_, clk_50_, pix_clk_, reset_;
    logic locked_;
    logic rgb_ [2:0];
    logic [3:0] vga_rgb_ [2:0];
    logic hsync_, vsync_, blank_;
    logic [9:0] pos_h_, pos_v_;

    button_debouncer btn_debouncer_inst (
        .btnout(reset_),
        .btn(BTNC),
        .sys_clk(CLK100MHZ),
        .rst(1'b0)
    );
    
    clock_wizard clock_wizard_inst (
        .clk_out_150MHz(clk_150_),
        .clk_out_50MHz(clk_50_),
        .reset(reset_),
        .locked(locked_),
        .clk_in_100MHz(CLK100MHZ)
    );

    vga_sync_50MHz vga_sync_50MHz_inst (
        .clk(clk_50_),
        .hsync(hsync_),
        .vsync(vsync_),
        .hcount(pos_h_),
        .vcount(pos_v_),
        .pix_clk(pix_clk_),
        .blank(blank_)
    );

    vga_discs_controller vga_discs_controller_inst (
        .red(rgb_[0]),
        .green(rgb_[1]),
        .blue(rgb_[2]),
        .pos_h(pos_h_),
        .pos_v(pos_v_),
        .blank(blank_),
        .locked(locked_),
        .pix_clk(pix_clk_),
        .clk(clk_150_)
    );

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin
            bit_replicator_1to4 bit_replicator_1to4_inst (
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
