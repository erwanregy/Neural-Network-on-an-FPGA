`timescale 1ns / 1ps

`include "include.svh"

module lenet_5 #(parameter
    string IMAGES_FILE = "seven.mem",
    int NUM_IMAGES = 1,
    int PIXEL_WIDTH = 9,
    int NUM_PIXELS = 784,
    int NUM_LAYERS = 4,
    layer_builder LAYERS[4] = '{
        '{INPUT, NUM_PIXELS, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, SIGMOID}
    }
) (
    input logic clock, reset, enable,
    output logic [$clog2(LAYERS[NUM_LAYERS-1].SIZE)-1:0] label,
    output logic [$clog2(NUM_IMAGES)-1:0] label_num,
    output logic label_ready
);

    // State machine outputs
    
    logic reset_units, inputs_ready, classify;


    // Images ROM
    
    localparam int IMAGE_WIDTH = PIXEL_WIDTH * NUM_PIXELS;
    
    logic [$clog2(NUM_IMAGES)-1:0] image_num;
    logic [0:NUM_PIXELS-1][PIXEL_WIDTH-1:0] image;

    rom #(
        .WIDTH(IMAGE_WIDTH),
        .DEPTH(NUM_IMAGES),
        .FILE(IMAGES_FILE)
    ) images (
        .clock(clock),
        .address(image_num),
        .out(image)
    );
    
    
    // Image number counter
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            image_num <= 0;
        end else if (reset_units) begin
            image_num <= 0;
        end else if (classify) begin
            image_num <= image_num + 1;
        end else begin
            image_num <= image_num;
        end
    end
    
    assign label_num = image_num - 1;
    
    
    // Neural Network
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[LAYERS[0].SIZE];
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] outputs[LAYERS[NUM_LAYERS-1].SIZE];
    logic outputs_ready;
    
    always_comb begin
        foreach (inputs[i]) begin
            inputs[i] = image[i];
        end
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
                if (image_num < NUM_IMAGES) begin
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
