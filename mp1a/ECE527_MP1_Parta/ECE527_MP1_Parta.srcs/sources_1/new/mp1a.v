`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 17:23:57
// Design Name: 
// Module Name: mp1a
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


//module mp1a(
//    input clk,
//    input [1:0]SW,
//    output reg [1:0]LED
//    );
    
//    reg [31:0]counter = 0;
//    reg [31:0]counter_next;
//    reg [1:0]SW_reg;
//    reg [1:0]STATE,STATE_next;
//    reg [1:0]SW_STATE_0, SW_STATE_1, SW_STATE_2;
    
//    assign SW_STATE_0 = 2'b00;
//    assign SW_STATE_1 = 2'b01;
//    assign SW_STATE_2 = 2'b10;

//    always @(posedge clk) begin
//        SW_reg <= SW;
//        STATE <= STATE_next;
//    end
    
//    always @(*) begin
//        STATE_next = 0;
//        LED = 2'b00;
//        if(STATE == SW_STATE_0 && SW != SW_reg) begin
//            STATE_next = SW_STATE_1;
//        end
//        else if (STATE == SW_STATE_1) begin
//            STATE_next = SW_STATE_2;
//        end
//        else if (STATE == SW_STATE_2) begin
//            STATE_next = SW_STATE_0;
//            LED = SW_reg;
//        end
//    end
//endmodule
module mp1a(
    input        clk,
    input  [1:0] SW,
    output reg [1:0] LED   
);

    // 2-stage synchronizer / pipeline
    reg [1:0] sw_d0;  // sampled now
    reg [1:0] sw_d1;  // +1 cycle
    reg [1:0] sw_d2;  // +2 cycles

    always @(posedge clk) begin
        sw_d0 <= SW; 
        sw_d1 <= sw_d0;   
        sw_d2 <= sw_d1;   
        LED   <= sw_d2;  
    end

endmodule
