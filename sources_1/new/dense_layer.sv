`timescale 1ns / 100ps

typedef enum {RELU, SIGMOID} ACTIVATION;

module dense_layer #(parameter
    INTG_WIDTH = 16,
    FRAC_WIDTH = 16,
    NUM_INPUTS = 16,
    NUM_NEURONS = 16,
    ACTIVATION = RELU
) (
    input logic clock, reset, inputs_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] outputs[NUM_NEURONS],
    output logic outputs_ready
);

typedef struct packed {
    logic signed [INTG_WIDTH-1:0] intg;
    logic [FRAC_WIDTH-1:0] frac;
} fixed;

logic [NUM_NEURONS-1:0] neuron_output_ready;

generate
    for (genvar i = 0; i < NUM_NEURONS; i++) begin
        neuron #(
            .INTG_WIDTH(INTG_WIDTH),
            .FRAC_WIDTH(FRAC_WIDTH),
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