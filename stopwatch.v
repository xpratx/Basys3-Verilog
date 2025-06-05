`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2025 11:06:00
// Design Name: 
// Module Name: stopwatch
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
/////////////////////////////////////////////////////////////////////////////////
    
    
    module seven_seg_decoder(input [3:0]digit, output reg[6:0] seg);
    
    
    always @(*) begin
    case(digit)
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
    
module stopwatch(
    input reset,
    input stop,
    input clk,
    input start,
    output reg[3:0] an,
    output reg[6:0] segment
    );
    
    reg[7:0] count = 0;
    reg[27:0] one_sec_clk =0;
    wire one_sec_enable;
    reg[19:0] refresh_counter=0;
    wire[3:0] lower_nibble, upper_nibble;
    wire anode_select;
    reg[3:0] digit;
    wire[6:0] seg_out;
    
    
    
      always @(posedge clk or posedge reset) begin
    if (reset ==1)
        one_sec_clk <= 0;
     
     else begin
        if(one_sec_clk >= 99999999)
            one_sec_clk <= 0;
           else
           one_sec_clk <= one_sec_clk + 1;
          end  
          
          end
     
     assign one_sec_enable = (one_sec_clk == 99999999) ? 1:0;
            
            
 always @(posedge one_sec_enable or posedge reset) 
 begin
    if (reset)
       count <= 0;
    
    else
     count <= count +1;
 end
    
    
 
 always @(posedge clk or posedge reset) 
 begin
 
    if(reset)
      refresh_counter <= 0;
    
    else
      refresh_counter <= refresh_counter + 1;
    
end    
    
 
    
 assign lower_nibble = count[3:0] ;
 assign upper_nibble = count[7:4];
 
 assign anode_select = refresh_counter[18];
 
 
 always @(*) 
 begin
    case(anode_select)
        1'b0 : begin an = 4'b1110;  digit = lower_nibble; end
        
        1'b1 : begin an= 4'b1101; digit = upper_nibble; end
    
    endcase
 end
    
   
 seven_seg_decoder decoder(.digit(digit), .seg(seg_out));
   
 assign seg_out = segment;
    
    
endmodule
