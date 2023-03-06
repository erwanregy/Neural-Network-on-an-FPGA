`timescale 1ns / 1ps

`include "include.svh"

module test_neural_network;
    
    // Device under test

    localparam int NUM_LAYERS = 4;
    localparam layer_builder LAYERS[NUM_LAYERS] = '{
        '{INPUT, 10, NONE},
        '{DENSE, 16, RELU},
        '{DENSE, 16, RELU},
        '{DENSE, 10, RELU}
    };
    
    logic clock, reset, inputs_ready, outputs_ready;
    fixed_point inputs[LAYERS[0].SIZE], outputs[LAYERS[NUM_LAYERS-1].SIZE];
    
    neural_network #(
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) nn (.*);


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
        inputs_ready = 1;
        
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
