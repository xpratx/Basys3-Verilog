`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2025 10:22:14
// Design Name: 
// Module Name: up_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module seven_seg_decoder(
    input [3:0] digit,
    output reg[6:0] seg
    );
    
    always @(*) begin
    case (digit)
    4'h0: seg=7'b1000000;
    4'h1: seg=7'b1111001;
    4'h2: seg=7'b0100100;
    4'h3: seg=7'b0110000;
    4'h4: seg=7'b0011001;
    4'h5: seg=7'b0010010;
    4'h6:seg=7'b0000010;
    4'h7:seg=7'b1111000;
    4'h8:seg=7'b0000000;
    4'h9:seg=7'b0011000;
    4'hA:seg=7'b0001000;
    4'hB:seg=7'b0000011;
    4'hC:seg=7'b1000110;
    4'hD:seg=7'b0100001;
    4'hE:seg=7'b0000110;
    4'hF:seg=7'b0001110;
    endcase
    end
endmodule

module up_counter(
    input clk,
    input reset,
    output reg[6:0] seg,
    output reg[3:0] an
    
    );

    reg[7:0] counter = 0;
    wire[3:0] upper_nibble, lower_nibble;
    reg [3:0] digit;
    reg [19:0] refresh_counter = 0;
    wire [6:0] seg_out;
    reg[1:0] digit_select;
    reg [26:0] one_sec_clk;
    wire one_sec_enable;
    
    assign upper_nibble = counter[7:4];
    assign lower_nibble = counter[3:0];
    
    always @(posedge clk or posedge reset) begin
    if (reset ==1)
        one_sec_clk <= 0;
     
     else begin
        if(one_sec_clk >= 9999999)
            one_sec_clk <= 0;
           else
           one_sec_clk <= one_sec_clk + 1;
          end  
          
          end
     
     assign one_sec_enable = (one_sec_clk == 9999999) ? 1:0;
    
    always@(posedge one_sec_enable or posedge reset) begin
        if(reset)
        counter <= 0;
        
        else
        counter <= counter + 1;
        
       end
       
       
       //digit refresh logic
       always @(posedge clk) begin
       refresh_counter <= refresh_counter + 1;
       digit_select <= refresh_counter[19:18];  //selects digit ~0.25ms
       end
       
       //digit multiplexing
       always @(*) begin
       case(digit_select)
       2'b00: begin digit = lower_nibble; an = 4'b1110; end
       2'b01: begin digit = upper_nibble; an = 4'b1101; end
       default: begin digit = 4'b0000; an=4'b1111; end
       endcase
       end
       
       //segment decoder
       
       seven_seg_decoder decoder(.digit(digit), .seg(seg_out));
      
       assign seg_out = seg;
       
endmodule
