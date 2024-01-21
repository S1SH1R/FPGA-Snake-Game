`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2022 21:21:14
// Design Name: 
// Module Name: VGA_Interface
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


module VGA_Interface(
    input CLK, 
    input [11:0] COLOUR_IN, 
    output reg [9:0] ADDRH, 
    output reg [8:0] ADDRV, 
    output reg [11:0] COLOUR_OUT, 
    output reg HS,
    output reg VS
    );
    
    
    
    //Time is Vertical Lines 
    parameter VertTimeToPulsewidthEnd = 10'd2;
    parameter VertTimeToBackPorchEnd = 10'd31; 
    parameter VertTimeToDisplayTimeEnd = 10'd511; 
    parameter VertTimeToFrontPorchEnd = 10'd521;
    
    //Time is Front Horizontal Lines 
    parameter HorzTimeToPulseWidthEnd = 10'd96; 
    parameter HorzTimeToBackPorchEnd = 10'd144; 
    parameter HorzTimeToDisplayTimeEnd = 10'd784; 
    parameter HorzTimeToFrontPorchEnd = 10'd800;
    
    wire BitHSTriggOut;
    wire BitVSTriggOut;
    wire Bit2triggOut;
    wire [9:0] BitHSCount;
    wire [9:0] BitVSCount;
    
     simple_generic_counter # (.COUNTER_WIDTH(2),
                           .COUNTER_MAX(3)
                           )
                           Bit2Counter(
                                  .CLK(CLK),
                                  .RESET(1'b0),
                                  .ENABLE(1'b1),
                                  .TRIG_OUT(Bit2triggOut)
                               ); 
    
    
    
    
     simple_generic_counter # (.COUNTER_WIDTH(10),
                        .COUNTER_MAX(799)
                        )
                        Bit10_HSCounter(
                               .CLK(CLK),
                               .RESET(1'b0),
                               .ENABLE(Bit2triggOut),
                               .TRIG_OUT(BitHSTriggOut),
                               .COUNT(BitHSCount)
                            ); 
                            
     simple_generic_counter # (.COUNTER_WIDTH(10),
                        .COUNTER_MAX(520)
                        )
                        Bit10_VSCounter(
                             .CLK(CLK),
                             .RESET(1'b0),
                             .ENABLE(BitHSTriggOut),
                             .TRIG_OUT(BitVSTriggOut),
                             .COUNT(BitVSCount)
                                        ); 
    
    
    
    // logic defining the vs and hs states 
    always@(posedge CLK) begin
        if(BitVSCount < VertTimeToPulsewidthEnd)
                VS <= 0;
              else
                  VS <= 1;
          end
          
    always@(posedge CLK) begin
        if(BitHSCount < HorzTimeToPulseWidthEnd) 
            HS <= 0;
        else
            HS <= 1;
    end
    
    
    //logic defining the colour out state
    always@(posedge CLK) begin
        if((VertTimeToBackPorchEnd < BitVSCount) & (BitVSCount < VertTimeToDisplayTimeEnd) & (HorzTimeToBackPorchEnd < BitHSCount) & (BitHSCount < HorzTimeToDisplayTimeEnd))
                COLOUR_OUT <= COLOUR_IN;
        else 
            COLOUR_OUT <= 0;
   end

    //horizontal address pixel state
    always@(posedge CLK) begin
        if((VertTimeToBackPorchEnd < BitVSCount) & (BitVSCount < VertTimeToDisplayTimeEnd) & (HorzTimeToBackPorchEnd < BitHSCount) & (BitHSCount < HorzTimeToDisplayTimeEnd))
                    ADDRH <= BitHSCount - HorzTimeToBackPorchEnd; // same speed increment as BitHSCount;
            else 
                ADDRH <= 0;
       end
       
     //vertical address pixel state
     always@(posedge CLK) begin
        if((VertTimeToBackPorchEnd < BitVSCount) & (BitVSCount < VertTimeToDisplayTimeEnd) & (HorzTimeToBackPorchEnd < BitHSCount) & (BitHSCount < HorzTimeToDisplayTimeEnd))        
                ADDRV <= BitVSCount - VertTimeToBackPorchEnd; // same speed increment as BitHSCount;
         else 
            ADDRV <= 0;
     end
            
            
    
endmodule