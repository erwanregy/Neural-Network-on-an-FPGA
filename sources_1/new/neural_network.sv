`timescale 1ns / 1ps

`include "include.svh"

module neural_network #(parameter
    int NUM_LAYERS = 4,
    layer_builder LAYERS[NUM_LAYERS] = '{
        '{INPUT, 10, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, SIGMOID}
    }
) (
    input logic clock, reset, inputs_ready,
    input fixed_point inputs[LAYERS[0].SIZE],
    output fixed_point outputs[LAYERS[NUM_LAYERS-1].SIZE],
    output logic outputs_ready
);
    
    fixed_point layer_1_inputs[LAYERS[0].SIZE];
    logic layer_1_inputs_ready;
    
    assign layer_1_inputs = inputs;
    assign layer_1_inputs_ready = inputs_ready;

    fixed_point layer_1_outputs[LAYERS[1].SIZE];
    logic layer_1_outputs_ready;
    
    dense_layer #(
       .NUM_INPUTS(LAYERS[0].SIZE),
       .NUM_NEURONS(LAYERS[1].SIZE),
       .ACTIVATION(LAYERS[1].ACTIVATION)
    ) layer_1 (
       .clock(clock), .reset(reset),
       .inputs_ready(layer_1_inputs_ready),
       .inputs(layer_1_inputs),
       .outputs(layer_1_outputs),
       .outputs_ready(layer_1_outputs_ready)
    );
    
    fixed_point layer_2_inputs[LAYERS[1].SIZE];
    logic layer_2_inputs_ready;
    
    assign layer_2_inputs = layer_1_outputs;
    assign layer_2_inputs_ready = layer_1_outputs_ready;
    
    fixed_point layer_2_outputs[LAYERS[2].SIZE];
    logic layer_2_outputs_ready;
    
    dense_layer #(
       .NUM_INPUTS(LAYERS[1].SIZE),
       .NUM_NEURONS(LAYERS[2].SIZE),
       .ACTIVATION(LAYERS[2].ACTIVATION)
    ) layer_2 (
       .clock(clock), .reset(reset),
       .inputs_ready(layer_2_inputs_ready),
       .inputs(layer_2_inputs),
       .outputs(layer_2_outputs),
       .outputs_ready(layer_2_outputs_ready)
    );
    
    fixed_point layer_3_inputs[LAYERS[2].SIZE];
    logic layer_3_inputs_ready;
    
    assign layer_3_inputs = layer_2_outputs;
    assign layer_3_inputs_ready = layer_2_outputs_ready;
    
    fixed_point layer_3_outputs[LAYERS[3].SIZE];
    logic layer_3_outputs_ready;
    
    dense_layer #(
       .NUM_INPUTS(LAYERS[2].SIZE),
       .NUM_NEURONS(LAYERS[3].SIZE),
       .ACTIVATION(LAYERS[3].ACTIVATION)
    ) layer_3 (
       .clock(clock), .reset(reset),
       .inputs_ready(layer_3_inputs_ready),
       .inputs(layer_3_inputs),
       .outputs(layer_3_outputs),
       .outputs_ready(layer_3_outputs_ready)
    );
    
    assign outputs = layer_3_outputs;
    assign outputs_ready = layer_3_outputs_ready;


    // State machine

    localparam STATE_WIDTH = $clog2(1 + NUM_LAYERS + 1);

    enum logic [STATE_WIDTH-1:0] {idle, layer_1_processing, layer_2_processing, layer_3_processing, done} present_state, next_state;
    
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            present_state <= idle;
        end else begin
            present_state <= next_state;
        end
    end

    always_comb begin
        next_state = present_state;
        unique case (present_state)
            idle: begin
                if (inputs_ready) begin
                    next_state = layer_1_processing;
                end else begin
                    next_state = idle;
                end
            end layer_1_processing: begin
                if (layer_1_outputs_ready) begin
                    next_state = layer_2_processing;
                end else begin
                    next_state = layer_1_processing;
                end
            end layer_2_processing: begin
                if (layer_2_outputs_ready) begin
                    next_state = layer_3_processing;
                end else begin
                    next_state = layer_2_processing;
                end
            end layer_3_processing: begin
                if (layer_3_outputs_ready) begin
                    next_state = idle;
                end else begin
                    next_state = layer_3_processing;
                end
            end default: begin
                next_state = idle;
            end
        endcase
    end

endmodule