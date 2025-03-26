`timescale 1ms / 1us
module bundler_ch_v2 (
    hv_array,
    hvout
);

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;

    input [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    output reg [DIMENSIONS - 1:0] hvout;
    reg [$clog2(NUM_HVS):0] ones [DIMENSIONS - 1:0];
    
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
                .hv_array(hv_array),
                .ones(ones),
                .hvout(hvout)
            );
        end
    endgenerate

    always @(*) begin

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

    input [$clog2(NUM_HVS):0] ones [DIMENSIONS - 1:0];;
    output reg [DIMENSIONS - 1:0] hvout;

    always @(*) begin
        for(int i = 0; i < DIMENSIONS; i = i + 1) begin
            if (ones[i] > (NUM_HVS - 1) / 2)
                hvout[i] = 1;
            else
                hvout[i] = 0;
        end
    end
endmodule

module binarizer_even (
    hv_array,
    ones,
    hvout
);
    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;

    input [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    input [$clog2(NUM_HVS):0] ones [DIMENSIONS - 1:0];;
    output reg [DIMENSIONS - 1:0] hvout = 0;


    always @(*) begin
        for(int i = 0; i < DIMENSIONS; i = i + 1) begin
            if (ones[i] > NUM_HVS / 2) begin
                hvout[i] = 1;
            end
            else if (ones[i] < NUM_HVS / 2) begin
                hvout[i] = 0;
            end
            else if (ones[i] == NUM_HVS / 2) begin
                if (i == DIMENSIONS - 1) begin
                    hvout[i] = hv_array[0][0] ^ hv_array[NUM_HVS - 1][0];
                end else begin
                    hvout[i] = hv_array[0][i + 1] ^ hv_array[NUM_HVS - 1][i + 1];
                end
            end
        end

    end
endmodule