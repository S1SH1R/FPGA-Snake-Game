`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 16:32:28
// Design Name: 
// Module Name: Snake_Game_Top_wrapper
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

// There is an LED state machine which is used to indicate that the code is running whether its succesful or not. This way we know that if there is a fault it could be the hardware's fault and not the FPGA
//Msater State machines determines whether we are playing, idle or won. 
// Navigation state machine finds out which button is pressed and which state to put the snake in(up down left or right)
//I have created the test bench for the navigation state machine in the simulation sources.
//The 7 Segement display first displays the amount of time in the first two segements from the left and it counts down from 99 while the last two segements conut to 3 as the snake eats each target.


/////////////////////////////////////////////////////////////////////EPILESPSY WARNING WHEN YOU WIN AFTER EAATING 3 TARGETS////////////////////////////////////////////////////////////////



module Snake_Game_Top_wrapper(
    input CLK,
    input RESET,
    input BTNU,
    input BTND,
    input BTNL,
    input BTNR,
    input START_STOP,
    output [11:0] COLOUR_OUT,
    output HS,
    output VS,
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT,
    output [3:0] LED_OUT,
    output [3:0] LED_Display_SM_Out    
    );
    
    wire [1:0] MSM_State;
    wire [1:0] Direction_State;
    wire Reached_Target;
    wire [11:0] Colour;
    wire [6:0] Random_Target_Y;
    wire [7:0] Random_Target_X;
    wire [6:0] D_Random_Target_Y;
    wire [7:0] D_Random_Target_X;    
    wire [9:0] ADDRH; 
    wire [8:0] ADDRV;
    wire [3:0] Score;
    wire Body_hit;
    wire time_is_up;
    
    Snake_Game_Master_State_Machine Master_State_Machin(
      .BTNR(BTNR),
      .BTNL(BTNL),
      .BTND(BTND),
      .BTNU(BTNU),
      .CLK(CLK),
      .RESET(RESET),
      .Score(Score),
      .Play_State(MSM_State),
      .Body_hit(Body_hit),
      .time_is_up(time_is_up) 
      );
    
    Snake_Game_Navigation_State_Machine Navigation_State_Machine(
          .BTNR(BTNR),
          .BTNL(BTNL),
          .BTND(BTND),
          .BTNU(BTNU),
          .CLK(CLK),
          .RESET(RESET),
          .Direction_State(Direction_State)
          );  
          
     Snake_controller_2 Snake_Control(
              .CLK(CLK),
              .RESET(RESET),
              .ADDRH(ADDRH),
              .ADDRV(ADDRV),
              .Random_Target_Y(Random_Target_Y),
              .Random_Target_X(Random_Target_X),           
              .Reached_Target(Reached_Target),
              .Play_State(MSM_State),
              .Direction_State(Direction_State),
              .Colour(Colour),
              .Body_hit(Body_hit),
              .D_Random_Target_Y(D_Random_Target_Y),
              .D_Random_Target_X(D_Random_Target_X),                                   
              .START_STOP(START_STOP)
              );     
      
     Pseudo_Random_Number_Generator Target_Generator(
                  .CLK(CLK),
                  .RESET(RESET),
                  .Reached_Target(Reached_Target),
                  .Random_Target_Y(Random_Target_Y),
                  .Random_Target_X(Random_Target_X),
                  .D_Random_Target_Y(D_Random_Target_Y),
                  .D_Random_Target_X(D_Random_Target_X)                                        
                  ); 
                  
     Wrapper_VGA VGA_interface(                      
                      .CLK(CLK),
                      .COLOUR_OUT(COLOUR_OUT),
                      .HS(HS),
                      .Play_State(MSM_State),
                      .VS(VS),
                      .ADDRH(ADDRH),
                      .ADDRV(ADDRV),
                      .COLOUR_IN(Colour)
                      );            
                            
    Snake_Game_Timing_the_World_in_Decimal Score_Counter(
                          .CLK(CLK),
                          .RESET(RESET),
                          .SEG_SELECT(SEG_SELECT),
                          .DEC_OUT(HEX_OUT),
                          .Score(Score),
                          .Reached_Target(Reached_Target),
                          .Play_State(MSM_State),
                          .time_is_up(time_is_up) 
                          );
    
    LED_state_machine LED(
    .CLK(CLK),
    .RESET(RESET),
    .Play_State(CurrState),
    .LED_OUT(LED_OUT),
    .LED_Display_SM_Out(LED_STATE_Out)
        );
    
endmodule
