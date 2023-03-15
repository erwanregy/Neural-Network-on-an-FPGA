`timescale 1ns / 1ps

`include "include.svh"

module dense_layer #(parameter
    int NUM_INPUTS = 16,
    int NUM_NEURONS = 16,
    activation_type ACTIVATION = RELU
) (
    input logic clock, reset,
    input logic inputs_ready,
    input logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[NUM_INPUTS],
    output logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] outputs[NUM_NEURONS],
    output logic outputs_ready
);

    logic [NUM_NEURONS-1:0] output_readys;
    
    generate
        for (genvar i = 0; i < NUM_NEURONS; i++) begin
            neuron #(
                .NUM_INPUTS(NUM_INPUTS),
                .ACTIVATION(ACTIVATION)
            ) neuron (
                .clock(clock), .reset(reset),
                .inputs_ready(inputs_ready),
                .inputs(inputs),
                .out(outputs[i]),
                .output_ready(output_readys[i])
            );
        end
    endgenerate
    
    assign outputs_ready = (output_readys == (2 ** NUM_NEURONS) - 1) ? 1 : 0;

endmodule