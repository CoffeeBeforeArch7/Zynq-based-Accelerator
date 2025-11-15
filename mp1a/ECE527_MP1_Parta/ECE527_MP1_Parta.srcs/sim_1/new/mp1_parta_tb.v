`timescale 1ns / 1ps
module mp1a_tb;
    // Inputs
    reg clk;
    reg [1:0] SW;
    // Outputs
    wire [1:0] LED;
    // Variables for verification
    reg [1:0] sw_delay_pipe [0:2];  // Pipeline to track expected values
    integer i;
    integer error_count = 0;
    integer pass_count = 0;
    // Instantiate the Unit Under Test (UUT)
    mp1a uut (
        .clk(clk),
        .SW(SW),
        .LED(LED)
    );
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    // Task to wait for clock cycles
    task wait_cycles;
        input integer num_cycles;
        begin
            repeat(num_cycles) @(posedge clk);
        end
    endtask
    // Task to apply switch value and check result after 3 cycles
    task apply_and_check;
        input [1:0] switch_val;
        input check_enable;  // Whether to check the output
        reg [1:0] expected;
        begin
            // Apply new switch value
            SW = switch_val;
            // If checking is enabled, verify the 3-cycle delay
            if (check_enable) begin
                expected = sw_delay_pipe[2];  // Value from 3 cycles ago
                #1;  // Small delay to sample after clock edge settles
                if (LED !== expected) begin
                    $display("ERROR at time %0t: SW=%b, LED=%b, Expected=%b",
                            $time, SW, LED, expected);
                    error_count = error_count + 1;
                end else begin
                    pass_count = pass_count + 1;
                end
            end
            // Update the pipeline for next cycle
            @(posedge clk);
            sw_delay_pipe[2] = sw_delay_pipe[1];
            sw_delay_pipe[1] = sw_delay_pipe[0];
            sw_delay_pipe[0] = switch_val;
        end
    endtask
    // Main test sequence
    initial begin
        // Initialize
        SW = 2'b00;
        for (i = 0; i < 3; i = i + 1) begin
            sw_delay_pipe[i] = 2'b00;
        end
        // Create VCD file for waveform viewing
        $dumpfile("mp1a_tb.vcd");
        $dumpvars(0, mp1a_tb);
        // Display header
        $display("\n====================================");
        $display("     MP1A Testbench Started");
        $display("====================================\n");
        $display("Time\t\tClk\tSW\tLED\tsw_d0\tsw_d1\tsw_d2");
        $display("--------\t---\t--\t---\t-----\t-----\t-----");
        // Monitor all signals
        $monitor("%8t\t%b\t%b\t%b\t%b\t%b\t%b",
                $time, clk, SW, LED, uut.sw_d0, uut.sw_d1, uut.sw_d2);
        // Wait for initial stabilization (3 cycles to fill pipeline)
        wait_cycles(3);
        $display("\n--- Test 1: Initialize Pipeline ---");
        SW = 2'b00;
        wait_cycles(4);  // Wait for pipeline to fill with 00
        $display("\n--- Test 2: Basic Transitions ---");
        // Test each transition with verification
        apply_and_check(2'b00, 0);  // First 3 changes won't have valid history
        apply_and_check(2'b01, 0);
        apply_and_check(2'b10, 0);
        apply_and_check(2'b11, 1);  // Start checking from 4th change
        apply_and_check(2'b00, 1);
        apply_and_check(2'b01, 1);
        apply_and_check(2'b10, 1);
        apply_and_check(2'b11, 1);
        $display("\n--- Test 3: Pattern from Timing Diagram ---");
        // Reset pipeline tracking
        for (i = 0; i < 3; i = i + 1) sw_delay_pipe[i] = LED;
        // Pattern: 00 -> 10 -> 11 -> 00
        SW = 2'b00;
        wait_cycles(2);
        SW = 2'b10;  // Change to 10
        wait_cycles(1);
        #1;
        if (LED !== 2'b00) $display("Cycle 1 after SW=10: LED should still be 00, got %b", LED);
        wait_cycles(1);
        #1;
        if (LED !== 2'b00) $display("Cycle 2 after SW=10: LED should still be 00, got %b", LED);
        wait_cycles(1);
        #1;
        if (LED !== 2'b10) $display("Cycle 3 after SW=10: LED should now be 10, got %b", LED);
        else $display("PASS: LED correctly shows 10 after 3 cycles");
        SW = 2'b11;  // Change to 11
        wait_cycles(3);
        #1;
        if (LED !== 2'b11) $display("ERROR: LED should be 11, got %b", LED);
        else $display("PASS: LED correctly shows 11 after 3 cycles");
        $display("\n--- Test 4: Rapid Toggle Test ---");
        for (i = 0; i < 10; i = i + 1) begin
            SW = i[1:0];
            @(posedge clk);
        end
        wait_cycles(5);  // Let pipeline clear
        $display("\n--- Test 5: Hold Values ---");
        SW = 2'b10;
        wait_cycles(5);
        #1;
        if (LED !== 2'b10) begin
            $display("ERROR: After holding 10 for 5 cycles, LED should be 10, got %b", LED);
        end else begin
            $display("PASS: LED correctly holds value 10");
        end
        // Final summary
        #50;
        $display("\n====================================");
        $display("     Testbench Summary");
        $display("====================================");
        $display("Total Checks: %0d", pass_count + error_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", error_count);
        $display("Final State:");
        $display("  SW = %b", SW);
        $display("  LED = %b", LED);
        $display("  Pipeline: sw_d0=%b, sw_d1=%b, sw_d2=%b",
                uut.sw_d0, uut.sw_d1, uut.sw_d2);
        $display("====================================\n");
        if (error_count == 0) begin
            $display("*** ALL TESTS PASSED! ***\n");
        end else begin
            $display("*** SOME TESTS FAILED - Review errors above ***\n");
        end
        $finish;
    end
    // Timeout watchdog
    initial begin
        #1000;
        $display("\nERROR: Testbench timeout!");
        $finish;
    end
endmodule