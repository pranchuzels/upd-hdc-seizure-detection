`timescale 1ms / 1us
module bundler_hf (
    clk,
    nrst,
    en,
    hv_array,
    out,
    hv_out
);

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;

    input reg clk;
    input reg nrst;
    input en;
    input [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    output reg out;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [$clog2(DIMENSIONS) - 1: 0] count_dim;
    reg [$clog2(NUM_HVS): 0] count_ones;
    reg state;
    wire [$clog2(NUM_HVS): 0] min_ones;
    wire [$clog2(NUM_HVS): 0] max_zeros;

    assign min_ones = $floor(NUM_HVS / 2.0);
    assign max_zeros = $ceil(NUM_HVS / 2.0);

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            count_dim <= 0;
            count_ones = 0;
            state <= 0;
            hv_out <= 0;
            out <= 1;
        end else begin
            if (!state) begin
                if (en) begin
                    state <= 1;
                    out <= 0;
                end
            end else begin
                count_ones = 0;
                for (int i = 0; i < NUM_HVS; i = i + 1) begin
                    if (hv_array[i][count_dim] == 1)
                        count_ones = count_ones + 1;
                end

                if (count_ones > min_ones)
                    hv_out[count_dim] <= 1;
                else if (count_ones < max_zeros)
                    hv_out[count_dim] <= 0;
                else begin
                    if (count_dim == DIMENSIONS - 1) begin
                        hv_out[count_dim] <= hv_array[0][0] ^ hv_array[NUM_HVS - 1][0];
                    end else begin
                        hv_out[count_dim] <= hv_array[0][count_dim + 1] ^ hv_array[NUM_HVS - 1][count_dim + 1];
                    end
                end

                if (count_dim == DIMENSIONS - 1) begin
                    count_dim <= 0;
                    state <= 0;
                    out <= 1;
                end else
                    count_dim <= count_dim + 1; 
            end
            
        end
    end
    
endmodule