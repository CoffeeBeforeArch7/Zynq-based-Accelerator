`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 07:11:17 PM
// Design Name: 
// Module Name: mp1_b
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

// Switch to LED Display System with Multiple Modes
// Maps 2 switches to 4 LEDs with different display modes

module switch_led_modes(
    input wire clk,           // System clock
    input wire [1:0] sw,      // Two slide switches
    input wire [3:0] btn,     // Four push buttons
    output reg [3:0] led      // Four regular LEDs (LD0-LD3)
);

    // Internal signals
    reg [1:0] current_mode;   // Current display mode (0-3)
    reg [3:0] base_state;     // Base LED pattern from switch mapping
    reg [3:0] displayed_state; // Final LED pattern after mode processing
    
    // Button edge detection registers
    reg [3:0] btn_prev;       // Previous button state
    wire [3:0] btn_pressed;   // Button press detected (rising edge)
    
    // Detect button press (rising edge)
    assign btn_pressed = btn & ~btn_prev;
    
    // Update previous button state
    always @(posedge clk) begin
        btn_prev <= btn;
    end
    
    // Mode selection based on button press
    always @(posedge clk) begin
        if (btn_pressed[0])
            current_mode <= 2'b00;  // Mode 0
        else if (btn_pressed[1])
            current_mode <= 2'b01;  // Mode 1
        else if (btn_pressed[2])
            current_mode <= 2'b10;  // Mode 2
        else if (btn_pressed[3])
            current_mode <= 2'b11;  // Mode 3
        // Note: If no button pressed, mode remains unchanged
    end
    
    // Map switches to base LED state
    always @(*) begin
        case (sw)
            2'b00: base_state = 4'b0001;  // SW=00 → 0001
            2'b01: base_state = 4'b0011;  // SW=01 → 0011
            2'b10: base_state = 4'b0111;  // SW=10 → 0111
            2'b11: base_state = 4'b1111;  // SW=11 → 1111
            default: base_state = 4'b0001; // Default case
        endcase
    end
    
    // Apply mode transformation to base state
    always @(*) begin
        case (current_mode)
            2'b00: // Mode 0: Display state as-is
                displayed_state = base_state;
                
            2'b01: // Mode 1: Logical shift right by 2
                displayed_state = base_state >> 2;
                
            2'b10: // Mode 2: Circular shift left by 3
                displayed_state = {base_state[0], base_state[3:1]};
                // Note: Circular left by 3 is same as circular right by 1 for 4 bits
                
            2'b11: // Mode 3: Bitwise invert
                displayed_state = ~base_state;
                
            default:
                displayed_state = base_state;
        endcase
    end
    
    // Output the displayed state to LEDs
    always @(posedge clk) begin
        led <= displayed_state;
    end
    
endmodule
