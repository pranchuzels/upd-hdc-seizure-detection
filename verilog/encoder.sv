`timescale 1ns / 1ps
module encoder (
    clk,
    nrst,
    sample_array,
    feature_set,
    window_hv
);
    // General params
    parameter DIMENSIONS = 10000;
    parameter WINDOW_SIZE = 256;
    parameter LBP_SIZE = 6;
    parameter NUM_LBP = 64;
    parameter NUM_CHS = 17;

    // Bundler Params
    // LFSR Params
    parameter NUM_REGS = 16;
    parameter SEED = 16'b1001010010110101;
    parameter NUM_VALS = 10000;
    parameter START_VAL = 10000'h18ba18cd34c7dc94459994489059d5d1727ff63ce5a7068874d5cf46763aa37435bde02c8a615f525adf981edee20bb2ce0b77b39a6207ac177a78ed5c266b1a98de26031c23514ba707d192b653c06b2729f88d8735e30ef1cb000ccf482cee18d6c2ff6b6d9d56233c90069a12f74e5cea09048e48cf9e9a00692a3ab2b2731e61ffc15f0679502a2d79adaaa887dccc1c9f4317d2015bc07e2ac3ef127bac6000c599dfcc697d0a6e65557f17d1941a72b5857869df563182f05fa9a36a00334c74c8886b547990549ea344d3f032aa73e1e55933c53764486eea474e4c6898f02461ee896a5cb61f30054e3073a6bb621e344763966f5f5bfacf24f595b0e6540dbc3744ded43fe7d5225186d6aa0c0883e2c8df5369e758756be6a97a4b5f550f034d456855e69f16bccc49f068159832bfe8c8952c9d04e8cf9b9bcb21242c445c26ac06f078cc15b653c79799f3475347867bbb74f0b173c399f8904e0b17940b712e203f66565726132d730822f10d0fc5a5c04bf8c7ff1d136fd1a2669ef14b7551fef48ce92065e8f61f651990e7fb005b4c3059b69643721d44bde04a6c981dc59fc970b7c66608e54abac83bb629c6a2965a0209156a4aa47928fb4455506dcbaf3acfdd7a6e537eb62e37508296a04c3599c771f69c00e86361f75186576c85e7ef204613ab015fb78b7600c951bd07c5e5796a0718c0672805255fda3e5ca52b3d851ba3ea92b0f5596afb7f5a0a02c11c6bcb624ce1389f47bbabdb5dcdb875ae65d65b95e3148b3d14faf53f07d086aafaca2f739b9dd4710cdb15c632761b1cbcd39c01ec336eadd5e2b0c374ffebe2c4b8c90a58c6b85520b77789dc2f8526d3ba8421a4daf1f616546467f0b6bfa643da060a8d9456d7cc7fc6ed2ecc925ab73e6590aafc5100e27bc44ed9503fac8bab022e0c541c7db9098ed06da2334d390d47dcf1bc19e9a4569fdc98f2c5d14f25fb4e860a67c178a0450e4cef8113706314012deea786500a4e8777e844b96ef0978a86bd931b610589fb33b3ba0035d7b8f5fce02cd70d5eb393e5e7895ad90dad3b6790d4a257b6f2102ce41bf5de0ee2aa94b7765bcd9f49fc8407b77e7f1bd63d16c2d671d43e333d5cc99e859ba85acbcbf54552a76d37078b828cba4fbd6b879514e2449d4b356fe9fa34fd0301e0be4f05ea46ba559a6a4804566e06ca2372bef5222f68ac87e653d68e260044ae074b1f2bbf5ca911915223fdc3100a920793791eda1012415f2406b49a1869ebbccb09eff6271e19ee60b99bc34babbfc617e8ba79acb218728fb04a6ed23ef066428fdc1e0b51dfcd7224bccccfc469d6449046db065faf6e05f7071cdef53aaa0dcc2cef907da5075f26d4a8519412f27c9d632f8a3151573b6423046e8d3d6548aa157473c8555409a629f6a19abf95ea05111d4ce1bd411ee0af4ae45904de0099417cb849a0041c96f0beb7c21eb2654347062b50e79ca4bbd44f834adaf812382416df2d9ea1845a9d88fc74d0e33bc45d28c44e879c6016d95bba5450bbc88b35a913d00d31878d207efba4efeb025636bbd35b45181a914b45e663b3bfe3fdf490f49bfc85a42857fceb60e08942fc61d692e1a919161299888fe6924601d29683c13d12e6bc85fb69c2aec8b76c10add214098a2f7e3d2e3dfa2c00748afa0a46582e1cc8db2b07379b224bd7790aebd100c9e99ce7860c726de61e17eaecdfb88ed8516cbe15d1f04edc914794e4f03d6fc3;


    input clk;
    input nrst;
    input [1:0] feature_set;
    input real sample_array [NUM_CHS - 1: 0][WINDOW_SIZE + LBP_SIZE - 1:0]; // 256 + 6 = 262
    output reg [DIMENSIONS - 1:0] window_hv;

    // Feature Item HVs
    wire [DIMENSIONS - 1:0] ch_hv [17 - 1: 0];
    wire [DIMENSIONS - 1:0] lbp_hv [64 - 1: 0];

    reg curr_lbp [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][LBP_SIZE - 1: 0];
    reg [DIMENSIONS - 1: 0] samples_lbp [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0];
    reg [DIMENSIONS - 1: 0] binded_lbp_ch [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0];
    reg [DIMENSIONS - 1: 0] bundled_sample_hv [WINDOW_SIZE - 1: 0];

    typedef bit [LBP_SIZE - 1: 0] bs_t;

    item_mem #(
    ) 
    enc_item_mem(
        .ch_hv (ch_hv),
        .lbp_hv  (lbp_hv)
    );

    // Generate channel-lbp binding
    generate
        genvar i;
        genvar c;
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            for (c = 0; c < NUM_CHS; c = c + 1) begin
                binder #(
                    .DIMENSIONS(DIMENSIONS)
                ) 
                lbp_binder(
                    .hv1  (samples_lbp[i][c]),
                    .hv2 (ch_hv[c]),
                    .hvout  (binded_lbp_ch[i][c])
                );
            end
        end
    endgenerate

    // Generate channel-lbp bundling
    generate
        genvar l;
        for (l = 0; l < WINDOW_SIZE; l = l + 1) begin
            bundler_ch #(
                .DIMENSIONS(DIMENSIONS),
                .NUM_HVS(NUM_CHS),
                .NUM_REGS(NUM_REGS),
                .SEED(SEED),
                .NUM_VALS(NUM_VALS),
                .START_VAL(START_VAL)
            ) 
            lbp_bundler_ch(
                .clk  (clk),
                .nrst  (nrst),
                .hv_array  (binded_lbp_ch[l]),
                .hvout  (bundled_sample_hv[l])
            );
        end
    endgenerate

    // Generate window bundling
    generate
        bundler_ch #(
            .DIMENSIONS(DIMENSIONS),
            .NUM_HVS(WINDOW_SIZE),
            .NUM_REGS(NUM_REGS),
            .SEED(SEED),
            .NUM_VALS(NUM_VALS),
            .START_VAL(START_VAL)
        ) 
        window_bundler_ch(
            .clk  (clk),
            .nrst  (nrst),
            .hv_array  (bundled_sample_hv),
            .hvout  (window_hv)
        );
    endgenerate

    always @(posedge clk) begin
        if (!nrst) begin
            //
        end else begin
            if (feature_set == 2'b0) begin

                // Extract 
                for (int i = LBP_SIZE; i < WINDOW_SIZE + LBP_SIZE; i = i + 1) begin
                    for (int c = 0; c < NUM_CHS; c = c + 1) begin
                        for (int j = 0 - LBP_SIZE; j < 0; j = j + 1) begin
                            if (sample_array[c][i + j] < sample_array[c][i + j + 1]) begin
                                curr_lbp[i - LBP_SIZE][c][j + LBP_SIZE] = 1'b1;
                            end
                            else if (sample_array[c][i + j] > sample_array[c][i + j + 1]) begin
                                curr_lbp[i - LBP_SIZE][c][j + LBP_SIZE] = 1'b0;
                            end
                            else begin
                                curr_lbp[i - LBP_SIZE][c][j + LBP_SIZE] = 1'b1; // randomize later
                            end
                        end
                        samples_lbp[i - LBP_SIZE][c] = lbp_hv[bs_t'({ << {curr_lbp[i - LBP_SIZE][c]}})];
                    end
                end
            end
        end
    end

endmodule