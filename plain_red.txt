`timescale 1ns / 1ps

module vga_controller (
    input clk_100MHz,  // Basys3 100 MHz clock
    input reset,
    output hsync,
    output vsync,
    output [3:0] vga_r, // 4-bit VGA red
    output [3:0] vga_g, // 4-bit VGA green
    output [3:0] vga_b  // 4-bit VGA blue
);

    wire clk_108MHz;  // pixel clock for 1280x1024@60Hz
    wire locked;

    // Instantiate PLL to generate 108 MHz from 100 MHz
    clk_wiz_0 pll_inst (
        .clk_in1(clk_100MHz),
        .reset(reset),
        .clk_out1(clk_108MHz),
        .locked(locked)
    );

    // VGA Timing parameters
    localparam H_ACTIVE = 1280;
    localparam H_FP = 48;
    localparam H_SYNC = 112;
    localparam H_BP = 248;
    localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP; //1688

    localparam V_ACTIVE = 1024;
    localparam V_FP = 1;
    localparam V_SYNC = 3;
    localparam V_BP = 38;
    localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP; //1066

    reg [11:0] h_count = 0;  // enough bits for 1688
    reg [11:0] v_count = 0;  // enough bits for 1066

    // Horizontal and vertical counters
    always @(posedge clk_108MHz or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Generate sync signals (active low)
    assign hsync = ~((h_count >= (H_ACTIVE + H_FP)) && (h_count < (H_ACTIVE + H_FP + H_SYNC)));
    assign vsync = ~((v_count >= (V_ACTIVE + V_FP)) && (v_count < (V_ACTIVE + V_FP + V_SYNC)));

    // Display enable signal
    wire active_area = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

    // Output red color only during active area, else black
    assign vga_r = 4'b0000; 
    assign vga_g = active_area ? 4'b1111 : 4'b0000;
    assign vga_b = 4'b0000;

endmodule

