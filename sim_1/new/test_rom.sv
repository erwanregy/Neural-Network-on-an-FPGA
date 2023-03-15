`timescale 1ns / 1ps

module test_rom;

    // ROM

    localparam int INT_WIDTH = 8;
    localparam int FRAC_WIDTH = 8;
    
    localparam int NUM_WEIGHTS = 784;
    localparam string WEIGHTS_FILE = "weights.mem";

    logic clock, reset;
    logic [$clog2(NUM_WEIGHTS)-1:0] weight_num;
    logic signed [INT_WIDTH-1:-FRAC_WIDTH] weight;

    rom #(
        .WIDTH(INT_WIDTH + FRAC_WIDTH),
        .DEPTH(NUM_WEIGHTS),
        .FILE(WEIGHTS_FILE)
    ) parameters (
        .clock(clock),
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