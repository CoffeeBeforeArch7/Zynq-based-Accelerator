`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 07:30:57 PM
// Design Name: 
// Module Name: mp1_b_tb
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

`timescale 1ns / 1ps

module switch_led_modes_tb;

    // Inputs
    reg clk;
    reg [1:0] sw;
    reg [3:0] btn;
    
    // Outputs
    wire [3:0] led;
    
    // Expected values for verification
    reg [3:0] expected_led;
    integer error_count = 0;
    integer test_count = 0;
    
    // Instantiate the Unit Under Test (UUT)
    switch_led_modes uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to press and release a button
    task press_button;
        input [1:0] button_num;
        begin
            btn = 4'b0000;
            #10;
            btn[button_num] = 1'b1;  // Press button
            #20;  // Hold for 2 clock cycles
            btn[button_num] = 1'b0;  // Release button
            #20;  // Wait for processing
        end
    endtask
    
    // Task to test a specific switch configuration in all modes
    task test_switch_config;
        input [1:0] switch_val;
        input [3:0] base_pattern;
        begin
            sw = switch_val;
            #10;
            
            $display("\n  Testing SW=%b (base pattern=%b)", switch_val, base_pattern);
            
            // Test Mode 0: Display as-is
            press_button(0);
            expected_led = base_pattern;
            #10;
            test_count = test_count + 1;
            if (led !== expected_led) begin
                $display("    ERROR Mode 0: LED=%b, Expected=%b", led, expected_led);
                error_count = error_count + 1;
            end else begin
                $display("    PASS Mode 0: LED=%b", led);
            end
            
            // Test Mode 1: Logical shift right by 2
            press_button(1);
            expected_led = base_pattern >> 2;
            #10;
            test_count = test_count + 1;
            if (led !== expected_led) begin
                $display("    ERROR Mode 1: LED=%b, Expected=%b", led, expected_led);
                error_count = error_count + 1;
            end else begin
                $display("    PASS Mode 1: LED=%b (>>2)", led);
            end
            
            // Test Mode 2: Circular shift left by 3 (same as right by 1 for 4 bits)
            press_button(2);
            expected_led = {base_pattern[0], base_pattern[3:1]};
            #10;
            test_count = test_count + 1;
            if (led !== expected_led) begin
                $display("    ERROR Mode 2: LED=%b, Expected=%b", led, expected_led);
                error_count = error_count + 1;
            end else begin
                $display("    PASS Mode 2: LED=%b (circular left 3)", led);
            end
            
            // Test Mode 3: Bitwise invert
            press_button(3);
            expected_led = ~base_pattern;
            #10;
            test_count = test_count + 1;
            if (led !== expected_led) begin
                $display("    ERROR Mode 3: LED=%b, Expected=%b", led, expected_led);
                error_count = error_count + 1;
            end else begin
                $display("    PASS Mode 3: LED=%b (inverted)", led);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        sw = 2'b00;
        btn = 4'b0000;
        
        // Create VCD file for waveform viewing
        $dumpfile("switch_led_modes_tb.vcd");
        $dumpvars(0, switch_led_modes_tb);
        
        // Display header
        $display("\n====================================");
        $display("  Switch-LED Modes System Testbench");
        $display("====================================");
        
        // Wait for initial stabilization
        #100;
        
        // Test all switch combinations
        $display("\n--- Testing All Switch Combinations ---");
        
        test_switch_config(2'b00, 4'b0001);  // SW=00 → 0001
        test_switch_config(2'b01, 4'b0011);  // SW=01 → 0011
        test_switch_config(2'b10, 4'b0111);  // SW=10 → 0111
        test_switch_config(2'b11, 4'b1111);  // SW=11 → 1111
        
        // Test mode persistence (mode should stay when switch changes)
        $display("\n--- Testing Mode Persistence ---");
        press_button(2);  // Set to Mode 2
        sw = 2'b00;  // Base pattern will be 0001
        #20;
        expected_led = 4'b1000;  // 0001 circular left by 3
        if (led !== expected_led) begin
            $display("  ERROR: Mode didn't persist. LED=%b, Expected=%b", led, expected_led);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Mode 2 persisted after switch change. LED=%b", led);
        end
        test_count = test_count + 1;
        
        sw = 2'b11;  // Change switch, mode should remain
        #20;
        expected_led = 4'b1111;  // 1111 circular left by 3 = 1111
        if (led !== expected_led) begin
            $display("  ERROR: Mode didn't persist. LED=%b, Expected=%b", led, expected_led);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Mode 2 still active. LED=%b", led);
        end
        test_count = test_count + 1;
        
        // Test rapid button presses
        $display("\n--- Testing Rapid Mode Changes ---");
        sw = 2'b10;  // Base pattern 0111
        press_button(0);
        #10;
        $display("  Mode 0: LED=%b", led);
        press_button(1);
        #10;
        $display("  Mode 1: LED=%b", led);
        press_button(2);
        #10;
        $display("  Mode 2: LED=%b", led);
        press_button(3);
        #10;
        $display("  Mode 3: LED=%b", led);
        
        // Detailed example calculations
        $display("\n--- Detailed Mode Transformations ---");
        sw = 2'b10;  // Base: 0111
        $display("  Switch state: %b → Base pattern: 0111", sw);
        
        press_button(0);
        #20;
        $display("    Mode 0 (as-is):           0111 → %b", led);
        
        press_button(1);
        #20;
        $display("    Mode 1 (>>2):             0111 → %b", led);
        
        press_button(2);
        #20;
        $display("    Mode 2 (circular left 3): 0111 → %b", led);
        
        press_button(3);
        #20;
        $display("    Mode 3 (invert):          0111 → %b", led);
        
        // Final summary
        #100;
        $display("\n====================================");
        $display("         Testbench Summary");
        $display("====================================");
        $display("  Total Tests: %0d", test_count);
        $display("  Passed: %0d", test_count - error_count);
        $display("  Failed: %0d", error_count);
        $display("====================================");
        
        if (error_count == 0) begin
            $display("\n*** ALL TESTS PASSED! ***\n");
        end else begin
            $display("\n*** %0d TESTS FAILED ***\n", error_count);
        end
        
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: clk=%b sw=%b btn=%b mode=%b led=%b", 
                 $time, clk, sw, btn, uut.current_mode, led);
    end

endmodule
