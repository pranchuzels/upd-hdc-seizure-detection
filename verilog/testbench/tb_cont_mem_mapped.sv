`timescale 1ns / 1ps
module tb_cont_mem_mapped ();
    localparam T = 10;  // clock period in ns


    // General params
    localparam DIMENSIONS = 10000;
    localparam PAR_BITS = 10;

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
        $dumpfile("cont_mem_mapped.dump");
        $dumpvars(0,tb_cont_mem_mapped);
        
        $sdf_annotate("../mapped/cont_mem_mapped.sdf", u_cont_mem);
        nrst = 0;
        en = 0;
        label_override = 0;
        override_hv_nonseizure = 10000'h0;
        override_hv_seizure = 10000'h0;
        hv_train = 0;
        label = 0;
        # (20 - 5)
        $dumpon;
        nrst = 1;
        # (5 + 5)
        en = 1;
        hv_train = 10000'h79efeb5f9b06cce570845f1c0c2f5491ba6c6b3ed259ab2a519157d1b1fe6544f4c2a10c1998d6918a647d804ea8f7f8c38126188a6758de64e3fb15b460367e69d462e5068cff26d97d04cea613778ed12ead49c15caaca933c653a29132a89978151eb7ff90f85bd7632689de7803da0405e6103ea70baa6876e28277864ba8bd36eb42ec3b913465b871974709d1e97dcd3d450df39b1f8aa50c06e1f7e6bd112a137f2ac386626e7d63c8759a7592e3f34691f6c856b11ff86ce374ccfd40491d96bea1c8f3f827675780ff9825d1c950d3066bc87efed0acf96135a9964ce48389669d6b8aa078cd26e2a1f7b31db38b2f25ba620a0e8635cbe5ce3263;
        label = 0;
        # (5 + 5)
        en = 0;
        # (5 + 5)
        wait (u_cont_mem.done == 1);
        $dumpoff;
        # (20 - 5)
        $finish;
    end
endmodule