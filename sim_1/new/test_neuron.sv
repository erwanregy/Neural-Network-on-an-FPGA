`timescale 1ns / 1ps

`include "include.svh"

module test_neuron;

    // Neuron

    localparam int NUM_INPUTS = 4;

    logic clock, reset, inputs_ready, output_ready;
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[NUM_INPUTS], out;

    neuron #(
        .NUM_INPUTS(NUM_INPUTS),
        .ACTIVATION(RELU)
    ) n_relu (.*);


    // Clock generator

    localparam real CLOCK_PERIOD = 1.0;
    localparam real RESET_PERIOD = 0.1;

    clock_generator #(
        .CLOCK_PERIOD(CLOCK_PERIOD),
        .RESET_PERIOD(RESET_PERIOD)
    ) cg (.*);


    // Stimulus

    initial begin
        #RESET_PERIOD

        foreach (inputs[i]) begin
            inputs[i] = $urandom_range(2 ** FRACTION_WIDTH - 1);
        end
        inputs_ready = 1;

        forever begin
            #CLOCK_PERIOD
            if (output_ready) begin
                $stop;
            end
        end
    end

endmodule