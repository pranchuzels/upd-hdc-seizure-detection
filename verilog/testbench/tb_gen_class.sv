`timescale 1ms / 1us
module tb_gen_class ();
    localparam T = 3.90625;  // clock period in ns


    // General params
    parameter DIMENSIONS = 5;
    // Continuous memory params
    parameter START_NS_HV = 5'b00000;
    //parameter START_S_HV = 10000'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    parameter START_S_HV = 5'h10101;

    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS - 1:0] in_hv;
    reg op;
    reg trained_label;
    
    wire [DIMENSIONS - 1:0] ns_hv;
    wire [DIMENSIONS - 1:0] s_hv;
    wire predicted_label;

    gen_class #(
        .DIMENSIONS(DIMENSIONS),
        .START_NS_HV(START_NS_HV),
        .START_S_HV(START_S_HV)
    ) 
    u_gen_class(
        .clk  (clk),
        .nrst  (nrst),
        .en (en),
        .in_hv (in_hv),
        .op  (op),
        .trained_label (trained_label),
        
        .ns_hv (ns_hv),
        .s_hv (s_hv),
        .predicted_label (predicted_label)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        $vcdplusfile("tb_gen_class.vpd");
        $vcdpluson;
        nrst = 0;
        en = 0;
        in_hv = 5'b0;
        op = 0;
        trained_label = 0;
        #7
        nrst = 1;
        #(3.90625 * 10)
        en = 1;
        in_hv = 5'b11111;
        trained_label = 1;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b10001;
        trained_label = 0;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b11111;
        trained_label = 1;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        op = 1;
        in_hv = 5'b11111;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b11101;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b00111;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b00000;
        #3.90625
        en = 0;
        #3.90625
        en = 1;
        in_hv = 5'b00001;
        #3.90625
        $finish;
    end
endmodule