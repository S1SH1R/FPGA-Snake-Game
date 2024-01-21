`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2022 19:15:58
// Design Name: 
// Module Name: Timing_the_World_in_Decimal
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


module Snake_Game_Timing_the_World_in_Decimal(
    input CLK,
    input RESET,
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT,
    output [3:0] Score,
    input Reached_Target,
    input [1:0] Play_State,
    output reg time_is_up
    );
    
    //Tested, functionality seems correct for score, dec_out and seg_select to be tested
    wire [3:0] Score_Count;
    wire[3:0] Bit4_score_1Count;        
    wire[3:0] Bit4_score_2Count;    
    wire Bit4_score_1TriggOut;
    wire Bit17TriggOut; 
    wire [1:0] StrobeCount;
    
    //for the timer
    wire Bit17tTriggOut;
    wire Bit4tTriggOut;
    wire Bit4t_2TriggOut;
    wire Bit4t_3TriggOut;
    wire Bit4t_4TriggOut;
    wire [3:0] Bit4t_4Count;
    wire [3:0] Bit4t_5Count;
    wire [3:0] Bit4t_3Count;
    wire [3:0] Bit4t_2Count;
    wire [3:0] Bit4tCount;
    
   //This controls the frequency of the strobe counter
   direction_generic_counter # (.COUNTER_WIDTH(17),
                       .COUNTER_MAX(99999)
                       )
                       Bit17Counter(
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .DIRECTION(1'b1),
                       .TRIG_OUT(Bit17TriggOut)
                       );
                       
   // wire Bit17TriggOut;
   
   //The strobe count goes through all the segment selects so fast that it seems instant -corresponds to the 2bit counter from timing the world in decimal                                          
    direction_generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                        )
                      Bit2Counter(
                         .CLK(CLK),
                         .RESET(1'b0),
                         .ENABLE(Bit17TriggOut),
                         .DIRECTION(1'b1),
                         .COUNT(StrobeCount)
                               );
    // wire StrobeCount;                       
  /*  direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                       Bit4Counter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Bit17TriggOut&&ENABLE),
                            .DIRECTION(DIRECTION),
                            .TRIG_OUT(Bit4TriggOut)
                         ); 

    // wire Bit4TriggOut;                          
                         
    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                       Bit4_2Counter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Bit4TriggOut),
                            .DIRECTION(DIRECTION),
                            .TRIG_OUT(Bit4_2TriggOut),
                            .COUNT(Bit4_2Count)
                       ); */
                   
    // wire Bit4_2TriggOut;                                                  

    //seperate counter for storing the score value using the 4 bit counter     
    direction_generic_counter # (.COUNTER_WIDTH(4),
                                 .COUNTER_MAX(10)
                                )
                      Bit_Score_Counter(
                             .CLK(CLK),
                             .RESET(RESET),
                             .ENABLE(Reached_Target),
                             .DIRECTION(1'b1),
                             .COUNT(Score_Count)
                      );

   //Using the right 2 displays for displaying the score using the two 4 bit counters
   //Counts every time the target is reached by the snake                     
    direction_generic_counter # (.COUNTER_WIDTH(4),
                                 .COUNTER_MAX(9)
                       )
                      Bit4_score_1Counter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Reached_Target),
                            .DIRECTION(1'b1),
                            .TRIG_OUT(Bit4_score_1TriggOut),
                            .COUNT(Bit4_score_1Count)
                         );
    // wire Bit4_3TriggOut;                         
    //Counts every time a trigger out signal is sent by the previous bit4_3 counter. This means when the target is reached 9 times, this counter will increment
    // therefore displaying 1 on the 2nd segment and 0 on the first segment displaying 10.
    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(1)
                       )
                      Bit4_score_2Counter(
                             .CLK(CLK),
                             .RESET(RESET),
                             .ENABLE(Bit4_score_1TriggOut),
                             .DIRECTION(1'b1),
                             //.TRIG_OUT(Bit4_4TriggOut),
                             .COUNT(Bit4_score_2Count)
                      );

   // wire Bit4_4TriggOut;


    //start timer of 60 seconds or 59.99s
    reg Timer_enable;
    initial begin
          Timer_enable <= 0;
          end      
        
    always@(posedge CLK) begin
        if(Play_State == 2'b01)     //when the game starts
            Timer_enable <= 1;
        else
            Timer_enable <= 0;
         end 

//starting the timer using the counters and the time will be displayed on the left 2 segment displays
   direction_generic_counter # (.COUNTER_WIDTH(17),
                       .COUNTER_MAX(99999)
                       )
                       Bit17tCounter(
                       .CLK(CLK),
                       .RESET(RESET),
                       .ENABLE(Timer_enable),
                       .DIRECTION(1'b0),
                       .TRIG_OUT(Bit17tTriggOut)
                       );

    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                       Bit4tCounter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Bit17tTriggOut),
                            .DIRECTION(1'b0),
                            .TRIG_OUT(Bit4tTriggOut),
                            .COUNT(Bit4tCount)
                         ); 

    // wire Bit4TriggOut;                          
                         
    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                       Bit4t_2Counter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Bit4tTriggOut),
                            .DIRECTION(1'b0),
                            .TRIG_OUT(Bit4t_2TriggOut),
                            .COUNT(Bit4t_2Count)                            
                       );
                   
    // wire Bit4_2TriggOut;                                                  
                        
    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                      Bit4t_3Counter(
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(Bit4t_2TriggOut),
                            .DIRECTION(1'b0),
                            .TRIG_OUT(Bit4t_3TriggOut),
                            .COUNT(Bit4t_3Count)                                                        
                         );




    direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                      Bit4t_4Counter(
                             .CLK(CLK),
                             .RESET(RESET),
                             .ENABLE(Bit4t_3TriggOut),
                             .DIRECTION(1'b0),
                             .TRIG_OUT(Bit4t_4TriggOut),
                             .COUNT(Bit4t_4Count)
                         );           

     direction_generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                       )
                      Bit4t_5Counter(
                             .CLK(CLK),
                             .RESET(RESET),
                             .ENABLE(Bit4t_4TriggOut),
                             .DIRECTION(1'b0),
                             .COUNT(Bit4t_5Count)
                         );            
                         
    reg initiation;
    initial begin
    initiation <=0;
    end
                                                    
     always@(posedge CLK) begin
        if(RESET)
            initiation <=0;    
        else if(Bit4t_5Count == 5) 
            initiation <= 1;
        else
            initiation <= initiation;
            end
    
    initial begin
        time_is_up <= 0;
        end     
         
                                    
    always@(posedge CLK) begin
        if(RESET)
            time_is_up <= 0;
        else if(Play_State == 2'b01)
            if(initiation)
                if(Bit4t_5Count == 0 && Bit4t_4Count == 0 && Bit4t_3Count == 0 && Bit4t_2Count == 0 && Bit4tCount == 0)
                    time_is_up <= 1;
         end

                      
    //wire[3:0] Bit4_2Count;
    //wire[3:0] Bit4_3Count;
    //wire[3:0] Bit4_4Count;
    //wire[3:0] Bit4_5Count;                                             
    reg [4:0] DecCountAndDot0;
    reg [4:0] DecCountAndDot1;
    reg [4:0] DecCountAndDot2;
    reg [4:0] DecCountAndDot3;
    
    wire [4:0] F;
    wire [4:0] A;
    wire [4:0] I;
    wire [4:0] L;
    
    wire [4:0] MuxOut;
    
    assign F = {1'b0, 4'b1111};
    assign A = {1'b0, 4'b1010};
    assign I = {1'b0, 4'b1100};
    assign L = {1'b0, 4'b1101};
    
    always@(posedge CLK) begin
        if(Play_State == 2'b11) begin
            DecCountAndDot0 <= L;
            DecCountAndDot1 <= I;
            DecCountAndDot2 <= A;
            DecCountAndDot3 <= F;
            end
         else begin
            DecCountAndDot0 <= {1'b0, Bit4_score_1Count};
            DecCountAndDot1 <= {1'b0, Bit4_score_2Count};
            DecCountAndDot2 <= {1'b0, Bit4t_4Count};
            DecCountAndDot3 <= {1'b0, Bit4t_5Count};
                   end  
            end
        /*DecCountAndDot0 <= {1'b0, Bit4_score_1Count};
                        DecCountAndDot1 <= {1'b0, Bit4_score_2Count};
                        DecCountAndDot2 <= {1'b0, Bit4t_4Count};
                        DecCountAndDot3 <= {1'b0, Bit4t_5Count};
                        */
                
    Multiplexer mux4(
        .CONTROL(StrobeCount),
        .IN0(DecCountAndDot0),
        .IN1(DecCountAndDot1),
        .IN2(DecCountAndDot2),
        .IN3(DecCountAndDot3),
        .OUT(MuxOut)
        );
        
            assign Score = Score_Count; //Can replace values with bit4_3 to 6 to see if they function properly using Test bench
        
        
   Decoding_the_world Seg7(
                .SEG_SELECT_IN(StrobeCount),
                .BIN_IN(MuxOut[3:0]),
                .DOT_IN(MuxOut[4]),
                .SEG_SELECT_OUT(SEG_SELECT),
                .HEX_OUT(DEC_OUT)
                );

endmodule
