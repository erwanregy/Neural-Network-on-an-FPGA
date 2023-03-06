`timescale 1ns / 1ps

`include "include.svh"

module test_dense_layer;

    // Device under test

    localparam int NUM_INPUTS = 16;
    localparam int NUM_OUTPUTS = 16;
    localparam activation_type ACTIVATION = RELU;

    logic clock, reset, inputs_ready, outputs_ready;
    fixed_point inputs[NUM_INPUTS], outputs[NUM_OUTPUTS];

    dense_layer #(
        .NUM_INPUTS(NUM_INPUTS),
        .NUM_NEURONS(NUM_OUTPUTS),
        .ACTIVATION(ACTIVATION)
    ) dl (.*);


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

        $display("Inputs:");
        foreach (inputs[i]) begin
            inputs[i].integral = 0;
            inputs[i].fraction = $urandom_range(1 << FRACTION_WIDTH);
            $display("%b.%b", inputs[i].integral, inputs[i].fraction);
        end
        input_ready = 1;

        forever begin
            #CLOCK_PERIOD
            if (outputs_ready) begin
                $display("Outputs:");
                foreach (outputs[i]) begin
                    $display("%b.%b", outputs[i].integral, outputs[i].fraction);
                end
                $stop;
            end
        end
    end

endmodule
