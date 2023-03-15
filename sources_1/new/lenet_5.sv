`timescale 1ns / 1ps

`include "include.svh"

module lenet_5 #(parameter
    int NUM_IMAGES = 10_000,
    int PIXEL_WIDTH = 9,
    int NUM_PIXELS = 784,
    int NUM_LAYERS = 4,
    layer_builder LAYERS[4] = '{
        '{INPUT, 784, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, SIGMOID}
    }
) (
    input logic clock, reset, enable,
    output logic [$clog2(LAYERS[NUM_LAYERS-1].SIZE)-1:0] label,
    output logic label_ready
);

    // State machine outputs
    
    logic reset_units, inputs_ready, classify, increment_image_num;


    // Images ROM
    
    localparam int IMAGE_WIDTH = PIXEL_WIDTH * NUM_PIXELS;
    
    logic [$clog2(NUM_IMAGES)-1:0] image_num;
    logic [IMAGE_WIDTH-1:0] image;

    rom #(
        .WITDH(IMAGE_WIDTH),
        .DEPTH(NUM_IMAGES),
        .FILE("test_images.mem")
    ) images (
        .clock(clock),
        .address(image_num),
        .data(image)
    );
    
    
    // Image number counter
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            image_num <= 0;
        end else if (reset_units) begin
            image_num <= 0;
        end else if (increment_image_num) begin
            image_num <= image_num + 1;
        end else begin
            image_num <= image_num;
        end
    end
    
    
    // Neural Network
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[LAYERS[0].SIZE];
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] outputs[LAYERS[NUM_LAYERS-1].SIZE];
    logic outputs_ready;
    
    for (genvar i = 0; i < IMAGE_WIDTH; i++) begin
        assign inputs[i] = image[i:i + PIXEL_WIDTH];
    end
    
    neural_network #(
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) neural_network (
        .clock(clock), .reset(reset),
        .inputs_ready(inputs_ready),
        .inputs(inputs),
        .outputs(outputs),
        .outputs_ready(outputs_ready)
    );
    
    
    // Classifying
    
    always_ff @(posedge clock or posedge reset) begin: labeller
        if (reset) begin
            label <= 0;
        end else if (reset_units) begin
            label <= 0;
        end else if (classify) begin
            foreach (outputs[i]) begin
                 if (outputs[i] > label) begin
                    label <= outputs[i];
                 end
            end
        end else begin
            label <= label;
        end
    end
    
    
    // State machine

    enum logic [2:0] {idle, processing, classifying, outputting} present_state, next_state;
    
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            present_state <= idle;
        end else begin
            present_state <= next_state;
        end
    end
    
    always_comb begin
        reset_units = 0;
        inputs_ready = 0;
        classify = 0;
        label_ready = 0;
        next_state = present_state;
        unique case (present_state)
            idle: begin
                reset_units = 1;
                if (enable) begin
                    next_state = processing;
                end else begin
                    next_state = idle;
                end
            end processing: begin
                inputs_ready = 1;
                if (outputs_ready) begin
                    next_state = classifying;
                end else begin
                    next_state = processing;
                end
            end classifying: begin
                classify = 1;
                next_state = outputting;
            end outputting: begin
                label_ready = 1;
                if (image_num < NUM_IMAGES - 1) begin
                    increment_image_num = 1;
                    next_state = processing;
                end else begin
                    next_state = idle;
                end
            end default: begin
                next_state = idle;
            end
        endcase
    end

endmodule
