`timescale 1ns/1ns

module dense_layer #(parameter
    DATA_WIDTH = 32,
    NUM_INPUTS = 16,
    NUM_NEURONS = 16,
    ACTIVATION = "relu"
) (
    input logic clock, reset, inputs_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] outputs[NUM_NEURONS],
    output logic outputs_ready
);

logic output_ready [NUM_NEURONS];

generate
    for (genvar i = 0; i < NUM_NEURONS; i++) begin
        neuron #(
            .DATA_WIDTH(DATA_WIDTH),
            .NUM_INPUTS(NUM_INPUTS),
            .ACTIVATION(ACTIVATION)
        ) neuron (
            .clock(clock), .reset(reset),
            .input_ready(input_ready),
            .inputs(inputs),
            .out(outputs[i]),
            .output_ready(output_ready[i])
        );
    end
endgenerate

always_comb begin
    output_ready = 1;
    foreach (output_ready[i]) begin
        if (output_ready[i] != 1) begin
            outputs_ready = 0;
            break;
        end
    end
end

endmodule