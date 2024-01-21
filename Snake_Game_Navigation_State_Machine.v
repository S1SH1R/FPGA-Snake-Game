`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 12:13:09
// Design Name: 
// Module Name: Snake_Game_Navigation_State_Machine
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


module Snake_Game_Navigation_State_Machine(
    input BTNR,
    input BTNL,
    input BTND,
    input BTNU,
    input CLK,
    input RESET,
    output [1:0] Direction_State
    );
    
    reg [1:0] CurrState;
    reg [1:0] NextState;
    
   //Sequential logic
   always@(posedge CLK) begin
      if(RESET)begin
         CurrState <= 2'h0;
      end
         else begin
              CurrState <= NextState;
      end
   end

    
    always@(CurrState or BTNU or BTND or BTNL or BTNR) begin
        case(CurrState)
        //Up direction state
            2'b00   : begin
                if(BTNL)
                    NextState <= 2'b01; //Left
                else if(BTNR)
                    NextState <= 2'b10; //Right
                else
                    NextState <= CurrState;
                end
            
            //Left direction state
            2'b01   : begin
                    if(BTND)
                        NextState <= 2'b11; //Down
                    else if(BTNU)
                        NextState <= 2'b00; //Up
                    else
                        NextState <= CurrState;
                    end 
                    
            //Right direction state        
            2'b10   : begin
                    if(BTND)
                        NextState <= 2'b11; //Down
                    else if(BTNU)
                        NextState <= 2'b00; //Up
                    else
                        NextState <= CurrState;
                    end 

                
         //Down direction state
            2'b11   : begin
                if(BTNL)
                    NextState <= 2'b01; //Left
                else if(BTNR)
                    NextState <= 2'b10; //Right
                else
                    NextState <= CurrState;
                end
                    
                 default : NextState <= 2'b00;
            endcase
         end      
         
    assign Direction_State = CurrState;
    
endmodule
