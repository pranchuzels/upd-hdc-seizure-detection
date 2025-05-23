`timescale 1ns / 1ps
module sp_extractor (
    clk,
    nrst,
    en,
    c,
    spi,
    samples,
    done,
    spv
);

    // General params
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    parameter SAMPLE_SIZE = 16;
    
    // Feature params
    parameter NUM_SPI = 6;
    parameter NUM_SPV = 64;

    input clk;
    input nrst;
    input en;
    input [$clog2(NUM_CHS) - 1: 0] c;
    input [$clog2(NUM_SPI) - 1: 0] spi;
    input [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [$clog2(NUM_SPV) - 1:0] spv;

    wire [NUM_CHS - 1: 0][NUM_SPI - 1: 0][$clog2(NUM_SPV) - 1: 0] spv_mem;

    assign spv_mem[0] = { 6'd1, 6'd0, 6'd2, 6'd1, 6'd1, 6'd0 }; 
    assign spv_mem[1] = { 6'd0, 6'd0, 6'd1, 6'd1, 6'd0, 6'd0 }; 
    assign spv_mem[2] = { 6'd1, 6'd0, 6'd1, 6'd2, 6'd0, 6'd0 }; 
    assign spv_mem[3] = { 6'd0, 6'd0, 6'd2, 6'd1, 6'd0, 6'd0 }; 
    assign spv_mem[4] = { 6'd1, 6'd1, 6'd2, 6'd2, 6'd1, 6'd0 }; 
    assign spv_mem[5] = { 6'd0, 6'd0, 6'd1, 6'd1, 6'd1, 6'd0 }; 
    assign spv_mem[6] = { 6'd0, 6'd0, 6'd1, 6'd2, 6'd0, 6'd0 }; 
    assign spv_mem[7] = { 6'd0, 6'd0, 6'd2, 6'd1, 6'd1, 6'd0 }; 
    assign spv_mem[8] = { 6'd0, 6'd2, 6'd4, 6'd9, 6'd3, 6'd2 }; 
    assign spv_mem[9] = { 6'd2, 6'd1, 6'd3, 6'd7, 6'd2, 6'd1 }; 
    assign spv_mem[10] = { 6'd0, 6'd0, 6'd3, 6'd6, 6'd1, 6'd1 }; 
    assign spv_mem[11] = { 6'd0, 6'd1, 6'd2, 6'd6, 6'd1, 6'd0 }; 
    assign spv_mem[12] = { 6'd5, 6'd1, 6'd5, 6'd4, 6'd10, 6'd6 }; 
    assign spv_mem[13] = { 6'd2, 6'd1, 6'd3, 6'd15, 6'd16, 6'd9 }; 
    assign spv_mem[14] = { 6'd0, 6'd1, 6'd3, 6'd6, 6'd1, 6'd1 }; 
    assign spv_mem[15] = { 6'd1, 6'd1, 6'd3, 6'd3, 6'd0, 6'd0 }; 
    assign spv_mem[16] = { 6'd0, 6'd0, 6'd2, 6'd3, 6'd0, 6'd0 }; 




    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 1'b0;
            spv <= 0;
        end
        else begin
            if (en) begin
                // SP extractor logic
                // Assuming some logic to extract the SP value based on the SPI and samples
                spv <= spv_mem[c][spi];
                done <= 1'b1;
            end
            else begin
                done <= 1'b0;
            end
        end
    end

endmodule