`timescale 1ns / 1ps

`include "include.svh"

module regnet #(parameter
    int INPUT_SIZE = 1,
    int NUM_LAYERS = 4,
    layer_builder LAYERS[NUM_LAYERS] = '{
        '{INPUT, 10, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, SIGMOID}
    }
) (
    input logic clock, reset,
    input logic image_ready,
    input fixed_point pixels[INPUT_SIZE],
    output logic [$clog2(LAYERS[NUM_LAYERS-1].SIZE)-1:0] label, // enough bits to store indices of nn output
    output logic label_ready
);

    // State machine outputs
    
    logic reset_units, load_image, inputs_ready, classify;


    // Take in image data (pixels) serially and convert into parallel input buffer
    
    localparam NUM_PIXELS = LAYERS[0].SIZE;
    localparam PIXEL_NUM_WIDTH = $clog2(NUM_PIXELS);
    
    logic [PIXEL_NUM_WIDTH-1:0] pixel_num;
    
    always_ff @(posedge clock or posedge reset) begin: pixel_num_counter
        if (reset) begin
            pixel_num <= 0;
        end else if (reset_units) begin
            pixel_num <= 0;
        end else if (load_image) begin
            pixel_num <= pixel_num + INPUT_SIZE;
        end else begin
            pixel_num <= pixel_num;
        end
    end
    
    localparam NUM_INPUTS = NUM_PIXELS;
    
    fixed_point inputs[NUM_INPUTS];
    
    always_ff @(posedge clock or posedge reset) begin: inputs_buffer
        if (reset) begin
            foreach (inputs[i]) begin
                inputs[i] <= 0;
            end
        end else if (reset_units) begin
            foreach (inputs[i]) begin
                inputs[i] <= 0;
            end
        end else if (load_image) begin
            for (int i = 0; i < INPUT_SIZE; i++) begin
                // TODO: check hardware synthesised from this
                automatic int input_num = pixel_num + i;
                if (input_num < NUM_PIXELS - 1) begin
                    inputs[input_num] <= pixels[input_num];
                end
            end
        end else begin
            foreach (inputs[i]) begin
                inputs[i] <= inputs[i];
            end
        end
    end
    
    
    // Neural Network
    
    fixed_point outputs[LAYERS[NUM_LAYERS-1].SIZE];
    logic outputs_ready;
    
    neural_network #(
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) neural_network (.*);
    
    
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

    enum logic [2:0] {idle, loading_image, processing, classifying, done} present_state, next_state;
    
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            present_state <= idle;
        end else begin
            present_state <= next_state;
        end
    end
    
    always_comb begin
        reset_units = 0;
        load_image = 0;
        inputs_ready = 0;
        classify = 0;
        label_ready = 0;
        next_state = present_state;
        unique case (present_state)
            idle: begin
                reset_units = 1;
                if (image_ready) begin
                    next_state = loading_image;
                end else begin
                    next_state = idle;
                end 
            end loading_image: begin
                load_image = 1;
                if (pixel_num < NUM_PIXELS - 1) begin
                    next_state = loading_image;
                end else if (pixel_num == NUM_PIXELS - 1) begin
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
                next_state = done;
            end done: begin
                label_ready = 1;
                next_state = idle;
            end default: begin
                next_state = idle;
            end
        endcase
    end    

endmodule
