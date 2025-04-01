`timescale 1ms / 1us

module similarity_hf (
    clk,
    nrst,
    en,
    hv,
    ns_hv,
    s_hv,
    out,
    label_out
);

    parameter DIMENSIONS = 10000;

    input clk;
    input nrst;
    input en;
    input [DIMENSIONS - 1:0] hv;
    input [DIMENSIONS - 1:0] ns_hv;
    input [DIMENSIONS - 1:0] s_hv;
    output out;
    output reg label_out;

    reg [$clog2(DIMENSIONS):0] hv_xor_ns;
    reg [$clog2(DIMENSIONS):0]  hv_xor_s;
    reg [$clog2(DIMENSIONS) - 1:0] i;
    
    reg state;

    assign out = ~state;

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            hv_xor_ns <= 0;
            hv_xor_s <= 0;
            i <= 0;
            label_out <= 0;
            state <= 0;
        end else begin
            if (!state) begin
                if (en)
                    state <= 1;
                else begin
                    hv_xor_ns <= 0;
                    hv_xor_s <= 0;
                end
            end else begin
                if (i <= DIMENSIONS - 1) begin
                    if (hv[i] ^ ns_hv[i] == 1'b1)
                        hv_xor_ns <= hv_xor_ns + 1;
                    if (hv[i] ^ s_hv[i] == 1'b1)
                        hv_xor_s <= hv_xor_s + 1;
                    i <= i + 1; 
                end else begin
                    if (hv_xor_ns < hv_xor_s)
                        label_out <= 0;
                    else
                        label_out <= 1;

                    i <= 0;
                    state <= 0;
                end
            end
        end 
    end

endmodule