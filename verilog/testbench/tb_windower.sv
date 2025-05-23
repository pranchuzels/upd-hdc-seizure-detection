`timescale 1ns / 1ps
module tb_windower; 
    localparam T = 10;  // clock period in ms
    

    localparam NUM_CHS = 2;
    localparam WINDOW_SIZE = 4;
    localparam WINDOW_STEP = 2;
    localparam SAMPLE_SIZE = 2;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    wire done;
    wire [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] sample_memory;

    
    windower #(
        .NUM_CHS(NUM_CHS),
        .WINDOW_SIZE(WINDOW_SIZE),
        .WINDOW_STEP(WINDOW_STEP),
        .SAMPLE_SIZE(SAMPLE_SIZE)
    )
    u_windower(
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .samples(samples),
        .done(done),
        .sample_memory(sample_memory)
    );
    
    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_bundler_odd.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        samples[0] = 2'b00;
        samples[1] = 2'b00;
        # (20 - 5)
        nrst = 1;
        
        en = 1;
        samples[0] = 2'b01;
        samples[1] = 2'b01;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b10;
        samples[1] = 2'b10;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b11;
        samples[1] = 2'b11;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b00;
        samples[1] = 2'b00;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b01;
        samples[1] = 2'b01;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b10;
        samples[1] = 2'b10;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b11;
        samples[1] = 2'b11;
        # (5 + 5)
        en = 0;
        # (20 - 5 - 5)

        en = 1;
        samples[0] = 2'b00;
        samples[1] = 2'b00;
        # (5 + 5)
        en = 0;
        # (20 - 5)
        $finish;
    end
    endmodule