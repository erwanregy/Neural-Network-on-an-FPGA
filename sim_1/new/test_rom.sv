`timescale 1ns / 1ps

module test_rom;

    // ROM

    localparam int INT_WIDTH = 8;
    localparam int FRAC_WIDTH = 8;
    
    localparam type T = logic signed [INT_WIDTH-1:-FRAC_WIDTH];
    
    localparam int NUM_ELEMENTS = 4;
//    localparam string FILE_PATH = "C:/Users/erwan/OneDrive - University of Southampton/Code/SystemVerilog/Neural Network/Neural Network.srcs/models/3b1b/layer_0/neuron_0/weights.mem";
    localparam string FILE_PATH = "weights.mem";

    logic clock, reset, enable_rom;
    logic [$clog2(NUM_ELEMENTS)-1:0] element_num;
    T element;

    rom #(
        .T(T),
        .NUM_ELEMENTS(NUM_ELEMENTS),
        .FILE_PATH(FILE_PATH)
    ) rom (
        .clock(clock), .reset(reset), .enable(enable_rom),
        .address(element_num),
        .out(element)
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
        enable_rom = 1;
        for (int i = 0; i < NUM_ELEMENTS; i++) begin
            element_num = i;
            #CLOCK_PERIOD;
        end
        $finish;
    end

endmodule