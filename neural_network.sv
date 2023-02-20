`timescale 1ns/1ns

typedef struct {
    int NUM_NEURONS;
    ACTIVATION ACTIVATION;
} LAYER;

module neural_network #(parameter
    DATA_WIDTH = 32,
    NUM_LAYERS = 3,
    NUM_INPUTS = 10,
    LAYER LAYERS[NUM_LAYERS] = '{
        '{16, RELU},
        '{16, RELU},
        '{10, SIGMOID}
    }
) (
    input logic clock, reset, inputs_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] outputs[LAYERS[NUM_LAYERS-1].NUM_NEURONS],
    output logic outputs_ready
);

logic signed [DATA_WIDTH-1:0] layer_0_outputs[LAYERS[0].NUM_NEURONS];
logic layer_0_outputs_ready;

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(NUM_INPUTS),
   .NUM_NEURONS(LAYERS[0].NUM_NEURONS),
   .ACTIVATION(LAYERS[0].ACTIVATION)
) layer_0 (
   .clock(clock), .reset(reset),
   .inputs_ready(inputs_ready),
   .inputs(inputs),
   .outputs(layer_0_outputs),
   .outputs_ready(layer_0_outputs_ready)
);

logic signed [DATA_WIDTH-1:0] layer_1_outputs[LAYERS[1].NUM_NEURONS];
logic layer_1_outputs_ready;

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(LAYERS[0].NUM_NEURONS),
   .NUM_NEURONS(LAYERS[1].NUM_NEURONS),
   .ACTIVATION(LAYERS[1].ACTIVATION)
) layer_1 (
   .clock(clock), .reset(reset),
   .inputs_ready(layer_0_outputs_ready),
   .inputs(layer_0_outputs),
   .outputs(layer_1_outputs),
   .outputs_ready(layer_1_outputs_ready)
);

dense_layer #(
   .DATA_WIDTH(DATA_WIDTH),
   .NUM_INPUTS(LAYERS[1].NUM_NEURONS),
   .NUM_NEURONS(LAYERS[2].NUM_NEURONS),
   .ACTIVATION(LAYERS[2].ACTIVATION)
) output_layer (
   .clock(clock), .reset(reset),
   .inputs_ready(layer_1_outputs_ready),
   .inputs(layer_1_outputs),
   .outputs(outputs),
   .outputs_ready(outputs_ready)
);

endmodule