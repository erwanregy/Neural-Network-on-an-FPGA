`timescale 1ns/1ns

typedef enum bit {RELU, SIGMOID} activation_type;

module neural_network #(parameter
    DATA_WIDTH = 32,
    NUM_LAYERS = 4,
    int SIZES[NUM_LAYERS] = {2, 4, 4, 2},
    bit ACTIVATIONS[NUM_LAYERS-1] = {relu, relu, sigmoid}
) (
    input logic clock, reset, inputs_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[SIZES[0]],
    output logic signed [DATA_WIDTH-1:0] outputs[SIZES[NUM_LAYERS-1]],
    output logic outputs_ready
);

wire signed [DATA_WIDTH-1:0] connections_0[SIZES[1]];
wire outputs_ready_0;

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(SIZES[0]),
   .NUM_NEURONS(SIZES[1]),
   .ACTIVATION(ACTIVATIONS[0])
) hidden_layer_0 (
   .clock(clock), .reset(reset),
   .inputs_ready(inputss_ready),
   .inputs(inputs),
   .outputs(connections_0),
   .outputs_ready(outputs_ready_0)
);

wire signed [DATA_WIDTH-1:0] connections_1[SIZES[2]];
wire outputs_ready_1;

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(SIZES[1]),
   .NUM_NEURONS(SIZES[2]),
   .ACTIVATION(ACTIVATIONS[1])
) hidden_layer_1 (
   .inputs_ready(outputs_ready_0),
   .clock(clock), .reset(reset),
   .inputs(connections_0),
   .outputs(connections_1),
   .outputs_ready(outputs_ready_1)
);

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(SIZES[2]),
   .NUM_NEURONS(SIZES[3]),
   .ACTIVATION(ACTIVATIONS[2])
) output_layer (
   .inputs_ready(outputs_ready_1),
   .clock(clock), .reset(reset),
   .inputs(connections_1),
   .outputs(outputs),
   .outputs_ready(outputs_ready)
);

endmodule