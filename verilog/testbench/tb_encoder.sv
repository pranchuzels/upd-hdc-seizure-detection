`timescale 1ns / 1ps
module tb_encoder ();
    localparam T = 10;  // clock period in ns

    // General params
    localparam DIMENSIONS = 10000;
    localparam WINDOW_SIZE = 2;
    localparam LBP_SIZE = 6;
    localparam NUM_LBP = 64;
    localparam NUM_CHS = 2;

    // Bundler Params
    // LFSR Params
    localparam NUM_REGS = 16;
    localparam SEED = 16'b1001010010110101;
    localparam NUM_VALS = 10000;
    localparam START_VAL = 10000'h18ba18cd34c7dc94459994489059d5d1727ff63ce5a7068874d5cf46763aa37435bde02c8a615f525adf981edee20bb2ce0b77b39a6207ac177a78ed5c266b1a98de26031c23514ba707d192b653c06b2729f88d8735e30ef1cb000ccf482cee18d6c2ff6b6d9d56233c90069a12f74e5cea09048e48cf9e9a00692a3ab2b2731e61ffc15f0679502a2d79adaaa887dccc1c9f4317d2015bc07e2ac3ef127bac6000c599dfcc697d0a6e65557f17d1941a72b5857869df563182f05fa9a36a00334c74c8886b547990549ea344d3f032aa73e1e55933c53764486eea474e4c6898f02461ee896a5cb61f30054e3073a6bb621e344763966f5f5bfacf24f595b0e6540dbc3744ded43fe7d5225186d6aa0c0883e2c8df5369e758756be6a97a4b5f550f034d456855e69f16bccc49f068159832bfe8c8952c9d04e8cf9b9bcb21242c445c26ac06f078cc15b653c79799f3475347867bbb74f0b173c399f8904e0b17940b712e203f66565726132d730822f10d0fc5a5c04bf8c7ff1d136fd1a2669ef14b7551fef48ce92065e8f61f651990e7fb005b4c3059b69643721d44bde04a6c981dc59fc970b7c66608e54abac83bb629c6a2965a0209156a4aa47928fb4455506dcbaf3acfdd7a6e537eb62e37508296a04c3599c771f69c00e86361f75186576c85e7ef204613ab015fb78b7600c951bd07c5e5796a0718c0672805255fda3e5ca52b3d851ba3ea92b0f5596afb7f5a0a02c11c6bcb624ce1389f47bbabdb5dcdb875ae65d65b95e3148b3d14faf53f07d086aafaca2f739b9dd4710cdb15c632761b1cbcd39c01ec336eadd5e2b0c374ffebe2c4b8c90a58c6b85520b77789dc2f8526d3ba8421a4daf1f616546467f0b6bfa643da060a8d9456d7cc7fc6ed2ecc925ab73e6590aafc5100e27bc44ed9503fac8bab022e0c541c7db9098ed06da2334d390d47dcf1bc19e9a4569fdc98f2c5d14f25fb4e860a67c178a0450e4cef8113706314012deea786500a4e8777e844b96ef0978a86bd931b610589fb33b3ba0035d7b8f5fce02cd70d5eb393e5e7895ad90dad3b6790d4a257b6f2102ce41bf5de0ee2aa94b7765bcd9f49fc8407b77e7f1bd63d16c2d671d43e333d5cc99e859ba85acbcbf54552a76d37078b828cba4fbd6b879514e2449d4b356fe9fa34fd0301e0be4f05ea46ba559a6a4804566e06ca2372bef5222f68ac87e653d68e260044ae074b1f2bbf5ca911915223fdc3100a920793791eda1012415f2406b49a1869ebbccb09eff6271e19ee60b99bc34babbfc617e8ba79acb218728fb04a6ed23ef066428fdc1e0b51dfcd7224bccccfc469d6449046db065faf6e05f7071cdef53aaa0dcc2cef907da5075f26d4a8519412f27c9d632f8a3151573b6423046e8d3d6548aa157473c8555409a629f6a19abf95ea05111d4ce1bd411ee0af4ae45904de0099417cb849a0041c96f0beb7c21eb2654347062b50e79ca4bbd44f834adaf812382416df2d9ea1845a9d88fc74d0e33bc45d28c44e879c6016d95bba5450bbc88b35a913d00d31878d207efba4efeb025636bbd35b45181a914b45e663b3bfe3fdf490f49bfc85a42857fceb60e08942fc61d692e1a919161299888fe6924601d29683c13d12e6bc85fb69c2aec8b76c10add214098a2f7e3d2e3dfa2c00748afa0a46582e1cc8db2b07379b224bd7790aebd100c9e99ce7860c726de61e17eaecdfb88ed8516cbe15d1f04edc914794e4f03d6fc3;
  

    reg clk;
    reg nrst;
    reg [1:0] feature_set;
    real sample_array [NUM_CHS - 1: 0][WINDOW_SIZE + LBP_SIZE - 1:0];
    wire [DIMENSIONS - 1:0] window_hv;

    encoder #(
        .DIMENSIONS(DIMENSIONS),
        .WINDOW_SIZE(WINDOW_SIZE),
        .LBP_SIZE(LBP_SIZE),
        .NUM_LBP(NUM_LBP),
        .NUM_CHS(NUM_CHS),
        .NUM_REGS(NUM_REGS),
        .SEED(SEED),
        .NUM_VALS(NUM_VALS),
        .START_VAL(START_VAL)
    ) 
    u_encoder(   
        .clk (clk),
        .nrst (nrst),
        .sample_array (sample_array),
        .feature_set (feature_set),
        .window_hv (window_hv)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        $vcdplusfile("tb_encoder.vpd");
        $vcdpluson;
        nrst = 0;
        #25
        nrst = 1;
        feature_set = 0;
        sample_array[0][0] = 4.884004884004884e-06;
        sample_array[0][1] = 1.367521367521367e-06;
        sample_array[0][2] = -6.446886446886447e-06;
        sample_array[0][3] = -1.6605616605616607e-05;
        sample_array[0][4] = -2.5982905982905982e-05;
        sample_array[0][5] = -4.239316239316239e-05;
        sample_array[0][6] =  -5.137973137973138e-05;
        sample_array[0][7] = 4.884004884004884e-06;
        sample_array[1][0] = -1.6605616605616607e-05;
        sample_array[1][1] = -1.6996336996336996e-05;
        sample_array[1][2] = -1.9340659340659342e-05;
        sample_array[1][3] = -2.0903540903540904e-05;
        sample_array[1][4] = -2.0903540903540904e-05;
        sample_array[1][5] = -2.442002442002442e-05;
        sample_array[1][6] = -1.4261294261294262e-05;
        sample_array[1][7] = -1.6605616605616607e-05;
        #10
        #5
        $finish;
    end
endmodule