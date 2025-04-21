`timescale 1ns / 1ps
 
module tb_lfsr_mapped;
    localparam T = 10;  // clock period in ns

    localparam NUM_REGS = 32;
    localparam SEED = 32'hee84d6f0;
    localparam [$clog2(NUM_REGS) - 1: 0] TAPS [3: 0] = {0, 2, 6, 7};

    reg clk;
    reg nrst;
    reg en;
    wire out_tie;
    
    lfsr #(
        .NUM_REGS(NUM_REGS),
        .SEED(SEED),
        .TAPS(TAPS)
    ) 
    u_lfsr (
        .clk  (clk),
        .nrst (nrst),
        .en   (en),
        .out_tie  (out_tie)
    );
    
    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end
    
    initial begin
        // $dumpfile("lfsr_mapped.dump");
        // $dumpvars(0,tb_lfsr_mapped);
        
        // $vcdplusfile("tb_lfsr_mapped.vpd");
        // $vcdpluson;
        $sdf_annotate("../mapped/lfsr_mapped.sdf", u_lfsr);
        nrst = 1'b0;
        en = 0;
        #15
        nrst = 1'b1;
        $dumpon;
        for (int i = 0; i < 5; i = i + 1) begin
            en = 1;
            # 10
            en = 0;
        end
        # 15
        $finish;
    end
endmodule