`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2022 17:19:25
// Design Name: 
// Module Name: Snake_controller_2
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

//Controls how fast the snake moves using the counter and counter max
//Controls, with START_STOP switch0, when the VGA DISPLAY freezes and only the VGA.
//Controls the movement of the snake pixel while initialising it and sets the colour of background, snake and target.
//Identigies when the snake hits the targets

module Snake_controller_2(
    input CLK,
    input RESET,
    input [9:0] ADDRH, 
    input [8:0] ADDRV, 
    input [6:0] Random_Target_Y,    //target generator to score the points
    input [7:0] Random_Target_X,    //target generator to score the points
    input [6:0] D_Random_Target_Y,  //target generator for death
    input [7:0] D_Random_Target_X,  //target generator for death      
    input [1:0] Play_State,
    input [1:0] Direction_State,
    input START_STOP,  
    output reg Body_hit,
    output reg Reached_Target,
    output reg [11:0] Colour
    );
    
    parameter MaxX = 159;          //79 is the reduced resolution for thick dimension, original is 159
    parameter MaxY = 119;          //59 is the reduced resolution for thick dimension, original is 119
    parameter SnakeLength = 20;
    
    reg [26:0] Counter;
    reg [26:0] Counter_Max;
    
    initial begin
       Counter_Max <= 10000000;
      end
  
      
    
    always@(posedge CLK) begin
        if(RESET)
          Counter_Max <= 10000000;            
        else if(Reached_Target)
          Counter_Max <= Counter_Max - 500000;   //to increase the speed of the snake when the snoke hits the target
        else
          Counter_Max <= Counter_Max;
        end
      
    always@(posedge CLK) begin
        if(RESET)
            Counter <= 0;
        else if(!START_STOP)begin //Freeze only the VGA display as it stops countdown.
            if(Play_State == 2'b01) begin   //when the game starts
                if(Counter == Counter_Max)  //speed of snake is minimum
                    Counter <= 0;
                else
                    Counter <= Counter + 1;
                end
            end
        end
   
    //Snake is a 2 dimensional shift register, 1 dimension representing x, 1 dimension representing y
    //Snake_X * Snakelength and Snake_Y * Snakelength. Where 15 bits are split between X and Y, 8 and 7 bits respectively * the snake length
    //Making 2 2 dimensional shift registers
    
    reg [7:0] SnakeState_X [0: SnakeLength -1];
    reg [6:0] SnakeState_Y [0: SnakeLength -1];
    reg Body_hit_side;      //hitting the boundaries
    
    integer i;
    initial begin
        Body_hit_side <= 0;
        for (i = 1; i < SnakeLength; i = i + 1) begin
                           SnakeState_X[i] <= SnakeLength - i;
                           SnakeState_Y[i] <= SnakeLength;
                       end
        end            
               
//How to represent a snake     
//Replace top snake state with new one based on direction
         always@(posedge CLK) begin
           if(RESET || Play_State == 2'b00) begin       //at the start state
           //set the initial state of the snake
               SnakeState_X[0] <= 20;       //initilizing the position of the snake
               SnakeState_Y[0] <= 20;
                                  
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
                       if(SnakeState_X[0] == MaxX)  
                           SnakeState_X[0] <= 0; 
                       else
                           SnakeState_X[0] <= SnakeState_X[0] +1;
                       end
   
                   2'b11   :begin //down
                       if(SnakeState_Y[0] == MaxY)
                           SnakeState_Y[0] <= 0; 
                       else
                           SnakeState_Y[0] <= SnakeState_Y[0] +1;
                       end
                       
                    default: SnakeState_X[0] <= SnakeState_X[0];                       
               endcase
               for (i = SnakeLength - 1; i > 0; i = i-1) begin
                           SnakeState_X[i] = SnakeState_X[i - 1];
                           SnakeState_Y[i] = SnakeState_Y[i - 1];
                       end
             end
          end     

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
    
    //How to display a snake    
    
   //if the pixel address belongs to the target display red, if it belongs to the snake display yellow and the background is blue
   //hF00 is blue, h00F is red and h0F0 is green
    always@(posedge CLK) begin
        //Head
        if((SnakeState_X[0] == ADDRH[9:2]) && (SnakeState_Y[0] == ADDRV[8:2])) //starts from 3 because of reduced resolution
           Colour <= 12'h000;   //black
        //Fruit (target)     
        else if(ADDRH[9:2] == Random_Target_X && ADDRV[8:2] == Random_Target_Y)
            Colour <= 12'h0F0;      //green
        //Body of the snake    
        else if((SnakeState_X[i] == ADDRH[9:2]) && (SnakeState_Y[i] == ADDRV[8:2])&&Counter ==0) 
            Colour <= 12'h0FF;  //yellow
         //Background  
        else  
            Colour <= 12'hF00;      //blue
    end
           
        //How to determine if a target has been found
        always@(posedge CLK) begin
        //head of the snake meets the target
         if((SnakeState_X[0] == Random_Target_X) && (SnakeState_Y[0] == Random_Target_Y) && (Counter == 0)) 
            Reached_Target <= 1;
         else
            Reached_Target <= 0;
         end

       //This indicates when the snake moves from its initial position, to make sure body hit does not go off instantly
       reg pixshiftamount;
       parameter SnakeStartValue = 1; //Make sure to make the starting snake value less than Snakemaxlength -10 or 40 - 10 = 30.
          initial begin
             pixshiftamount = 0;
          end
             
          always@(posedge CLK) begin
             if(RESET)
                 pixshiftamount <= 0;
             else if(SnakeState_X[SnakeStartValue] != 80 || SnakeState_Y[SnakeStartValue] != 100)
                 pixshiftamount <= 1;
             else
                 pixshiftamount <= pixshiftamount;
           end          
           
           
           
         endmodule   
        
 
            
    
//       //White fruit (death target)
//       if(ADDRH[9:3] == D_Random_Target_X && ADDRV[8:3] == D_Random_Target_Y)
//           Colour <= 12'hFFF;
 
     
//       //Snake body to tail for different colours
//        else if((SnakeState_X[1] == ADDRH[9:3]) && (SnakeState_Y[1] == ADDRV[8:3]) && Body_increment > 1) 
//           Colour <= 12'h000;
//        else if((SnakeState_X[2] == ADDRH[9:3]) && (SnakeState_Y[2] == ADDRV[8:3]) && Body_increment > 2) 
//           Colour <= 12'hFFF;
//        else if((SnakeState_X[3] == ADDRH[9:3]) && (SnakeState_Y[3] == ADDRV[8:3]) && Body_increment > 3) 
//           Colour <= 12'h000;
//        else if((SnakeState_X[4] == ADDRH[9:3]) && (SnakeState_Y[4] == ADDRV[8:3]) && Body_increment > 4) 
//           Colour <= 12'hFFF;
//        else if((SnakeState_X[5] == ADDRH[9:3]) && (SnakeState_Y[5] == ADDRV[8:3]) && Body_increment > 5) 
//           Colour <= 12'h000;
//        else if((SnakeState_X[6] == ADDRH[9:3]) && (SnakeState_Y[6] == ADDRV[8:3]) && Body_increment > 6) 
//           Colour <= 12'hFFF;
//        else if((SnakeState_X[7] == ADDRH[9:3]) && (SnakeState_Y[7] == ADDRV[8:3]) && Body_increment > 7) 
//           Colour <= 12'h000;
//        else if((SnakeState_X[8] == ADDRH[9:3]) && (SnakeState_Y[8] == ADDRV[8:3]) && Body_increment > 8) 
//           Colour <= 12'hFFF;
//        else if((SnakeState_X[9] == ADDRH[9:3]) && (SnakeState_Y[9] == ADDRV[8:3]) && Body_increment > 9) 
//           Colour <= 12'h000;
     
//        else if((SnakeState_X[10] == ADDRH[9:3]) && (SnakeState_Y[10] == ADDRV[8:3]) && Body_increment > 10) 
//           Colour <= 12'hFFF;
                                 
         
//         for(s = 1; s<Body_increment; s = s+1) begin  //put snakelength here for normal snake
//             if((SnakeState_X[s] == ADDRH[9:3]) && (SnakeState_Y[s] == ADDRV[8:3])) 
//                 Colour <= 12'h0FF;
//                 end 
//         for(s = 8; s<15; s = s+1) begin  //put snakelength here for normal snake
//                     if((SnakeState_X[s] == ADDRH[9:2]) && (SnakeState_Y[s] == ADDRV[8:2])) 
//                         Colour <= 12'hFFF;
//                         end 
//         for(s = 16; s<20; s = s+1) begin  //put snakelength here for normal snake
//                             if((SnakeState_X[s] == ADDRH[9:2]) && (SnakeState_Y[s] == ADDRV[8:2])) 
//                                 Colour <= 12'h000;                                     
//         end 
    
//   //How to determine if death target is hit
//reg D_Target; 

//    initial begin
//        D_Target <= 0;
//    end  

//    always@(posedge CLK) begin
//    if(RESET)
//        D_Target <=0;
//    else if((SnakeState_X[0] == D_Random_Target_X) && (SnakeState_Y[0] == D_Random_Target_Y) && (Counter == 0)) 
//        D_Target <= 1;
//    else
//        D_Target <= 0;
//    end
   
   
//    //Body hit detection
//    integer bh;     //it is used for iterating the loop
//    initial begin
//      Body_hit <= 0;        //initializing the body hit
//      end
//    always@(posedge CLK) begin
//        if(RESET)
//            Body_hit = 0;
//        else if(Body_hit_side) begin
//            Body_hit <= 1;
//          end             
//       else if(D_Target) begin
//            Body_hit <= 1;
//        end   
//       else if(pixshiftamount) begin //At the start when the snake comes out it is like it is hitting itself. To preven instant death this condition is usesd
//        for(bh = 1; bh<Body_increment; bh = bh+1) begin
//            if((SnakeState_X[0] == SnakeState_X[bh]) && (SnakeState_Y[0] == SnakeState_Y[bh]))
//                Body_hit <= 1;
//                end
//            end
//         end     
  
   
