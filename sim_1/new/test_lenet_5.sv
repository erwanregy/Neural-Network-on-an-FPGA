`include "include.svh"

module test_lenet_5;

    // Lenet 5
    
    localparam string IMAGES_FILE = "seven.mem";
    localparam int NUM_IMAGES = 1;
    localparam int PIXEL_WIDTH = 9;
    localparam int NUM_PIXELS = 784;
    localparam int NUM_LAYERS = 4;
    localparam layer_builder LAYERS[4] = '{
        '{INPUT, NUM_PIXELS, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, SIGMOID}
    };
    
    logic clock, reset, enable;
    logic [$clog2(LAYERS[NUM_LAYERS-1].SIZE)-1:0] label;
    logic [$clog2(NUM_IMAGES)-1:0] label_num;
    logic label_ready;

    lenet_5 #(
        .IMAGES_FILE(IMAGES_FILE),
        .NUM_IMAGES(NUM_IMAGES),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .NUM_PIXELS(NUM_PIXELS),
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) lenet_5 (.*);
    
    
    // Clock generator

    clock_generator cg (.*);
    
    
    // Testbench
    
    initial begin
        #RESET_PERIOD
        enable = 1;
        forever begin
            #CLOCK_PERIOD
            if (label_ready) begin
//                if (label_num == NUM_IMAGES - 1) begin
//                    $finish;
//                end else begin
                    $stop;
//                end
            end
        end
    end

endmodule
