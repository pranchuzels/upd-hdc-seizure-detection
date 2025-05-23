`timescale 1ns / 1ps
module cont_mem (
    clk,
    nrst,
    en,
    finish,
    hv_train,
    label,
    done,
    hv_nonseizure,
    hv_seizure
);

    parameter DIMENSIONS = 10000;
    parameter COUNT_SIZE = 8;

    parameter HV_NONSEIZURE = 0;
    parameter HV_SEIZURE = 0;


    input clk;
    input nrst;
    input en;
    input finish;

    input [DIMENSIONS - 1:0] hv_train;
    input label;
    
    output reg done;
    output reg [DIMENSIONS - 1:0] hv_nonseizure;
    output reg [DIMENSIONS - 1:0] hv_seizure;


    reg state;
    
    logic [DIMENSIONS - 1: 0] hv_out;

    bundler_cont #(
        .DIMENSIONS(DIMENSIONS),
        .COUNT_SIZE(COUNT_SIZE)
    ) u_bundler_cont (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .finish(finish),
        .hv_in(hv_train),
        .hv_out(hv_out)
    );


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            hv_nonseizure <= HV_NONSEIZURE;
            hv_seizure <= HV_SEIZURE;
            
            state <= 0;
        end
        else begin
            if (!state) begin
                if (finish)
                    state <= 1;
                done <= 0;
            end
            else begin
                done <= 1;
                if (label)
                    hv_seizure <= hv_out;
                else
                    hv_nonseizure <= hv_out;
            end
        end
    end
endmodule