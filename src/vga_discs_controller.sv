`timescale 1ns / 1ps

module vga_discs_controller #(
    parameter X_CENTER_LEFT = 240,
    parameter X_CENTER_RIGHT = 400,
    parameter X_CENTER_MIDDLE = 320,
    parameter Y_CENTER_TOP = 160,
    parameter Y_CENTER_BOTTOM = 290,
    parameter RADIUS_TOP = 36,
    parameter RADIUS_BOTTOM = 142
) (
    output logic red,
    output logic green,
    output logic blue,
    input logic [9:0] pos_h,
    input logic [9:0] pos_v,
    input logic blank,
    input logic locked,
    input logic pix_clk,
    input logic clk
);

    typedef enum {
        S_DISC_LEFT,
        S_DISC_MIDDLE,
        S_DISC_RIGHT
    } state_t;

    logic [2:0] flag_on_disc;
    logic [2:0] mul_done;
    logic [2:0] mul_enable = 3'b0;
    state_t CS = S_DISC_LEFT, NS;

    // Disc 0: Left
    vga_disc #(
        .X_CENTER(X_CENTER_LEFT),
        .Y_CENTER(Y_CENTER_TOP),
        .RADIUS(RADIUS_TOP)
    ) vga_disc_left (
        .flag_on_disc(flag_on_disc[0]),
        .mul_done(mul_done[0]),
        .mul_enable(mul_enable[0]),
        .pos_h(pos_h),
        .pos_v(pos_v),
        .blank(blank),
        .locked(locked),
        .pix_clk(pix_clk),
        .clk(clk)
    );

    // Disc 1: Middle
    vga_disc #(
        .X_CENTER(X_CENTER_MIDDLE),
        .Y_CENTER(Y_CENTER_BOTTOM),
        .RADIUS(RADIUS_BOTTOM)
    ) vga_disc_middle (
        .flag_on_disc(flag_on_disc[1]),
        .mul_done(mul_done[1]),
        .mul_enable(mul_enable[1]),
        .pos_h(pos_h),
        .pos_v(pos_v),
        .blank(blank),
        .locked(locked),
        .pix_clk(pix_clk),
        .clk(clk)
    );

    // Disc 2: Right
    vga_disc #(
        .X_CENTER(X_CENTER_RIGHT),
        .Y_CENTER(Y_CENTER_TOP),
        .RADIUS(RADIUS_TOP)
    ) vga_disc_right (
        .flag_on_disc(flag_on_disc[2]),
        .mul_done(mul_done[2]),
        .mul_enable(mul_enable[2]),
        .pos_h(pos_h),
        .pos_v(pos_v),
        .blank(blank),
        .locked(locked),
        .pix_clk(pix_clk),
        .clk(clk)
    );

    always_ff @(posedge clk) begin
        red <= red; green <= green; blue <= blue; mul_enable <= mul_enable; CS <= CS; NS = CS;

        unique0 case (CS) inside
            S_DISC_LEFT: begin
                mul_enable[0] <= 1'b1;
                if (mul_done[0]) begin
                    mul_enable[0] <= 1'b0;
                    NS = S_DISC_MIDDLE;
                end
            end
            S_DISC_MIDDLE: begin
                mul_enable[1] <= 1'b1;
                if (mul_done[1]) begin
                    mul_enable[1] <= 1'b0;
                    NS = S_DISC_RIGHT;
                end
            end
            S_DISC_RIGHT: begin
                mul_enable[2] <= 1'b1;
                if (mul_done[2]) begin
                    mul_enable[2] <= 1'b0;
                    NS = S_DISC_LEFT;
                end
            end
        endcase
        CS <= NS;

        red <= |flag_on_disc;
        green <= 1'b0;
        blue <= 1'b0;
    end
endmodule