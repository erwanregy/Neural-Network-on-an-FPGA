`timescale 1ns/1ns

typedef enum {RELU, SIGMOID} ACTIVATION;

module dense_layer #(parameter
    DATA_WIDTH = 32,
    NUM_INPUTS = 16,
    NUM_NEURONS = 16,
    ACTIVATION = RELU
) (
    input logic clock, reset, inputs_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] outputs[NUM_NEURONS],
    output logic outputs_ready
);

logic [NUM_NEURONS-1:0] neuron_output_ready;

generate
    for (genvar i = 0; i < NUM_NEURONS; i++) begin
        neuron #(
            .DATA_WIDTH(DATA_WIDTH),
            .NUM_INPUTS(NUM_INPUTS),
            .ACTIVATION(ACTIVATION)
        ) neuron (
            .clock(clock), .reset(reset),
            .input_ready(inputs_ready),
            .inputs(inputs),
            .out(outputs[i]),
            .output_ready(neuron_output_ready[i])
        );
    end
endgenerate

assign outputs_ready = (neuron_output_ready == 2**NUM_NEURONS - 1) ? 1 : 0;

endmodule