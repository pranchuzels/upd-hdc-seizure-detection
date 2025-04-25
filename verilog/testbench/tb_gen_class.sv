`timescale 1ms / 1us
module tb_gen_class ();
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
    reg [DIMENSIONS - 1:0] window_hv;
    reg op;
    reg label_train;
    wire done;
    wire [DIMENSIONS - 1:0] out_hv_nonseizure;
    wire [DIMENSIONS - 1:0] out_hv_seizure;
    wire label_predict;


    gen_class #(
        .DIMENSIONS(DIMENSIONS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_gen_class(
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .label_override(label_override),
        .override_hv_nonseizure(override_hv_nonseizure),
        .override_hv_seizure(override_hv_seizure),
        .window_hv  (window_hv),
        .op (op),
        .label_train  (label_train),
        .done  (done),
        .out_hv_nonseizure  (out_hv_nonseizure),
        .out_hv_seizure  (out_hv_seizure),
        .label_predict  (label_predict)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_gen_class.vpd");
        // $vcdpluson;

        nrst = 0;
        en = 0;
        label_override = 0;
        override_hv_nonseizure = 0;
        override_hv_seizure = 0;

        window_hv = 6'b0;
        op = 0;
        label_train = 0;
        # (20 - 5)
        nrst = 1;

        en = 1;
        window_hv = 6'b000010;
        op = 0;
        label_train = 0;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        window_hv = 6'b000011;
        op = 0;
        label_train = 0;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        window_hv = 6'b111101;
        op = 0;
        label_train = 1;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        window_hv = 6'b101100;
        op = 0;
        label_train = 1;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)
        label_train = 0;

        en = 1;
        window_hv = 6'b000001;
        op = 1;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)

        en = 1;
        window_hv = 6'b111100;
        op = 1;
        # (5 + 5)
        en = 0;
        # (200 - 5 - 5)
        $finish;
    end
endmodule