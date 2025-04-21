`timescale 1ns / 1ps
module tb_cont_mem ();
    localparam T = 10;  // clock period in ns


    // General params
    localparam DIMENSIONS = 6;
    localparam PAR_BITS = 2;

    reg clk;
    reg nrst;
    reg en;
    reg label_override;
    reg [DIMENSIONS - 1:0] override_hv_nonseizure;
    reg [DIMENSIONS - 1:0] override_hv_seizure;
    reg [DIMENSIONS - 1:0] hv_train;
    reg label;
    wire done;
    wire [DIMENSIONS - 1:0] out_hv_nonseizure;
    wire [DIMENSIONS - 1:0] out_hv_seizure;

    cont_mem #(
        .DIMENSIONS(DIMENSIONS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_cont_mem(
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .label_override (label_override),
        .override_hv_nonseizure (override_hv_nonseizure),
        .override_hv_seizure (override_hv_seizure),
        .hv_train  (hv_train),
        .label (label),
        .done (done),
        .out_hv_nonseizure  (out_hv_nonseizure),
        .out_hv_seizure  (out_hv_seizure)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_cont_mem.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        label_override = 1;
        override_hv_nonseizure = 6'b000001;
        override_hv_seizure = 6'b111110;
        hv_train = 6'b000000;
        label = 0;
        # (20 - 5)
        nrst = 1;
        # 100
        nrst = 0;
        label_override = 0;
        # 10
        nrst = 1;
        # 10
        en = 1;
        hv_train = 6'b100001;
        label = 0;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        en = 1;
        hv_train = 6'b110000;
        label = 0;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        en = 1;
        hv_train = 6'b110001;
        label = 0;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        en = 1;
        hv_train = 6'b110111;
        label = 1;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        en = 1;
        hv_train = 6'b011110;
        label = 1;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        en = 1;
        hv_train = 6'b111111;
        label = 1;
        # (5 + 5)
        en = 0;
        # (200 - 5)
        $finish;
    end
endmodule