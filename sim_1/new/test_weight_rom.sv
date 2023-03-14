`timescale 1ns / 1ps

module test_weight_rom;

    // Weight ROM

    localparam int INT_WIDTH = 8;
    localparam int FRAC_WIDTH = 8;
    localparam int NUM_WEIGHTS = 10;
    localparam string FILENAME = "weights.txt";

    logic clock, reset;
    logic [$clog2(NUM_WEIGHTS)-1:0] weight_num;
    logic [INT_WIDTH-1:-FRAC_WIDTH] weight;

    weight_rom #(
        .INT_WIDTH(INT_WIDTH),
        .FRAC_WIDTH(FRAC_WIDTH),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .FILENAME(FILENAME)
    ) weight_rom (
        .clock(clock), .reset(reset),
        .address(weight_num),
        .out(weight)
    );


    // Clock generator

    localparam real CLOCK_PERIOD = 1.0;
    localparam real RESET_PERIOD = 0.1;

    clock_generator #(
        .CLOCK_PERIOD(CLOCK_PERIOD),
        .RESET_PERIOD(RESET_PERIOD)
    ) cg (.*);


    // Testbench

    initial begin
        #RESET_PERIOD;
        for (int i = 0; i < NUM_WEIGHTS; i++) begin
            weight_num = i;
            #CLOCK_PERIOD;
        end
        $finish;
    end

endmodule