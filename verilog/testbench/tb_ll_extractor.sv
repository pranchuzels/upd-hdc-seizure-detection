`timescale 1ns / 1ps
module tb_ll_extractor ();
    localparam T = 1000;  // clock period in ns

    // General params
    localparam DIMENSIONS = 10000;
    localparam NUM_CHS = 17;
    localparam WINDOW_SIZE = 256;
    localparam WINDOW_STEP = 128;
    localparam SAMPLE_SIZE = 16;

    // Feature params
    parameter NUM_LL = 64;
    parameter LL_MIN_PATIENT = 16'b0;
    parameter LL_MAX_PATIENT = 16'b0000010000001110;


    reg clk;
    reg nrst;
    reg en;
    reg [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    wire done;
    wire [$clog2(NUM_LL) - 1:0] ll;

    ll_extractor u_ll_extractor(   
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .samples (samples),
        .done (done),
        .ll (ll)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_lbp_encoder.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        samples = 0;
        # (2000 - 500)
        nrst = 1;

        en = 1;
        samples[0] = 16'b1111110111101011;
        samples[1] = 16'b1111111000111001;
        samples[2] = 16'b1111111001110101;
        samples[3] = 16'b1111111011001111;
        samples[4] = 16'b1111111100100100;
        samples[5] = 16'b1111111101110010;
        samples[6] = 16'b1111111110100111;
        samples[7] = 16'b1111111110100111;
        samples[8] = 16'b1111111111010011;
        samples[9] = 16'b1111111111000110;
        samples[10] = 16'b1111111101000011;
        samples[11] = 16'b1111111101000110;
        samples[12] = 16'b1111111101000011;
        samples[13] = 16'b1111111101100010;
        samples[14] = 16'b1111111101101000;
        samples[15] = 16'b1111111101111110;
        samples[16] = 16'b1111111101010011;
        samples[17] = 16'b1111111101000011;
        samples[18] = 16'b1111111101001111;
        samples[19] = 16'b1111111101011001;
        samples[20] = 16'b1111111101011111;
        samples[21] = 16'b1111111101101000;
        samples[22] = 16'b1111111110010111;
        samples[23] = 16'b1111111110001000;
        samples[24] = 16'b1111111101010011;
        samples[25] = 16'b1111111101001001;
        samples[26] = 16'b1111111011101110;
        samples[27] = 16'b1111111010100000;
        samples[28] = 16'b1111111010111001;
        samples[29] = 16'b1111111011011001;
        samples[30] = 16'b1111111100100001;
        samples[31] = 16'b1111111100101010;
        samples[32] = 16'b1111111100100111;
        samples[33] = 16'b1111111011010101;
        samples[34] = 16'b1111111011110101;
        samples[35] = 16'b1111111100000100;
        samples[36] = 16'b1111111011111011;
        samples[37] = 16'b1111111100110000;
        samples[38] = 16'b1111111101001100;
        samples[39] = 16'b1111111101010011;
        samples[40] = 16'b1111111101000011;
        samples[41] = 16'b1111111100100100;
        samples[42] = 16'b1111111101000110;
        samples[43] = 16'b1111111101110010;
        samples[44] = 16'b1111111110110011;
        samples[45] = 16'b1111111111111011;
        samples[46] = 16'b0000000000111010;
        samples[47] = 16'b0000000001010011;
        samples[48] = 16'b0000000010100001;
        samples[49] = 16'b0000000011010000;
        samples[50] = 16'b0000000011111100;
        samples[51] = 16'b0000000100110001;
        samples[52] = 16'b0000000101010000;
        samples[53] = 16'b0000000101010110;
        samples[54] = 16'b0000000101011101;
        samples[55] = 16'b0000000110011011;
        samples[56] = 16'b0000000110110111;
        samples[57] = 16'b0000000110100001;
        samples[58] = 16'b0000000101111111;
        samples[59] = 16'b0000000110100100;
        samples[60] = 16'b0000000100110001;
        samples[61] = 16'b0000000101010000;
        samples[62] = 16'b0000000101111001;
        samples[63] = 16'b0000000101000100;
        samples[64] = 16'b0000000101100000;
        samples[65] = 16'b0000000101101100;
        samples[66] = 16'b0000000100110001;
        samples[67] = 16'b0000000100100100;
        samples[68] = 16'b0000000101010000;
        samples[69] = 16'b0000000101111001;
        samples[70] = 16'b0000000101010000;
        samples[71] = 16'b0000000100100100;
        samples[72] = 16'b0000000011010110;
        samples[73] = 16'b0000000001010011;
        samples[74] = 16'b1111111110110111;
        samples[75] = 16'b1111111101011001;
        samples[76] = 16'b1111111100010111;
        samples[77] = 16'b1111111100001110;
        samples[78] = 16'b1111111100100111;
        samples[79] = 16'b1111111100000100;
        samples[80] = 16'b1111111011111011;
        samples[81] = 16'b1111111011100101;
        samples[82] = 16'b1111111011110101;
        samples[83] = 16'b1111111100000001;
        samples[84] = 16'b1111111100001011;
        samples[85] = 16'b1111111101011100;
        samples[86] = 16'b1111111110101101;
        samples[87] = 16'b1111111110000001;
        samples[88] = 16'b1111111110000001;
        samples[89] = 16'b1111111110000001;
        samples[90] = 16'b1111111100100100;
        samples[91] = 16'b1111111011101110;
        samples[92] = 16'b1111111011000011;
        samples[93] = 16'b1111111010110000;
        samples[94] = 16'b1111111001101000;
        samples[95] = 16'b1111111001001111;
        samples[96] = 16'b1111111000110011;
        samples[97] = 16'b1111110111101110;
        samples[98] = 16'b1111110111110100;
        samples[99] = 16'b1111110111111011;
        samples[100] = 16'b1111111000000001;
        samples[101] = 16'b1111110111111110;
        samples[102] = 16'b1111111001100101;
        samples[103] = 16'b1111111001110101;
        samples[104] = 16'b1111111010000100;
        samples[105] = 16'b1111111001111110;
        samples[106] = 16'b1111111010000001;
        samples[107] = 16'b1111111010011010;
        samples[108] = 16'b1111111001001001;
        samples[109] = 16'b1111111010010111;
        samples[110] = 16'b1111111001011100;
        samples[111] = 16'b1111111001111110;
        samples[112] = 16'b1111111010111100;
        samples[113] = 16'b1111111100000001;
        samples[114] = 16'b1111111101011001;
        samples[115] = 16'b1111111110000001;
        samples[116] = 16'b1111111110011110;
        samples[117] = 16'b1111111110100111;
        samples[118] = 16'b1111111110011010;
        samples[119] = 16'b0000000000000010;
        samples[120] = 16'b0000000000110000;
        samples[121] = 16'b0000000001000110;
        samples[122] = 16'b0000000000111101;
        samples[123] = 16'b0000000001100010;
        samples[124] = 16'b0000000011001010;
        samples[125] = 16'b0000000011111000;
        samples[126] = 16'b0000000100111010;
        samples[127] = 16'b0000000101010000;
        samples[128] = 16'b0000000101000100;
        samples[129] = 16'b0000000101110110;
        samples[130] = 16'b0000000110011110;
        samples[131] = 16'b0000000110011000;
        samples[132] = 16'b0000000111000100;
        samples[133] = 16'b0000000110111101;
        samples[134] = 16'b0000000101101100;
        samples[135] = 16'b0000000100111010;
        samples[136] = 16'b0000000101111001;
        samples[137] = 16'b0000000101110010;
        samples[138] = 16'b0000000101110010;
        samples[139] = 16'b0000000111001101;
        samples[140] = 16'b0000000110101110;
        samples[141] = 16'b0000001000011110;
        samples[142] = 16'b0000001001000111;
        samples[143] = 16'b0000001001001010;
        samples[144] = 16'b0000001001010011;
        samples[145] = 16'b0000001000011110;
        samples[146] = 16'b0000001000101110;
        samples[147] = 16'b0000000111100110;
        samples[148] = 16'b0000000110110111;
        samples[149] = 16'b0000000110110001;
        samples[150] = 16'b0000000110100100;
        samples[151] = 16'b0000000101100011;
        samples[152] = 16'b0000000101101001;
        samples[153] = 16'b0000000101100110;
        samples[154] = 16'b0000000101000000;
        samples[155] = 16'b0000000100010101;
        samples[156] = 16'b0000000011111000;
        samples[157] = 16'b0000000100111101;
        samples[158] = 16'b0000000011111111;
        samples[159] = 16'b0000000100110111;
        samples[160] = 16'b0000000100110100;
        samples[161] = 16'b0000000011011111;
        samples[162] = 16'b0000000011010110;
        samples[163] = 16'b0000000011101001;
        samples[164] = 16'b0000000010001110;
        samples[165] = 16'b0000000001100010;
        samples[166] = 16'b0000000001011100;
        samples[167] = 16'b0000000000010001;
        samples[168] = 16'b0000000000000010;
        samples[169] = 16'b1111111111100010;
        samples[170] = 16'b1111111111010110;
        samples[171] = 16'b1111111111011100;
        samples[172] = 16'b1111111111010011;
        samples[173] = 16'b0000000000101010;
        samples[174] = 16'b0000000010100111;
        samples[175] = 16'b0000000101000000;
        samples[176] = 16'b0000000101111001;
        samples[177] = 16'b0000000110111010;
        samples[178] = 16'b0000000111011101;
        samples[179] = 16'b0000000111111111;
        samples[180] = 16'b0000001000011110;
        samples[181] = 16'b0000001000001100;
        samples[182] = 16'b0000000111001010;
        samples[183] = 16'b0000000101010000;
        samples[184] = 16'b0000000011010011;
        samples[185] = 16'b0000000000111010;
        samples[186] = 16'b1111111111001100;
        samples[187] = 16'b1111111110101101;
        samples[188] = 16'b1111111101111000;
        samples[189] = 16'b1111111111010110;
        samples[190] = 16'b1111111110110000;
        samples[191] = 16'b1111111110100111;
        samples[192] = 16'b1111111110111010;
        samples[193] = 16'b1111111111000000;
        samples[194] = 16'b1111111101101000;
        samples[195] = 16'b1111111101101000;
        samples[196] = 16'b1111111101000110;
        samples[197] = 16'b1111111011100101;
        samples[198] = 16'b1111111011101110;
        samples[199] = 16'b1111111010110011;
        samples[200] = 16'b1111111010101101;
        samples[201] = 16'b1111111010100111;
        samples[202] = 16'b1111111000111001;
        samples[203] = 16'b1111110111001100;
        samples[204] = 16'b1111110111001001;
        samples[205] = 16'b1111110111000110;
        samples[206] = 16'b1111110111100101;
        samples[207] = 16'b1111110111101110;
        samples[208] = 16'b1111111000001101;
        samples[209] = 16'b1111110111111011;
        samples[210] = 16'b1111110111110100;
        samples[211] = 16'b1111111000101010;
        samples[212] = 16'b1111111000011101;
        samples[213] = 16'b1111111000000100;
        samples[214] = 16'b1111111000101101;
        samples[215] = 16'b1111110111111000;
        samples[216] = 16'b1111110111010101;
        samples[217] = 16'b1111110111111000;
        samples[218] = 16'b1111111000001101;
        samples[219] = 16'b1111111000110000;
        samples[220] = 16'b1111111001010101;
        samples[221] = 16'b1111111010100011;
        samples[222] = 16'b1111111011100101;
        samples[223] = 16'b1111111101001111;
        samples[224] = 16'b1111111110111101;
        samples[225] = 16'b0000000000010001;
        samples[226] = 16'b0000000010001011;
        samples[227] = 16'b0000000011010011;
        samples[228] = 16'b0000000011010000;
        samples[229] = 16'b0000000100100111;
        samples[230] = 16'b0000000110011000;
        samples[231] = 16'b0000000111000100;
        samples[232] = 16'b0000000110011011;
        samples[233] = 16'b0000000101101001;
        samples[234] = 16'b0000000101100011;
        samples[235] = 16'b0000000101100011;
        samples[236] = 16'b0000000101101100;
        samples[237] = 16'b0000000111000111;
        samples[238] = 16'b0000000101011001;
        samples[239] = 16'b0000000100000010;
        samples[240] = 16'b0000000011100110;
        samples[241] = 16'b0000000011100011;
        samples[242] = 16'b0000000010111101;
        samples[243] = 16'b0000000011010011;
        samples[244] = 16'b0000000011000000;
        samples[245] = 16'b0000000001100010;
        samples[246] = 16'b1111111111110101;
        samples[247] = 16'b0000000000100100;
        samples[248] = 16'b0000000000010001;
        samples[249] = 16'b1111111110010111;
        samples[250] = 16'b1111111110001110;
        samples[251] = 16'b1111111110000001;
        samples[252] = 16'b1111111101001111;
        samples[253] = 16'b1111111110010100;
        samples[254] = 16'b1111111110101010;
        samples[255] = 16'b1111111101001111;
        # (500 + 500)
        en = 0;
        # (257000 - 500 - 500)

        en = 1;
        samples[0] = 16'b1111111101010011;
        samples[1] = 16'b1111111100111010;
        samples[2] = 16'b1111111011101000;
        samples[3] = 16'b1111111011101110;
        samples[4] = 16'b1111111101000000;
        samples[5] = 16'b1111111101000011;
        samples[6] = 16'b1111111101001111;
        samples[7] = 16'b1111111100101010;
        samples[8] = 16'b1111111100010111;
        samples[9] = 16'b1111111011101000;
        samples[10] = 16'b1111111010110011;
        samples[11] = 16'b1111111011111011;
        samples[12] = 16'b1111111100111101;
        samples[13] = 16'b1111111101111000;
        samples[14] = 16'b1111111111101111;
        samples[15] = 16'b0000000001000011;
        samples[16] = 16'b0000000000101101;
        samples[17] = 16'b0000000000100100;
        samples[18] = 16'b0000000010001110;
        samples[19] = 16'b0000000000111101;
        samples[20] = 16'b0000000001101111;
        samples[21] = 16'b0000000011001101;
        samples[22] = 16'b0000000010101101;
        samples[23] = 16'b0000000001011001;
        samples[24] = 16'b0000000000001011;
        samples[25] = 16'b1111111111101111;
        samples[26] = 16'b1111111101101100;
        samples[27] = 16'b1111111101010110;
        samples[28] = 16'b1111111100110000;
        samples[29] = 16'b1111111101001111;
        samples[30] = 16'b1111111110010001;
        samples[31] = 16'b1111111111000000;
        samples[32] = 16'b1111111111000110;
        samples[33] = 16'b1111111110001110;
        samples[34] = 16'b1111111111000000;
        samples[35] = 16'b1111111111001001;
        samples[36] = 16'b1111111110000101;
        samples[37] = 16'b1111111111101001;
        samples[38] = 16'b1111111111010000;
        samples[39] = 16'b1111111110111010;
        samples[40] = 16'b1111111111011100;
        samples[41] = 16'b1111111101100010;
        samples[42] = 16'b1111111101000000;
        samples[43] = 16'b1111111100110110;
        samples[44] = 16'b1111111100110000;
        samples[45] = 16'b1111111101111000;
        samples[46] = 16'b1111111111011001;
        samples[47] = 16'b1111111111010000;
        samples[48] = 16'b0000000000100111;
        samples[49] = 16'b0000000000001000;
        samples[50] = 16'b0000000001000110;
        samples[51] = 16'b0000000010001011;
        samples[52] = 16'b0000000010010100;
        samples[53] = 16'b0000000011001010;
        samples[54] = 16'b0000000010000101;
        samples[55] = 16'b0000000010001110;
        samples[56] = 16'b0000000011010000;
        samples[57] = 16'b0000000011010011;
        samples[58] = 16'b0000000010100111;
        samples[59] = 16'b0000000011000011;
        samples[60] = 16'b0000000011011001;
        samples[61] = 16'b0000000011001010;
        samples[62] = 16'b0000000011110101;
        samples[63] = 16'b0000000010100111;
        samples[64] = 16'b0000000011010000;
        samples[65] = 16'b0000000011000110;
        samples[66] = 16'b0000000010100001;
        samples[67] = 16'b0000000010110111;
        samples[68] = 16'b0000000001111011;
        samples[69] = 16'b0000000001001001;
        samples[70] = 16'b0000000000000101;
        samples[71] = 16'b1111111111001100;
        samples[72] = 16'b1111111101010110;
        samples[73] = 16'b1111111100011101;
        samples[74] = 16'b1111111000111100;
        samples[75] = 16'b1111111000000111;
        samples[76] = 16'b1111110110101001;
        samples[77] = 16'b1111110100111001;
        samples[78] = 16'b1111110100011101;
        samples[79] = 16'b1111110011011011;
        samples[80] = 16'b1111110001100100;
        samples[81] = 16'b1111110000101001;
        samples[82] = 16'b1111110000111100;
        samples[83] = 16'b1111101111110100;
        samples[84] = 16'b1111101110100110;
        samples[85] = 16'b1111101111100100;
        samples[86] = 16'b1111101111100100;
        samples[87] = 16'b1111101110110010;
        samples[88] = 16'b1111101110101111;
        samples[89] = 16'b1111101111110111;
        samples[90] = 16'b1111101111001110;
        samples[91] = 16'b1111101110110010;
        samples[92] = 16'b1111110001101011;
        samples[93] = 16'b1111110010111100;
        samples[94] = 16'b1111110101010010;
        samples[95] = 16'b1111110110111100;
        samples[96] = 16'b1111111001000011;
        samples[97] = 16'b1111111001010010;
        samples[98] = 16'b1111111011100010;
        samples[99] = 16'b1111111110111101;
        samples[100] = 16'b0000000000101010;
        samples[101] = 16'b0000000011001010;
        samples[102] = 16'b0000000100010010;
        samples[103] = 16'b0000000101111111;
        samples[104] = 16'b0000000110000101;
        samples[105] = 16'b0000000111011010;
        samples[106] = 16'b0000000111010000;
        samples[107] = 16'b0000001000011000;
        samples[108] = 16'b0000001000001111;
        samples[109] = 16'b0000001000011000;
        samples[110] = 16'b0000001000000010;
        samples[111] = 16'b0000001011000100;
        samples[112] = 16'b0000001011001101;
        samples[113] = 16'b0000001010010101;
        samples[114] = 16'b0000001100101011;
        samples[115] = 16'b0000001010001100;
        samples[116] = 16'b0000000110001111;
        samples[117] = 16'b0000000101111100;
        samples[118] = 16'b0000000111010110;
        samples[119] = 16'b0000000101001101;
        samples[120] = 16'b0000000110100100;
        samples[121] = 16'b0000000110101110;
        samples[122] = 16'b0000000010111010;
        samples[123] = 16'b0000000011101100;
        samples[124] = 16'b0000000100001011;
        samples[125] = 16'b0000000011101100;
        samples[126] = 16'b0000000101000111;
        samples[127] = 16'b0000000100010101;
        samples[128] = 16'b0000000011011111;
        samples[129] = 16'b0000000100101011;
        samples[130] = 16'b0000000100100100;
        samples[131] = 16'b0000000011011111;
        samples[132] = 16'b0000000100001011;
        samples[133] = 16'b0000000101000100;
        samples[134] = 16'b0000000100000010;
        samples[135] = 16'b0000000101100000;
        samples[136] = 16'b0000000101001010;
        samples[137] = 16'b0000000011000000;
        samples[138] = 16'b0000000011000000;
        samples[139] = 16'b0000000001010110;
        samples[140] = 16'b0000000011101001;
        samples[141] = 16'b0000000101010011;
        samples[142] = 16'b0000000101111111;
        samples[143] = 16'b0000000110111010;
        samples[144] = 16'b0000000110111101;
        samples[145] = 16'b0000000110011110;
        samples[146] = 16'b0000000110001000;
        samples[147] = 16'b0000000101010110;
        samples[148] = 16'b0000000101010011;
        samples[149] = 16'b0000000110011011;
        samples[150] = 16'b0000000011101100;
        samples[151] = 16'b0000000010101010;
        samples[152] = 16'b0000000000110000;
        samples[153] = 16'b1111111111111110;
        samples[154] = 16'b1111111101111110;
        samples[155] = 16'b1111111111000011;
        samples[156] = 16'b1111111111101001;
        samples[157] = 16'b1111111111010011;
        samples[158] = 16'b1111111111001001;
        samples[159] = 16'b1111111111010011;
        samples[160] = 16'b1111111110001011;
        samples[161] = 16'b1111111101100010;
        samples[162] = 16'b1111111111010000;
        samples[163] = 16'b1111111111101100;
        samples[164] = 16'b1111111110100111;
        samples[165] = 16'b1111111011100101;
        samples[166] = 16'b1111111100011101;
        samples[167] = 16'b1111111100110011;
        samples[168] = 16'b1111111101011100;
        samples[169] = 16'b1111111110100001;
        samples[170] = 16'b0000000000000010;
        samples[171] = 16'b1111111110011010;
        samples[172] = 16'b1111111110000101;
        samples[173] = 16'b1111111110001000;
        samples[174] = 16'b1111111111010110;
        samples[175] = 16'b1111111111011100;
        samples[176] = 16'b0000000000110000;
        samples[177] = 16'b0000000010001011;
        samples[178] = 16'b1111111111101111;
        samples[179] = 16'b0000000000000010;
        samples[180] = 16'b0000000000101010;
        samples[181] = 16'b0000000001010011;
        samples[182] = 16'b0000000001111011;
        samples[183] = 16'b0000000010001011;
        samples[184] = 16'b0000000001011001;
        samples[185] = 16'b0000000001010000;
        samples[186] = 16'b1111111111010011;
        samples[187] = 16'b0000000001111011;
        samples[188] = 16'b0000000001110101;
        samples[189] = 16'b0000000011010011;
        samples[190] = 16'b0000000011101111;
        samples[191] = 16'b0000000101001101;
        samples[192] = 16'b0000000110111101;
        samples[193] = 16'b0000000101000100;
        samples[194] = 16'b0000000101110110;
        samples[195] = 16'b0000000100001011;
        samples[196] = 16'b0000000100010010;
        samples[197] = 16'b0000000110000101;
        samples[198] = 16'b0000000100100111;
        samples[199] = 16'b0000000100001000;
        samples[200] = 16'b0000000011101001;
        samples[201] = 16'b0000000011100110;
        samples[202] = 16'b0000000001011001;
        samples[203] = 16'b0000000010100111;
        samples[204] = 16'b0000000100001110;
        samples[205] = 16'b0000000010110001;
        samples[206] = 16'b0000000011111111;
        samples[207] = 16'b0000000111001010;
        samples[208] = 16'b0000000100000010;
        samples[209] = 16'b0000000100000010;
        samples[210] = 16'b0000000100110001;
        samples[211] = 16'b0000000011110010;
        samples[212] = 16'b0000000011110010;
        samples[213] = 16'b0000000111100011;
        samples[214] = 16'b0000001001010000;
        samples[215] = 16'b0000001001110000;
        samples[216] = 16'b0000001011010000;
        samples[217] = 16'b0000001100000110;
        samples[218] = 16'b0000001011011101;
        samples[219] = 16'b0000001011111001;
        samples[220] = 16'b0000001101110110;
        samples[221] = 16'b0000001110110010;
        samples[222] = 16'b0000001101100111;
        samples[223] = 16'b0000001110110010;
        samples[224] = 16'b0000001101010100;
        samples[225] = 16'b0000001011100011;
        samples[226] = 16'b0000001101111100;
        samples[227] = 16'b0000001101101101;
        samples[228] = 16'b0000001100010010;
        samples[229] = 16'b0000001100111011;
        samples[230] = 16'b0000001100101011;
        samples[231] = 16'b0000001100101011;
        samples[232] = 16'b0000001011111100;
        samples[233] = 16'b0000001011110000;
        samples[234] = 16'b0000001011101001;
        samples[235] = 16'b0000001001101100;
        samples[236] = 16'b0000001011111001;
        samples[237] = 16'b0000001010100010;
        samples[238] = 16'b0000001000110001;
        samples[239] = 16'b0000001000000010;
        samples[240] = 16'b0000000110100001;
        samples[241] = 16'b0000000101111111;
        samples[242] = 16'b0000000101110010;
        samples[243] = 16'b0000000110111010;
        samples[244] = 16'b0000000110100001;
        samples[245] = 16'b0000000101011001;
        samples[246] = 16'b0000000100100111;
        samples[247] = 16'b0000000101101001;
        samples[248] = 16'b0000000110110111;
        samples[249] = 16'b0000000110011000;
        samples[250] = 16'b0000000111001010;
        samples[251] = 16'b0000000110100100;
        samples[252] = 16'b0000000110001000;
        samples[253] = 16'b0000001000011000;
        samples[254] = 16'b0000001001111111;
        samples[255] = 16'b0000001011110110;
        # (500 + 500)
        en = 0;
        # (257000 - 500 - 500)
        $finish;
    end
endmodule