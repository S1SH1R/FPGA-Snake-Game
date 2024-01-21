`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 12:00:57
// Design Name: 
// Module Name: Snake_Game_Master_State_Machine
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


module Snake_Game_Master_State_Machine(
   input BTNR,
   input BTNL,
   input BTND,
   input BTNU,
   input CLK,
   input RESET,
   input [3:0] Score,
   output [1:0] Play_State,
   input Body_hit,
   input time_is_up
    );
    
    //Tested, functionality seems correct
    
    reg [1:0] CurrState;
    reg [1:0] NextState;
    
    assign Play_State = CurrState;
    
        //Sequential logic
               always@(posedge CLK) begin
                 if(RESET)begin
                   CurrState <= 2'h0;
                 end
                 else begin
                     CurrState <= NextState;
                 end
              end

    always@(CurrState or BTNU or BTND or BTNL or BTNR or Score or Body_hit or time_is_up) begin
        case(CurrState)
        //idle state
            2'b00   : begin
                if(BTNL | BTNR | BTND)
                    NextState <= 2'b01; //going to  play state
                else if(BTNU)
                    NextState <= 2'b11; //going to LED state
                else
                    NextState <= CurrState;
                end
            
            //play state
            2'b01   : begin
                    if(Score > 2)
                        NextState <= 2'b10;     //going to win state
                    else if(Body_hit || time_is_up) //snake hits itself or the allowed play time is over, it goes to lose state
                        NextState <= 2'b11; 
                    else
                        NextState <= CurrState;
                    end 
                    
             //Win State       
            2'b10   : begin
                     NextState <= CurrState;
                end
                
           //LED State
            2'b11   : begin
                    NextState <= CurrState;
                end
                                    
                 default : NextState <= 2'b00;
            endcase
         end      
         
endmodule
