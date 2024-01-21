`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2022 22:15:48
// Design Name: 
// Module Name: Seg7display
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


    module Seg7display(
        input [3:0] Slide,
        output [11:0] OUT
    );

    wire [3:0] SEG_SELECT_OUT;
    wire [7:0] HEX_OUT;
    reg [3:0] BIN_IN;
    
    Decoding_the_world uut(
        .SEG_SELECT_IN(SEG_SELECT_IN),
        .BIN_IN(BIN_IN),
        .DOT_IN(DOT_IN),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
    );

    wire [3:0] Slide;
    wire [11:0] OUT;
    
    assign OUT[0] = SEG_SELECT_OUT[0];
    assign OUT[1] = SEG_SELECT_OUT[1];
    assign OUT[2] = SEG_SELECT_OUT[2];
    assign OUT[3] = SEG_SELECT_OUT[3];
    
    assign OUT[4] = HEX_OUT[0];
    assign OUT[5] = HEX_OUT[1];
    assign OUT[6] = HEX_OUT[2];
    assign OUT[7] = HEX_OUT[3];
    assign OUT[8] = HEX_OUT[4];
    assign OUT[9] = HEX_OUT[5];
    assign OUT[10] = HEX_OUT[6];
    assign OUT[11] = HEX_OUT[7];
    
    //Hard wiring the first segment to be on
    assign OUT[0] = 0;
    assign OUT[1] = 0;
    assign OUT[2] = 0;
    assign OUT[3] = 0;
    
    //Hard wiring the dot to be 0
    assign OUT[11] = 1;
    
    //inputs 
    assign Slide[0] = BIN_IN[0];
    assign Slide[1] = BIN_IN[1];
    assign Slide[2] = BIN_IN[2];
    assign Slide[3] = BIN_IN[3];

  
    
endmodule
