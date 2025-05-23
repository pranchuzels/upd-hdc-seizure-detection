`timescale 1ns / 1ps
module tb_cont_mem ();
    localparam T = 10;  // clock period in ns


    // General params
    localparam DIMENSIONS = 6;
    localparam COUNT_SIZE = 8;


    reg clk;
    reg nrst;
    reg en;
    reg finish;
    reg [DIMENSIONS - 1:0] hv_train;
    reg label;

    wire done;
    wire [DIMENSIONS - 1:0] hv_nonseizure;
    wire [DIMENSIONS - 1:0] hv_seizure;

    cont_mem #(
        .DIMENSIONS(DIMENSIONS),
        .COUNT_SIZE(COUNT_SIZE)
    ) u_cont_mem (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .finish(finish),
        .hv_train(hv_train),
        .label(label),
        .done(done),
        .hv_nonseizure(hv_nonseizure),
        .hv_seizure(hv_seizure)
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
        finish = 0;
        hv_train = 6'b000000;
        label = 0;
        # (20 - 5)
        nrst = 1;
        
        en = 1;
        hv_train = 6'b100001;
        label = 0;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        en = 1;
        hv_train = 6'b110000;
        label = 0;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        en = 1;
        hv_train = 6'b110001;
        label = 0;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        finish = 1;
        # (5 + 5)
        finish = 0;
        # (20 - 5 - 5)

        nrst = 0;
        # (5 + 5)
        nrst = 1;
        # (20 - 5 - 5)


        en = 1;
        hv_train = 6'b110111;
        label = 1;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        en = 1;
        hv_train = 6'b011110;
        label = 1;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        en = 1;
        hv_train = 6'b111111;
        label = 1;
        # (5 + 5)
        en = 0;
        # (50 - 5 - 5)

        finish = 1;
        # (5 + 5)
        finish = 0;
        # (20 - 5 - 5)

        $finish;
    end
endmodule