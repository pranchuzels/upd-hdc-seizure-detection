`timescale 1ns / 1ps
module bundler_ch (
    clk,
    nrst,
    hv_array,
    hvout
);

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;
    parameter LFSR_SEED = 16'b1001010010110101;

    input clk;
    input nrst;

    input [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    output reg [DIMENSIONS - 1:0] hvout;


    reg [7:0] ones [DIMENSIONS - 1:0];
    
    generate
        if (NUM_HVS[0] == 1'b1) begin // if odd, # of 1s cannot tie with # of 0s 
            binarizer_odd #(
                .DIMENSIONS(DIMENSIONS),
                .NUM_HVS(NUM_HVS)
            ) b_no_ties (
                .ones(ones),
                .hvout(hvout)
            );
        end 
        else begin  // if even, # of 1s can tie with # of 0s 
            binarizer_even #(
                .DIMENSIONS(DIMENSIONS),
                .NUM_HVS(NUM_HVS)
            ) b_with_ties (
                .ones(ones),
                .hvout(hvout)
            );
        end
    endgenerate

    always @(hv_array) begin

        ones = '{DIMENSIONS{0}};

        for(int i = 0; i < DIMENSIONS; i = i + 1) begin
            for(int j = 0; j < NUM_HVS; j = j + 1) begin
                if (hv_array[j][i] == 1'b1)
                    ones[i] = ones[i] + 1;
            end

            
            
        end
    end

endmodule

module binarizer_odd (
    ones,
    hvout
);
    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;

    input [7:0] ones [DIMENSIONS - 1:0];
    output reg [DIMENSIONS - 1:0] hvout;

    always @(ones) begin
        for(int i = 0; i < DIMENSIONS; i = i + 1) begin
            if (ones[i] > (NUM_HVS - 1) / 2)
                hvout[i] = 1;
            else
                hvout[i] = 0;
        end
    end
endmodule

module binarizer_even (
    ones,
    hvout
);
    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;

    input [7:0] ones [DIMENSIONS - 1:0];
    output reg [DIMENSIONS - 1:0] hvout;

    reg lfsr_out;
    reg lfsr_en;

    lfsr #(
        .SEED(LFSR_SEED)
    ) lfsr_tie (
        .lfsr_out(lfsr_out)
    );

    always @(ones) begin
        for(int i = 0; i < DIMENSIONS; i = i + 1) begin
            if (ones[i] > NUM_HVS / 2) begin
                hvout[i] = 1;
            end
            else if (ones[i] < NUM_HVS / 2) begin
                hvout[i] = 0;
            end
            else begin
                hvout[i] = lfsr_out;
            end
        end

    end
endmodule