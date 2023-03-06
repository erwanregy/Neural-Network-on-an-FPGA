`timescale 1ns / 1ps

`include "include.svh"

module test_regnet;

    localparam DATA_WIDTH = 32;
    localparam INPUT_SIZE = 1;
    localparam NUM_LAYERS = 4;
    localparam layer_builder LAYERS[NUM_LAYERS] = '{
        '{INPUT, 10, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, RELU}
    };
    
    localparam NUM_PIXELS = LAYERS[0].SIZE;
    fixed_point image[NUM_PIXELS];

    logic clock, reset;
    logic image_ready;
    fixed_point pixels[INPUT_SIZE];
    logic [$clog2(LAYERS[NUM_LAYERS-1].SIZE)-1:0] label;
    logic label_ready;

    regnet #(
        .INPUT_SIZE(INPUT_SIZE),
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) regnet (.*);
    
    
    initial begin
        clock = 0;
        reset = 0;
        #0.5
        reset = 1;
        #0.5
        reset = 0;
        forever begin
            clock = ~clock;
            #0.5;
        end
    end
    
    initial begin
        #1
        foreach (image[i]) begin
            image[i].integral = i;
            image[i].fraction = 0;
        end
        #1
        image_ready = 1;
        for (int pixel_num = 0; pixel_num < NUM_PIXELS; pixel_num += INPUT_SIZE) begin
            for (int i = 0; i < INPUT_SIZE; i++) begin
                if (pixel_num + i < NUM_PIXELS) begin
                    pixels[i] = image[pixel_num + i];
                end
            end
            #1;
        end
        #1
        image_ready = 0;
        forever begin
            #1
            if (label_ready) begin
                $display("%d", label);
                $stop;
            end
        end
    end

endmodule
