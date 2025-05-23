`timescale 1ns / 1ps
module bundler_cont_tie (
    clk,
    nrst,
    en,
    finish,
    hv_in,
    hv_out
);

    parameter DIMENSIONS = 10000;
    parameter COUNT_SIZE = 8;
    parameter NUM_REGS = 32;
    parameter SEED = 32'hee84d6f0;
    parameter START = 10000'h6bf8ced21b601d3cdfb54cea624cc5629581f90edcc6344f864995f5cf438247923daa6d485d25c9f3b71a76292fd984018db541048dd4ebf14ad368dba08248dd650669eb0dff047f56da81c8824c7c90415eea6167bb72f58fcb41d5727bca639ac3ec08bd6d55c388fb3cbe82fbc14421edfd19db1d0f784c1b635afd5a3a2af6deafc4337354201731d6bbcec41c1540eeea8b7346d6726349fd30bfe0a45861b0b33fbe15f139436bbb668fcaeb56276c7795a88effae81c9e1f24459364331620bd5e23bffa4288ab36adb227c499fe86ced45510952e3739922d11aaf67860100bc6957f478395482852961a6330cfed476a907402ba5b51d03c49b64d936145702830be7382002fc99b7420823b37cfb506067a5a5099c07bb5e27b60250a47139ba406b7e27440cd0df622078ac064f811183aa47f54a2a3bc70d37e370e89a9e501e6ae7d3b948298ce1e5cd1ba3e04fa77aa765de832f2e76b40af7c87c88d516adb70136a5e2efd72455d8b603b938de62a4ce48b777aaa9b22b372c5bf1f883e4fc5101add95a93395aa9ed41574c9832dc45edc762ed16b7364d839b8ef374e1042e438cb72436b570ef7c8c8e2a3f456e38adbc30a88e2c19a5e82752f7fc4269c9015a7bdae729f35145c03c9493c1e31413a4055dc88e6a7810d7c98957debfffe507f28627fe9724a36f541eb957c9de4ad47c0bc4aa109b0b8da67ba45a504e99ea8d1698c83e468240d82d0657e16b70ccee7b98611d5264505f6b1597ca4d205ecc2af02b16fbc8183fe3fe6a86cfb7f232a56712024c41e8ae1057aae6783cc6d37a32081fb0def3c550ccad88ff3e201713605fb93bf68572beadcb3eb159818979e784127677942ca3d4791ac6f76445875ef3575f6fdc1d0ab9fcc53bdcae9c8186f7243732935bc166348b49cc18d32c46b56ce79d0b50401a94f6e48f5ad9b86cb09d50231184a6999ed8a1cf74f6c2b7ae5592dc0b31f417a6fafd8c0dbd4516b51fa8dd398b7b14593cd1fc97bf257012f9635505762b44e3a81f8adfebd9f4fc1db5147a55a93e35eef953ec8788a7e27b890cf2a385b63de857c23fb1cab9b8d978f8fab649c231de4d08f07d48315373f2da5708dbd17e1427e9dac577a80eb1c2d961ba99f0fcf170d2f97d53fcc93ae5479997d3d2934d4fede729c52a194213d8de1a98db0bdc20739e89fb3d8038c24a8f333d964e0a7fc80ebf57227a90b09278c1f2b4d6a141e9d7071931814a770b50e942b8b418374cec3aa4f2d124c7f08f7a82476566b41cd182471060db5a3473390f191786e9e450f1b385c22f5c4a76bc089ff2c61f540f7be4f1ecbc7be7d72016fda828fea786576d13d887ca82b0930342d6c8da523f34cfced2a07b56494649b4cae6e42d09139ed1052cec899f844a5e20cff218fb07520127e31139a514d263cfe352446efdde03a18a2f1f49b5b23c2e2fbde62f485accc7485b795efdd45e315563a82f79975b5f5066a0150ab38d148b4d5f704ddb64ec42f80798404db3f4256e257ffc88e149805bbb01d54a8a4bd32850f8065bdd9a22ca137b6cbb5c591f7091a56495fffe954d2514dac6a6ed527b68c6d716916f12b350e3f30b9913dd49bdc178534a231dde1cdc6ed4ce79ec09f99a884489c56a138863b8a0b2971fd9479bb5bba09661ef956679a42a7ba08f090ef6ac78579e6975567bcb18ac49e6c0da286dfbf28ccedf6bbfce6ae3d235af1ba4bc25c305482a;
    parameter [$clog2(NUM_REGS) - 1: 0] TAPS [3: 0] = {0, 2, 6, 7};

    input clk;
    input nrst;
    input en;
    input finish;
    input [DIMENSIONS - 1:0] hv_in;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [DIMENSIONS - 1:0][COUNT_SIZE : 0] counters_hv;
    reg [COUNT_SIZE : 0] counter;
    
    wire [DIMENSIONS - 1:0] out_ties;

    lfsr #(
    .NUM_REGS(NUM_REGS),
    .SEED(SEED),
    .START(START),
    .TAPS(TAPS)
    ) 
    u_lfsr (
        .clk  (clk),
        .nrst (nrst),
        .en   (finish),
        .out_ties  (out_ties)
    );

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            hv_out <= 0;
            counters_hv <= 0;
            counter <= 0;
        end
        else begin
            if (finish) begin
                for (int i = 0; i < DIMENSIONS; i = i + 1) begin
                    if (counter[0] == 1) begin
                        if (counters_hv[i] > counter/2) begin
                            hv_out[i] <= 1;
                        end
                        else begin
                            hv_out[i] <= 0;
                        end
                    end
                    else begin
                        if (counters_hv[i] > counter/2)
                            hv_out[i] <= 1;
                        else if (counters_hv[i] == counter/2)
                            hv_out[i] <= out_ties[i];
                        else
                            hv_out[i] <= 0;
                    end

                    
                end
                counters_hv <= 0;
                counter <= 0;
            end
            else if (en) begin
                for (int i = 0; i < DIMENSIONS; i = i + 1) begin
                    counters_hv[i] <= counters_hv[i] + hv_in[i];
                end
                counter <= counter + 1;
            end
        end
    end
endmodule