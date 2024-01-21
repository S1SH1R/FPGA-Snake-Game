`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 12:48:02
// Design Name: 
// Module Name: Pseudo_Random_Number_Generator
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


module Pseudo_Random_Number_Generator(
    input RESET,
    input CLK,
    input Reached_Target,
    output reg [6:0] Random_Target_Y,
    output reg [7:0] Random_Target_X,
    output reg [6:0] D_Random_Target_Y,
    output reg [7:0] D_Random_Target_X    
    );
    
    //two linear feedback registers, 8 bit and 7 bit
    // 7bit, xnor form  7,6
    // 8bit, xnor form  8,6,5,4
    
    //the linear feedback registers
    reg [6:0] LFSR_7;
    reg [7:0] LFSR_8;  
    //reg [6:0] D_LFSR_7;
    //reg [7:0] D_LFSR_8;  
    
    wire feedback;
    wire feedback_2;
   
    assign feedback = LFSR_7[6] ~^ LFSR_7[5];
    assign feedback_2 = LFSR_8[7] ^ ~LFSR_8[5] ^ ~LFSR_8[4] ^ ~LFSR_8[3];
    
    //wire D_feedback;
    //wire D_feedback_2;
   
    //assign D_feedback = D_LFSR_7[6] ~^ D_LFSR_7[5];
    //assign D_feedback_2 = D_LFSR_8[7] ^ ~D_LFSR_8[5] ^ ~D_LFSR_8[4] ^ ~D_LFSR_8[3];
    
    parameter MaxX = 159;
    parameter MaxY = 129;
    
    always@(posedge CLK) begin
        if(RESET) begin
           LFSR_7 <= 20;
           LFSR_8 <= 50;
           Random_Target_Y <= 20;
           Random_Target_X <= 50;
           //D_LFSR_7 <= 30; //for normal resolution 60, for zoomed in 30
           //D_LFSR_8 <= 30; //for normal resolution 100, for zoomed in 30
           //D_Random_Target_Y <= 30;
           //D_Random_Target_X <= 30;
           end
            
        else begin
           LFSR_7 <= {LFSR_7[5:0], feedback};
           LFSR_8 <= {LFSR_8[6:0], feedback_2};
           //D_LFSR_7 <= {D_LFSR_7[5:0], feedback};
           //D_LFSR_8 <= {D_LFSR_8[6:0], feedback_2}; 
                     
        if(Reached_Target) begin 
           Random_Target_Y <= LFSR_7;
           Random_Target_X <= LFSR_8;
           //D_Random_Target_Y <= D_LFSR_7;
           //D_Random_Target_X <= D_LFSR_8;                                                            
         end               
         
        else begin
           Random_Target_Y <= Random_Target_Y;
           Random_Target_X <= Random_Target_X;
           //D_Random_Target_Y <= D_Random_Target_Y;
           //D_Random_Target_X <= D_Random_Target_X;
             if(Random_Target_Y > MaxY) begin 
                Random_Target_Y <= MaxY - 10;
             end
             else if(Random_Target_X > MaxX) begin
                Random_Target_X <= MaxX - 20;
             end
             else if(Random_Target_X == 0) begin
                Random_Target_X <= Random_Target_X + 20;
             end
             else if(Random_Target_Y == 0) begin
                Random_Target_Y <= Random_Target_Y + 10;
             end
                      
             /*else if(D_Random_Target_Y > MaxY) begin
                D_Random_Target_Y <= MaxY - 20;
             end
             
             else if(D_Random_Target_X > MaxX) begin
                D_Random_Target_X <= MaxX - 30;
             end
             
             else if(D_Random_Target_X == 0) begin
                D_Random_Target_X <= D_Random_Target_X + 30;
             end
             
             else if(D_Random_Target_Y == 0) begin
                D_Random_Target_Y <= D_Random_Target_Y + 20;
             end
             
             else if(D_Random_Target_X == Random_Target_X) begin
                 D_Random_Target_X <= D_Random_Target_X + 50;
             end
             
             else if(D_Random_Target_Y == Random_Target_Y) begin
                 D_Random_Target_Y <= D_Random_Target_Y + 50;
             end
               */                               
           end           
       end
    end
            
            
   /* always@(posedge CLK) begin
        if(Random_Target_Y > MaxY)
            Random_Target_Y <= MaxY - 10;
        else if(Random_Target_X > MaxX)
            Random_Target_X <= MaxX - 20;
          end */            
    
    
    
endmodule
