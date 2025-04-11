`timescale 1ns / 1ps

module bundler_bit (
    clk,
    nrst,
    en,
    bits,
    tie_1,
    tie_2,
    done,
    out_bit
);

    parameter NUM_HVS = 17;
    localparam MIN_ONES = $floor(NUM_HVS / 2.0);
    localparam MAX_ZEROS = $ceil(NUM_HVS / 2.0);

    input reg clk;
    input reg nrst;
    input en;
    input bits [NUM_HVS - 1:0];
    input tie_1;
    input tie_2;
    output reg done;
    output reg out_bit;

    reg [1:0] state;
    reg [$clog2(NUM_HVS): 0] num_ones;
    reg [$clog2(NUM_HVS) - 1: 0] i;

    generate
        if (NUM_HVS % 2 == 0) begin : even_hvs
            always_ff @(posedge clk or negedge nrst) begin
                // Asynchronous Reset Stage
                if (!nrst) begin
                    done <= 1;
                    out_bit <= 0;

                    state <= 0;
                    num_ones <= 0;
                    i <= 0;
                end

                // Operating Stage
                else begin
                    // Idle State
                    if (state == 0) begin
                        if (en) begin
                            done <= 0;

                            state <= 1;
                            num_ones <= 0;
                            i <= 0;
                        end
                    end

                    // Count State
                    else if (state == 1) begin
                        if (bits[i])
                            num_ones <= num_ones + 1;

                        if (i == NUM_HVS - 1)
                            state <= 2; 
                        else
                            i <= i + 1; 
                    end

                    // Output State
                    else if (state == 2) begin
            
                        if (num_ones > MIN_ONES)
                            out_bit <= 1;
                        else if (num_ones < MAX_ZEROS)
                            out_bit <= 0;
                        else
                            out_bit <= tie_1 ^ tie_2;

                        state <= 0;
                        done <= 1;
                    end
                end
            end
        end

        else begin : odd_hvs
            always_ff @(posedge clk or negedge nrst) begin
                // Asynchronous Reset Stage
                if (!nrst) begin
                    done <= 1;
                    out_bit <= 0;

                    state <= 0;
                    num_ones <= 0;
                    i <= 0;
                end

                // Operating Stage
                else begin
                    // Idle State
                    if (state == 0) begin
                        if (en) begin
                            done <= 0;

                            state <= 1;
                            num_ones <= 0;
                            i <= 0;
                        end
                    end

                    // Count State
                    else if (state == 1) begin
                        if (bits[i])
                            num_ones <= num_ones + 1;

                        if (i == NUM_HVS - 1)
                            state <= 2; 
                        else
                            i <= i + 1; 
                    end

                    // Output State
                    else if (state == 2) begin
                        if (num_ones > MIN_ONES)
                            out_bit <= 1;
                        else
                            out_bit <= 0;

                        state <= 0;
                        done <= 1;
                    end
                end
            end
        end
    endgenerate

endmodule