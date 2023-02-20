`timescale 1ns / 100ps

module test_neural_network;

localparam INT_WIDTH = 16, FRAC_WIDTH = 16;
localparam NUM_LAYERS = 3;
localparam NUM_INPUTS = 10;
localparam LAYER LAYERS[NUM_LAYERS] = '{
    '{16, RELU},
    '{16, RELU},
    '{10, RELU}
};

function real fixed_to_real(fixed #(INT_WIDTH, FRAC_WIDTH) f);
    automatic real r = 0.0;
    for (int i = 0; i < INT_WIDTH; i++) begin
        r += f.integral[INT_WIDTH-1-i] * (1 << (INT_WIDTH-1-i));
    end
    for (int i = 0; i < FRAC_WIDTH; i++) begin
        r += f.fraction[FRAC_WIDTH-1-i] * (1.0 / (1 << (i+1)));
    end
    return r;
endfunction

logic clock, reset, inputs_ready, outputs_ready;
fixed #(INT_WIDTH, FRAC_WIDTH) inputs[NUM_INPUTS], outputs[LAYERS[NUM_LAYERS-1].NUM_NEURONS];

neural_network #(INT_WIDTH, FRAC_WIDTH, NUM_LAYERS, NUM_INPUTS, LAYERS) nn (.*);

initial begin
    clock = 0;
    reset = 0;
    #0.5
    reset = 1;
    #0.5
    reset = 0;
    forever begin
        clock = ~clock;
        #0.5;
    end
end

initial begin
    #1
    $display("Inputs:");
    foreach (inputs[i]) begin
        inputs[i].integral = 1;
        inputs[i].fraction = 0;
        $display("%b.%b = %f", inputs[i].integral, inputs[i].fraction, fixed_to_real(inputs[i]));
    end
    inputs_ready = 1;
    #1
    inputs_ready = 0;
    forever begin
        #1
        if (outputs_ready) begin
            $display("Outputs:");
            foreach (outputs[i]) begin
                $display("%b.%b = %f", outputs[i].integral, outputs[i].fraction, fixed_to_real(outputs[i]));
            end
            $stop;
        end
    end
end

endmodule
