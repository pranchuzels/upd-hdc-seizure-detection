`timescale 1ms / 1us

module binder_hf (
    clk,
    nrst,
    en,
    hv1,
    hv2,
    out,
    hv_out
);

    parameter DIMENSIONS = 10000;

    input clk;
    input nrst;
    input en;
    input [DIMENSIONS - 1:0] hv1;
    input [DIMENSIONS - 1:0] hv2;
    output out;
    output reg [DIMENSIONS - 1:0] hv_out;
    
    
    reg state;
    reg [$clog2(DIMENSIONS) - 1: 0] count_dim;

    assign out = ~state;

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            state <= 0;
            count_dim <= 0;
            hv_out <= 0;
        end else begin
            if (!state) begin
                if (en) begin
                    state <= 1;
                end
            end else begin
                // binding proper
                hv_out[count_dim] <= hv1[count_dim] ^ hv2[count_dim];
                
                // counter update
                if (count_dim == DIMENSIONS - 1) begin
                    count_dim <= 0;
                    state <= 0;
                end else
                    count_dim <= count_dim + 1; 
            end
        end
    end

endmodule