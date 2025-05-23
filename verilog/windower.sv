`timescale 1ns / 1ps
module windower (
    clk,
    nrst,
    en,
    samples,
    done,
    sample_memory
);

    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    parameter SAMPLE_SIZE = 16;
    

    input clk;
    input nrst;
    input en;
    input [NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] sample_memory;
    
    reg [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] running_memory;


    reg isFirstWindow;
    reg [$clog2(WINDOW_SIZE): 0] sampleCounter;


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            sample_memory <= 0;
            running_memory <= 0;

            isFirstWindow <= 1;
            sampleCounter <= 0;
        end else begin
            if (en) begin
                // Put samples into sample memory
                running_memory[WINDOW_SIZE - 1] <= samples;

                // Shift sample memory
                for (int i = 0; i < WINDOW_SIZE - 1; i = i + 1)
                    running_memory[i] <= running_memory[i + 1];
                
                // Window generation
                if (isFirstWindow && sampleCounter == WINDOW_SIZE - 1) begin
                    isFirstWindow <= 0;
                    sampleCounter <= 0;
                    sample_memory <= running_memory;
                    done <= 1;
                end
                else if (!isFirstWindow && sampleCounter == WINDOW_STEP - 1) begin
                    sampleCounter <= 0;
                    sample_memory <= running_memory;
                    done <= 1;
                end 
                else begin
                    sampleCounter <= sampleCounter + 1;
                    done <= 0;
                end
            end
            else
                done <= 0;
        end
    end

endmodule