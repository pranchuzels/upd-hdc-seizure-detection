`timescale 1ns / 1ps
module cont_mem (
    clk,
    nrst,
    en,
    label_override,
    override_hv_nonseizure,
    override_hv_seizure,
    hv_train,
    label,
    done,
    out_hv_nonseizure,
    out_hv_seizure
);
    // General params
    parameter DIMENSIONS = 10000;

    // Bundler params
    localparam NUM_HVS = 2;
    parameter PAR_BITS = 10;


    input clk;
    input nrst;
    input en;
    input label_override;
    input [DIMENSIONS - 1:0] override_hv_nonseizure;
    input [DIMENSIONS - 1:0] override_hv_seizure;
    input [DIMENSIONS - 1:0] hv_train;
    input label;
    output reg done;
    output reg [DIMENSIONS - 1:0] out_hv_nonseizure;
    output reg [DIMENSIONS - 1:0] out_hv_seizure;

    //  Internal signals
     reg [1:0] state; // 0 = startup, 1 = idle, 2 = bundler enabled, 3 = out

    // Bundler ports
    reg bundler_en;
    reg [NUM_HVS - 1:0][DIMENSIONS - 1:0] bundler_hv_array;
    wire bundler_out;
    wire [DIMENSIONS - 1:0] bundler_hv_out;

    bundler #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_bundler(
        .clk (clk),
        .nrst (nrst),
        .en (bundler_en),
        .hv_array  (bundler_hv_array),
        .out (bundler_out),
        .hv_out  (bundler_hv_out)
    );


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 1;
            out_hv_nonseizure <= 0;
            out_hv_seizure <= 0;
            state <= 0;

            bundler_en <= 0;
            bundler_hv_array[0] <= 0;
            bundler_hv_array[1] <= 0;
        end

        else begin
            if (state == 0) begin
                done <= 1;
                state <= 1;
                if (label_override) begin
                    out_hv_nonseizure <= override_hv_nonseizure;
                    out_hv_seizure <= override_hv_seizure;
                end
                else begin
                    out_hv_nonseizure <= 0;
                    out_hv_seizure <= 0;
                end

                
                bundler_hv_array[0] <= 0;
                bundler_hv_array[1] <= 0;
            end

            else if (state == 1) begin
                if (en) begin
                    done <= 0;
                    state <= 2;

                    
                    if (label == 1'b0) begin
                        bundler_hv_array[0] <= out_hv_nonseizure;
                        bundler_hv_array[1] <= hv_train;
                    end
                    else begin
                        bundler_hv_array[0] <= out_hv_seizure;
                        bundler_hv_array[1] <= hv_train;
                    end
                end
            end

            else if (state == 2) begin
                bundler_en <= 1'b1;
                state <= 3;
            end

            else if (state == 3) begin
                bundler_en <= 0;

                if (!bundler_en && bundler_out) begin
                    done <= 1;
                    state <= 1;

                    if (label == 1'b0) begin
                        out_hv_nonseizure <= bundler_hv_out;
                    end else begin
                        out_hv_seizure <= bundler_hv_out;
                    end
                end
            end
        end
    end
endmodule