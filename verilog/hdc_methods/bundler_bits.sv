`timescale 1ns / 1ps

module bundler_bits (
    clk,
    nrst,
    en,
    bits,
    tie_bits,
    done,
    out_bits
);

    // Parameters
    parameter NUM_HVS = 17;
    parameter PAR_BITS = 10;
    localparam MIN_ONES = $floor(NUM_HVS / 2.0);
    localparam MAX_ZEROS = $ceil(NUM_HVS / 2.0);

    // Input/Output
    input clk;
    input nrst;
    input en;
    input [NUM_HVS - 1:0][PAR_BITS - 1: 0] bits;
    input [PAR_BITS - 1: 0] tie_bits;
    output reg done;
    output reg [PAR_BITS - 1: 0] out_bits;

    // Sequential Registers
    reg [1:0] state; // 0: Idle, 1: Count, 2: Output
    reg [PAR_BITS - 1: 0][$clog2(NUM_HVS): 0] num_ones;
    reg [$clog2(NUM_HVS) - 1: 0] i_hv;

    // Combinational Logic
    logic [PAR_BITS - 1: 0][$clog2(NUM_HVS): 0] num_ones_temp;
    logic [PAR_BITS - 1: 0] out_bits_temp;

    // Tie breaker logic
    wire [$clog2(NUM_HVS): 0] w_min_ones;
    wire [$clog2(NUM_HVS): 0] w_max_zeros;
    assign w_min_ones = MIN_ONES;
    assign w_max_zeros = MAX_ZEROS;


    always_comb begin : num_ones_setter
        if (state == 1) begin
            for (int i_bit = 0; i_bit < PAR_BITS; i_bit = i_bit + 1) begin
                if (bits[i_hv][i_bit])
                    num_ones_temp[i_bit] = num_ones[i_bit] + 1;
                else
                    num_ones_temp[i_bit] = num_ones[i_bit] + 0;
            end
        end
        else
            num_ones_temp = 0;
    end

    generate
        
        if (NUM_HVS % 2 == 0) begin : even_out_bits_setter
            always_comb begin
                if (state == 2) begin
                    for (int i_bit = 0; i_bit < PAR_BITS; i_bit = i_bit + 1) begin
                        if (num_ones[i_bit] > w_min_ones)
                            out_bits_temp[i_bit] = 1;
                        else if (num_ones[i_bit] < w_max_zeros)
                            out_bits_temp[i_bit] = 0;
                        else
                            out_bits_temp[i_bit] = tie_bits[i_bit];
                    end
                end
                else begin
                    out_bits_temp = 0;
                end
            end
        end

        else begin : odd_out_bits_setter
            always_comb begin
                if (state == 2) begin
                    for (int i_bit = 0; i_bit < PAR_BITS; i_bit = i_bit + 1) begin
                        if (num_ones[i_bit] > w_min_ones)
                            out_bits_temp[i_bit] = 1;
                        else
                            out_bits_temp[i_bit] = 0;
                    end
                end
                else begin
                    out_bits_temp = 0;
                end
            end  
        end
    endgenerate

    always_ff @(posedge clk or negedge nrst) begin
        // Asynchronous Reset Stage
        if (!nrst) begin
            done <= 1;
            out_bits <= 0;

            num_ones <= 0;
            state <= 0;
            i_hv <= 0;
        end

        // Operating Stage
        else begin
            // Idle State
            if (state == 0) begin
                if (en) begin
                    done <= 0;

                    num_ones <= 0;
                    state <= 1;
                    i_hv <= 0;
                end
            end

            // Count State
            else if (state == 1) begin
                num_ones <= num_ones_temp;

                if (i_hv == NUM_HVS - 1)
                    state <= 2; 
                else
                    i_hv <= i_hv + 1; 
            end

            // Output State
            else if (state == 2) begin
                done <= 1;
                out_bits <= out_bits_temp;

                state <= 0;
            end
        end
    end

endmodule