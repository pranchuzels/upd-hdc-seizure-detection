`timescale 1ms / 1us

module similarity (
    hv,
    ns_hv,
    s_hv,
    label_out
);

    parameter DIMENSIONS = 10000;

    input [DIMENSIONS - 1:0] hv;
    input [DIMENSIONS - 1:0] ns_hv;
    input [DIMENSIONS - 1:0] s_hv;
    output reg label_out;

    integer hv_xor_ns;
    integer hv_xor_s;
    integer i;
    
    always @(*) begin

        hv_xor_ns = 0;
        hv_xor_s = 0;

        for (i = 0; i < DIMENSIONS; i = i + 1) begin
            if (hv[i] ^ ns_hv[i] == 1'b1)
                hv_xor_ns = hv_xor_ns + 1;
            if (hv[i] ^ s_hv[i] == 1'b1)
                hv_xor_s = hv_xor_s + 1;
        end

        if (hv_xor_ns < hv_xor_s)
            label_out = 0;
        else
            label_out = 1;
    end

endmodule