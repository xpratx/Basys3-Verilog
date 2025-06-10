`timescale 1ns / 1ps

module vga_circle_move (
    input clk_100MHz, 
    input move_L,
    input move_R,
    input move_U,
    input move_D, 
    input reset,
    output hsync,
    output vsync,
    output [11:0]vga_out
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

   reg [11:0]x_offsetL  ;
   reg [11:0]y_offsetU  ;
   reg [11:0]x_offsetR  ;
   reg [11:0]y_offsetD ;
    

    // VGA Timing parameters
    localparam H_ACTIVE = 1280;
    localparam H_FP = 48;
    localparam H_SYNC = 112;
    localparam H_BP = 248;
    localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP; 

    localparam V_ACTIVE = 1024;
    localparam V_FP = 1;
    localparam V_SYNC = 3;
    localparam V_BP = 38;
    localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP; 

    reg [11:0] h_count = 0;  
    reg [11:0] v_count = 0;
    wire [11:0] x;
    wire [11:0] y;  
    reg [11:0] color;

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
    assign active_area = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

   
   
   
    assign x = h_count;
    assign y = v_count;
    
    always@(posedge move_L) begin
    x_offsetL = x_offsetL +50;
    end
    
   always@(posedge move_R) begin
    x_offsetR = x_offsetR + 50;
    end
    
   always@(posedge move_U) begin
    y_offsetU = y_offsetU + 50;
    end 
    
    always@(posedge move_D) begin
    y_offsetD = y_offsetD + 50;
    end  
    
    always @ (posedge clk_108MHz )
    begin
        if (((x-640-x_offsetL+x_offsetR)*(x-640-x_offsetL+x_offsetR))+((y-512+y_offsetD-y_offsetU)*(y-512+y_offsetD-y_offsetU))<=625)
           color=12'b111100000000;
        else
          color=12'b000000000000;
     end  
   
    assign vga_out = color;
    
 endmodule
