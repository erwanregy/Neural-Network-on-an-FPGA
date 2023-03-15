`timescale 1ns / 1ps

module test_lenet_5;

    // Lenet 5
    
    localparam int NUM_IMAGES = 10_000;
    localparam int PIXEL_WIDTH = 9;
    localparam int NUM_PIXELS = 784;
    
    logic clock, reset, enable;

    lenet_5 #(
        .NUM_IMAGES(NUM_IMAGES),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .NUM_PIXELS(NUM_PIXELS)
    ) lenet_5 (
        .*
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
        #RESET_PERIOD
        
        enable = 1;
        forever begin
            #CLOCK_PERIOD
            if (output_ready) begin
                $stop;
            end
        end
    end

endmodule
