`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2022 15:57:20
// Design Name: 
// Module Name: Wrapper_Vlog
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
module Wrapper_VGA(
    input [11:0] COLOUR_IN,
    input CLK,
    input [1:0] Play_State,
    output [11:0] COLOUR_OUT,
    output HS,
    output VS,
    output [9:0] ADDRH, 
    output [8:0] ADDRV
    );
  wire [11:0] Colour;
  
       Some_logic sm(
       .X(ADDRH),
       .Y(ADDRV),
       .Colour_in(COLOUR_IN),
       .Colour(Colour),
       .Play_State(Play_State),
       .CLK(CLK)
       );  

       VGA_Interface VGA_I(
       .CLK(CLK), 
       .COLOUR_IN(Colour),  //put colour_in here if you want to use the slide switches
       .COLOUR_OUT(COLOUR_OUT), 
       .HS(HS),
       .VS(VS),
       .ADDRH(ADDRH), 
       .ADDRV(ADDRV) 
       );
       
endmodule
