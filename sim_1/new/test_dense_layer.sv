`include "include.svh"

module test_dense_layer;

    // Dense layer

    localparam int NUM_INPUTS = 16;
    localparam int NUM_OUTPUTS = 16;
    localparam activation_type ACTIVATION = RELU;

    logic clock, reset, inputs_ready, outputs_ready;
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[NUM_INPUTS], outputs[NUM_OUTPUTS];

    dense_layer #(
        .NUM_INPUTS(NUM_INPUTS),
        .NUM_NEURONS(NUM_OUTPUTS),
        .ACTIVATION(ACTIVATION)
    ) dl (.*);


    // Clock generator

    clock_generator cg (.*);


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
