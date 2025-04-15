`timescale 1ns / 1ps
 
module tb_similarity_mapped;
    localparam T = 10;  // clock period in ms

  // General Params
  localparam DIMENSIONS = 10000;

  // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS - 1 : 0] hv_test;
    reg [DIMENSIONS - 1 : 0] hv_nonseizure;
    reg [DIMENSIONS - 1 : 0] hv_seizure;
    wire done;
    wire label;
 
  similarity #(
    .DIMENSIONS(DIMENSIONS)
  ) 
  u_similarity(
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .hv_test(hv_test),
        .hv_nonseizure(hv_nonseizure),
        .hv_seizure(hv_seizure),
        .done(done),
        .label(label)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        $dumpfile("similarity_mapped.dump");
        $dumpvars(0,tb_similarity_mapped);
        
        $vcdplusfile("tb_similarity_mapped.vpd");
        $vcdpluson;
        $sdf_annotate("../mapped/similarity_mapped.sdf", u_similarity);
        
        nrst = 0;
        en = 0;
        hv_test = 0;
        hv_seizure = 10000'h669ff6a5b9b06c0f131e456140c275591126c6f36d39baa2e41b116d293ff6556f0c2a18d1998f6910b545f804ea8b76c4281a618ca4758fe64e1d870b440367ee954632d068cef268ddddf9a261377de903ebe4d415c8a861030e53ab091240952f909fb3ffb0f469f7e26481d63803d72607c5403eb52baa6056e282678e5bb8ad1b6906342bb130419ce1974709c1c96fd52c454fd3a99d8ab56c46ebd2e6bd0520c3d76bd7c7664e75e388639ef198a3f25281d6ca57f117f829e37ddc7942e15596bea5c8b7f1636e5048fb1025f84052932269c85f7450ace96535bbc64ed447a84299ee82b1e8cde7a1a1e2374db1830f343060a10e971c8ba6ce7670;
        hv_nonseizure = 10000'h649dffbbfa580f3711e4a7307ac756499a3ac6b36d498a20a3f335bd3c5f105d2fc0623da191cf6a189455c81dee097cd82403b15824f58f4f4a5dceaa8609e3669f3203713de2e7a892ff7cbac04978def0af74141bc38c548d061b8d37a3099b21841eb37a96326d706a2649beea899204d2e81e3adf1ea66d42e24b7b049b686406e846e54991154b8161874e88c4c7590da5465ae3acafbca464556a32a76f387e431f3adeaff7cd46f69a62b87500dfbac695948f466327c128eceb65f8d2e3df15b8c1ac2f6e3b7fda00b811231959539366e3e9863cd1a7e9a57f99000cc55781473ded0a9988d5a26303e29340af0dec0f79e5484eae2ca1ee86da64;
        # (20 - 5)
        $dumpon;
        nrst = 1;
        en = 1;
        hv_test = 10000'h79efeb5f9b06cce570845f1c0c2f5491ba6c6b3ed259ab2a519157d1b1fe6544f4c2a10c1998d6918a647d804ea8f7f8c38126188a6758de64e3fb15b460367e69d462e5068cff26d97d04cea613778ed12ead49c15caaca933c653a29132a89978151eb7ff90f85bd7632689de7803da0405e6103ea70baa6876e28277864ba8bd36eb42ec3b913465b871974709d1e97dcd3d450df39b1f8aa50c06e1f7e6bd112a137f2ac386626e7d63c8759a7592e3f34691f6c856b11ff86ce374ccfd40491d96bea1c8f3f827675780ff9825d1c950d3066bc87efed0acf96135a9964ce48389669d6b8aa078cd26e2a1f7b31db38b2f25ba620a0e8635cbe5ce3263;
        # (5 + 5)
        en = 0;
        wait (u_similarity.done == 1);
        $dumpoff;
        # (20 - 5)
        $finish;
    end
endmodule