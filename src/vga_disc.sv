`timescale 1ns / 1ps

module vga_disc #(
    parameter X_CENTER = 320,
    parameter Y_CENTER = 290,
    parameter RADIUS   = 36
) (
    output logic flag_on_disc,
    output logic mul_done,
    input logic [9:0] pos_h,
    input logic [9:0] pos_v,
    input logic blank,
    input logic locked,
    input logic mul_enable,
    input logic pix_clk,
    input logic clk // 150 MHz
);

    typedef enum {
        S_SUBTRACTIONS,
        S_MUL_X,
        S_MUL_Y,
        S_MUL_R
    } state_t;

    logic capture_pos = 0;
    logic [9:0] h, v;
    logic signed [10:0] sub_x = 0, sub_y = 0;
    logic signed [20:0] mul_x = 0, mul_y = 0, rad_squared = 0;
    state_t CS = S_SUBTRACTIONS, NS;


    assign flag_on_disc = ((mul_x + mul_y) < rad_squared) && ~blank;
    
    always_ff @(posedge pix_clk) begin
        capture_pos <= 1'b0; h <= h; v <= v;
        if (locked) begin
            h <= pos_h;
            v <= pos_v;
            capture_pos <= 1'b1;
        end 
    end

    always_ff @(posedge clk) begin
        sub_x <= sub_x; sub_y <= sub_y; mul_x <= mul_x; mul_y <= mul_y; rad_squared <= rad_squared; CS <= CS; NS = CS;
        unique0 case (CS) inside
            S_SUBTRACTIONS: begin
                mul_done <= 1'b0;
                if (capture_pos) begin
                    sub_x <= h - X_CENTER;
                    sub_y <= v - Y_CENTER;
                    NS = S_MUL_X;
                end
            end
            S_MUL_X: begin
                if (mul_enable) begin
                    mul_x <= sub_x * sub_x;
                    NS = S_MUL_Y;
                end
            end
            S_MUL_Y: begin
                mul_y <= sub_y * sub_y;
                NS = S_MUL_R;
            end
            S_MUL_R: begin
                rad_squared <= RADIUS * RADIUS;
                mul_done <= 1'b1;
                NS = S_SUBTRACTIONS;
            end
        endcase
        CS <= NS;
    end
endmodule
