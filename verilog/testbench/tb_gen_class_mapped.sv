`timescale 1ms / 1us
module tb_gen_class_mapped ();
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

        $dumpfile("gen_class_mapped.dump");
        $dumpvars(0,tb_gen_class_mapped);
        
        $sdf_annotate("../mapped/gen_class_mapped.sdf", u_gen_class);

        nrst = 0;
        en = 0;
        label_override = 0;
        override_hv_nonseizure = 0;
        override_hv_seizure = 0;

        window_hv = 0;
        op = 0;
        label_train = 0;
        # (20 - 5)
        $dumpon;
        nrst = 1;
        en = 1;
        window_hv = 10000'he9bbc5ddcdc53726fb971a255ed0b43449fe1507a258c1f05e84c25d536b6ace5e82f95afdaf68085faa366927d2e42b2971d1b5b88aca17a80740baa1c5d7cbe554aec7ef5288de7a58ae8843442f2af3f7d7502e36022409187b2c202e9b465e88a354cf8138f7ba089b4985a31fb4a6472dea48e2cc2035f9ba86fb5ffc32ffb0b4a1287434820bb586ad06d8d56ca2159b4841d78dd4a29105e123c05e97785bd198a1a1a1a246f5a6d5a7da0b0446bdd781fec29b97171ee825077cfcf10804c37f06af878489a3a975adbdcffa35a23f969e6c2d25955c48c97e038a89ea873da3113ef7b80a6c7143eb68b3af3265f6282cc087ddc0476a9033768186068cfca43a9fa3dfee57cd46df31eed18241d86d9d1603becddc2eda4bee0f48ab8e63cbc77afc5687b628dfc9d198597f2f0f3cd7e78b52390a3c5c40b93dea6daaa0053a88b8fa1a903d208a8ddb34ce198172cbefff2f5b2a94b2e2b3fb11b88aa23254a7bb800c9560606f7ac6432ded9da0b21bc6129a5ab1285aa06b21892107d3ee28dc1b454bea00a420c10be78220180b76efb5c2acc86f6cde18e859e37ec756783b243f356c96d78685e92bb8403598a41aeb064de7067566e1f23ad895fc70950970a0fafcce607f5acda1c919eb144933803ccf6a1d244700c8ca22e0c89d44ddfdf3a6c3cb6545a5d03e1c4ced4db84e1b4b4ee88458a6bbf64e462c9265fd6d4ff0bb734bb6bebc05e1eee08f5a03bd27a96468a1caca3804768d51b2cf7ef2cb5d84a5cc1ceb3ff904abe37cdbfbe4f60905379da31f0ec916b2fe4a2b45fa8ac3a1392a4cbba87047bd32ec741570e9a4a37145493edd6811a3e49672812bc169edae69050087ebbd2db9099d98bed4bf9316e85a2ada9cfd0effd7e79793f6dd9e36076c183b9ef6339c6104f3dbbe651cfb230a415761fd3438fcb74bd3604fc48609ff95a966c206de35941941103e0fb2f888e2e207c0d5cf403be8610ba6c7ffe6f3aa59b0bd441b9e2010f5532cf65587a2b3757b72b613a7eb68f0190dfbce60128a02087d4522453a5817fd12a8112f42e7cb508ef9a29f5aca19cb9da31dc92c0cdcc6d38d9f8c44bccf9268d4dd117c8cc8d14008019358d34c458a2f4274c8e3a30ffc1f5382e5952fee1cf2178bcea4f21700806b1abd73549ec9bcfb8ee56c7636327cec53214cdafc1f6ec548c2e516cb3b4e5618c480803515f1765a712f72e6818a80446f975de8f496a4d458a78554f2f26b9f1fba67912999cbc529e422a2e22e08e0c377432eb64fce57d63a143ad79246f96b3f0330f40818a5751af02090d14608ce12e894b7562e7d867fe3023d382f83188be759f76ffc675e4f1e240937085f14455b4bcc3cc05723e40ce14fbdaaf0f81312db8bfa63c5d624b98f585c6c1fc103527ae5b961be7a3d7c7abca5af87b204b43a0903d8ac9484b26b751ef73bae5c408ded43d4b1d86f229d24938d225f8e0b4850fae01d66884630dbd9e940ff22a716f5130cdb661154021345a3975844b8afc997bee48883d8146a8bf8e448d99dca0596acdec4fa4ba21ee652ce9ccb075f0c6b0e14f75004d95ceafd85e7ea145271a0be1dea0181b1477a8ef0801b16e56efe45073892028c9111e5007b912710b02a986d3b4b61e212717e53b60d11a74cb76ced6d5859ff602633519753f2fa1b03b9407309d8d011f02b7463d6864823bcbd3b9c11a9746bc7030f083862eef42f07e01cc7a30335f4;
        op = 0;
        label_train = 1;
        # (5 + 5)
        en = 0;
        # (5 + 5)
        wait (u_gen_class.done == 1);
        # (20 - 5)
        $finish;
    end
endmodule