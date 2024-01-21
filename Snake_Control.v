`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 15:11:39
// Design Name: 
// Module Name: Snake_Control
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


module Snake_Control(
    input CLK,
    input RESET,
    input [18:0] Address,
    input [14:0] Random_Target_Address,
    output reg Reached_Target,
    input [1:0] Play_State,
    input [1:0] Direction_State,
    output reg [11:0] Colour
    );
    
    
    parameter MaxX = 159;
    parameter MaxY = 119;
    parameter SnakeLength  = 25;
    
    wire [8:0] Y = Address[8:0];
    wire [9:0] X = Address[18:8];
    
    wire Target_Address_Y = Random_Target_Address[6:0];
    wire Target_Address_X = Random_Target_Address[14:7];
     
    wire [25:0] Counter;
    
     simple_generic_counter # (.COUNTER_WIDTH(26),
                              .COUNTER_MAX(49999999)
                              )
                              Bit2Counter(
                                     .CLK(CLK),
                                     .RESET(RESET),
                                     .ENABLE(1'b1),
                                     .COUNT(Counter)
                                  ); 
    
    
    
   
    
    reg [7:0] SnakeState_X [0: SnakeLength -1];
    reg [6:0] SnakeState_Y [0: SnakeLength -1];
    
    //Changing the position of the snake registers
    //Shift the SnakeState X and Y
    genvar PixNo;
    generate
        for (PixNo = 0; PixNo < SnakeLength-1; PixNo = PixNo+1)
        begin: PixShift
            always@(posedge CLK) begin
                if(RESET) begin
                    SnakeState_X[PixNo+1] <= 80;
                    SnakeState_Y[PixNo+1] <= 100;
                end
                else if(Counter == 0) begin
                    SnakeState_X[PixNo+1] <= SnakeState_X[PixNo];
                    SnakeState_Y[PixNo+1] <= SnakeState_Y[PixNo];
                end
             end
          end
      endgenerate
      
      //Replace top snake state with new one based on direction
      always@(posedge CLK) begin
        if(RESET) begin
        //set the initial state of the snake
            SnakeState_X[0] <= 80;
            SnakeState_Y[0] <= 100;                    
        end
        else if (Counter == 0) begin
            case(Direction_State)
                2'b00   :begin //up
                    if(SnakeState_Y[0] == 0)
                        SnakeState_Y[0] <= MaxY;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] -1;
                    end

                2'b01   :begin //left
                    if(SnakeState_X[0] == 0)
                        SnakeState_X[0] <= MaxX;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] -1;
                    end

                2'b10   :begin //right
                    if(SnakeState_X[0] == 0)
                        SnakeState_X[0] <= MaxX;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] +1;
                    end

                2'b11   :begin //down
                    if(SnakeState_Y[0] == 0)
                        SnakeState_Y[0] <= MaxY;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] +1;
                    end
                    
            endcase
          end
       end     



//see if the target has been reached
    always@(posedge CLK) begin
        if(SnakeState_Y[0] == Target_Address_Y && SnakeState_X[0] == Target_Address_X)
            Reached_Target <= 1;
        else
            Reached_Target <= 0;
       end
      
      
      integer i;
      //colour output
      always@(posedge CLK) begin
                if(Play_State == 2'b01) begin
                        //Colour output for Snake (yellow) courtesy of colour picker
                      if(SnakeState_X[0]== X[9:2] && SnakeState_Y[0]==Y[8:2]) begin
                         Colour<=12'h0FF; 
                         end
                        //Colour output for target (red) courtesy of colour picker
                      else if(X[9:2] == Target_Address_X && Y[8:2]== Target_Address_Y) begin
                          Colour<=12'h00F; 
                          end
                       //Colour output for background (blue) courtesy of colour picker
                      else  begin
                          Colour<=12'hF00;
                          end 
                      
                      for(i=0; i<SnakeLength; i=i+1) begin
                         if(X[9:2]==SnakeState_X[i] && Y[8:2]==SnakeState_Y[i])
                             Colour<=12'h0FF; 
                      end
                end
        end
    
    
endmodule
