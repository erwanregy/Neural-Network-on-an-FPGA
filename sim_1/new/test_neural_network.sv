`include "include.svh"

module test_neural_network;
    
    // Neural network

    localparam int NUM_LAYERS = 4;
    localparam layer_builder LAYERS[NUM_LAYERS] = '{
        '{INPUT, 120, NONE},
        '{DENSE, 84, RELU},
        '{DENSE, 10, SIGMOID}
    };
    
    logic clock, reset, inputs_ready, outputs_ready;
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[LAYERS[0].SIZE], outputs[LAYERS[NUM_LAYERS-1].SIZE];
    
    neural_network #(
        .NUM_LAYERS(NUM_LAYERS),
        .LAYERS(LAYERS)
    ) nn (.*);


    // Clock generator

    clock_generator cg (.*);


    // Stimulus
    
    initial begin
        #RESET_PERIOD

        $display("Inputs:");
        foreach (inputs[i]) begin
            inputs[i] = $urandom_range(2 ** FRACTION_WIDTH);
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
