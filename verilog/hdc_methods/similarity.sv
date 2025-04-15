`timescale 1ns / 1ps

module similarity (
    clk,
    nrst,
    en,
    hv_test,
    hv_nonseizure,
    hv_seizure,
    done,
    label
);

    parameter DIMENSIONS = 10000;

    input clk;
    input nrst;
    input en;
    input [DIMENSIONS - 1:0] hv_test;
    input [DIMENSIONS - 1:0] hv_nonseizure;
    input [DIMENSIONS - 1:0] hv_seizure;
    output reg done;
    output reg label;
    
    reg state;
    reg [$clog2(DIMENSIONS) - 1: 0] d;

    logic [DIMENSIONS - 1:0] hv_sim_nonseizure;
    logic [DIMENSIONS - 1:0] hv_sim_seizure;
    reg [$clog2(DIMENSIONS): 0] count_sim_nonseizure;
    reg [$clog2(DIMENSIONS): 0] count_sim_seizure;



    always_comb begin
        hv_sim_nonseizure = hv_test ^ hv_nonseizure;
        hv_sim_seizure = hv_test ^ hv_seizure;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 1;
            label <= 0;

            state <= 0;
            d <= 0;
            count_sim_nonseizure <= 0;
            count_sim_seizure <= 0;
        end else begin

            // Idle/Output State
            if (!state) begin
                if (en) begin
                    state <= 1;
                    done <= 0;

                    d <= 0; 
                    count_sim_nonseizure <= 0;
                    count_sim_seizure <= 0;
                end
            end

            // Counting State
            else begin
                if (d == DIMENSIONS) begin
                    if (count_sim_nonseizure > count_sim_seizure)
                        label <= 1;
                    else
                        label <= 0;

                    state <= 0;
                    done <= 1;
                end
                else begin
                    if (hv_sim_nonseizure[d] == 1)
                        count_sim_nonseizure <= count_sim_nonseizure + 1;
                    if (hv_sim_seizure[d] == 1)
                        count_sim_seizure <= count_sim_seizure + 1;

                    d <= d + 1;
                end
            end
        end
    end

endmodule