`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/05 13:53:28
// Design Name: 
// Module Name: accelerator
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


module caesar_cipher_accelerator #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // Clock and Reset
    input wire clk,
    input wire rst_n,
    // AXI Stream Slave Interface (Input)
    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output reg s_axis_tready,
    // AXI Stream Master Interface (Output)
    output reg [DATA_WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    // AXI Lite Slave Interface (Control)
    // Write Address Channel
    input wire [ADDR_WIDTH-1:0] s_axil_awaddr,
    input wire s_axil_awvalid,
    output reg s_axil_awready,
    // Write Data Channel
    input wire [DATA_WIDTH-1:0] s_axil_wdata,
    input wire s_axil_wvalid,
    output reg s_axil_wready,
    // Write Response Channel
    output reg [1:0] s_axil_bresp,
    output reg s_axil_bvalid,
    input wire s_axil_bready,
    // Read Address Channel
    input wire [ADDR_WIDTH-1:0] s_axil_araddr,
    input wire s_axil_arvalid,
    output reg s_axil_arready,
    // Read Data Channel
    output reg [DATA_WIDTH-1:0] s_axil_rdata,
    output reg [1:0] s_axil_rresp,
    output reg s_axil_rvalid,
    input wire s_axil_rready
);
    // Internal shift register (signed for encryption/decryption)
    reg signed [31:0] shift_amount;
    // Internal buffers
    reg [7:0] char_out0, char_out1, char_out2, char_out3;
    wire [7:0] char_in0, char_in1, char_in2, char_in3;
    // State machine for AXIL write
    localparam IDLE = 2'b00;
    localparam WRITE = 2'b01;
    localparam RESP = 2'b10;
    reg [1:0] write_state;
    // AXIL Write Logic
    always @(posedge clk) begin
        if (!rst_n) begin
            shift_amount <= 32'sd0;
            s_axil_awready <= 1'b0;
            s_axil_wready <= 1'b0;
            s_axil_bvalid <= 1'b0;
            s_axil_bresp <= 2'b00;
            write_state <= IDLE;
        end else begin
            case (write_state)
                IDLE: begin
                    s_axil_awready <= 1'b1;
                    s_axil_wready <= 1'b1;
                    if (s_axil_awvalid && s_axil_wvalid) begin
                        if (s_axil_awaddr[3:0] == 4'h0) begin
                            shift_amount <= $signed(s_axil_wdata);
                        end
                        write_state <= WRITE;
                    end
                end
                WRITE: begin
                    s_axil_awready <= 1'b0;
                    s_axil_wready <= 1'b0;
                    s_axil_bvalid <= 1'b1;
                    s_axil_bresp <= 2'b00; // OKAY response
                    write_state <= RESP;
                end
                RESP: begin
                    if (s_axil_bready && s_axil_bvalid) begin
                        s_axil_bvalid <= 1'b0;
                        write_state <= IDLE;
                    end
                end
            endcase
        end
    end
    // AXIL Read Logic
    always @(posedge clk) begin
        if (!rst_n) begin
            s_axil_arready <= 1'b0;
            s_axil_rvalid <= 1'b0;
            s_axil_rdata <= 32'd0;
            s_axil_rresp <= 2'b00;
        end else begin
            if (s_axil_arvalid && !s_axil_rvalid) begin
                s_axil_arready <= 1'b1;
                if (s_axil_araddr[3:0] == 4'h0) begin
                    s_axil_rdata <= shift_amount;
                end else begin
                    s_axil_rdata <= 32'd0;
                end
                s_axil_rvalid <= 1'b1;
                s_axil_rresp <= 2'b00; // OKAY
            end else begin
                s_axil_arready <= 1'b0;
                if (s_axil_rready && s_axil_rvalid) begin
                    s_axil_rvalid <= 1'b0;
                end
            end
        end
    end
    // Extract input characters
    assign char_in0 = s_axis_tdata[7:0];
    assign char_in1 = s_axis_tdata[15:8];
    assign char_in2 = s_axis_tdata[23:16];
    assign char_in3 = s_axis_tdata[31:24];
    // Caesar Cipher Function (SYNTHESIZABLE VERSION)
    // This function processes one character at a time
    function [7:0] caesar_shift;
        input [7:0] char_in;
        input signed [31:0] shift;
        reg [7:0] result;
        reg signed [31:0] char_pos;
        reg signed [31:0] shifted_pos;
        reg signed [31:0] mod_result;
        begin
            // Check if it's a lowercase letter (a-z: ASCII 97-122)
            if (char_in >= 8'd97 && char_in <= 8'd122) begin
                // Convert to position (0-25)
                char_pos = char_in - 8'd97;
                // Apply shift
                shifted_pos = char_pos + shift;
                // Handle modulo for synthesis - use fixed computation
                // For modulo 26, we handle common cases explicitly
                if (shifted_pos >= 0) begin
                    // Positive modulo
                    if (shifted_pos < 26) begin
                        mod_result = shifted_pos;
                    end else if (shifted_pos < 52) begin
                        mod_result = shifted_pos - 26;
                    end else if (shifted_pos < 78) begin
                        mod_result = shifted_pos - 52;
                    end else begin
                        // For larger values, use repeated subtraction (bounded)
                        mod_result = shifted_pos % 26;
                    end
                end else begin
                    // Negative modulo
                    if (shifted_pos >= -26) begin
                        mod_result = shifted_pos + 26;
                    end else if (shifted_pos >= -52) begin
                        mod_result = shifted_pos + 52;
                    end else if (shifted_pos >= -78) begin
                        mod_result = shifted_pos + 78;
                    end else begin
                        // For very negative values
                        mod_result = 26 + (shifted_pos % 26);
                        if (mod_result == 26) mod_result = 0;
                    end
                end
                // Convert back to ASCII
                result = mod_result + 8'd97;
            end else begin
                // Non-lowercase letter, pass through unchanged
                result = char_in;
            end
            caesar_shift = result;
        end
    endfunction
    // Stream Processing with registered output
    always @(posedge clk) begin
        if (!rst_n) begin
            s_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 32'd0;
            char_out0 <= 8'd0;
            char_out1 <= 8'd0;
            char_out2 <= 8'd0;
            char_out3 <= 8'd0;
        end else begin
            // Ready to accept new data when not holding valid data or when downstream is ready
            s_axis_tready <= !m_axis_tvalid || m_axis_tready;
            // Process incoming data
            if (s_axis_tvalid && s_axis_tready) begin
                // Apply Caesar cipher to all 4 characters in parallel
                char_out0 <= caesar_shift(char_in0, shift_amount);
                char_out1 <= caesar_shift(char_in1, shift_amount);
                char_out2 <= caesar_shift(char_in2, shift_amount);
                char_out3 <= caesar_shift(char_in3, shift_amount);
                // Assemble output data
                m_axis_tdata <= {caesar_shift(char_in3, shift_amount),
                                caesar_shift(char_in2, shift_amount),
                                caesar_shift(char_in1, shift_amount),
                                caesar_shift(char_in0, shift_amount)};
                m_axis_tvalid <= 1'b1;
            end else if (m_axis_tready && m_axis_tvalid) begin
                // Data accepted, clear valid
                m_axis_tvalid <= 1'b0;
            end
        end
    end
endmodule
