module neuron #(parameter
    DATA_WIDTH = 32,
    NUM_INPUTS = 16,
    ACTIVATION = "relu"
) (
    input logic clock, reset, input_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] out,
    output logic output_ready
);

// Weights

logic signed [DATA_WIDTH-1:0] weights[NUM_INPUTS];

initial begin
    foreach (weights[i]) begin
        weights[i] = i;
    end
end


// Bias

logic signed [DATA_WIDTH-1:0] bias;

initial begin
    bias = 0;
end


// State machine outputs

logic reset_outputs, enable_multiplier, enable_accumulator, enable_activator;


// Multiply

logic signed [(2*DATA_WIDTH)-1:0] products[NUM_INPUTS];

always_ff @(posedge clock or posedge reset) begin : multiply
    if (reset || reset_outputs) begin
        foreach (products[i]) begin
            products[i] <= 0;
        end
    end else if (enable_multiplier) begin
        foreach (products[i]) begin
            products[i] <= inputs[i] * weights[i];
        end
    end else begin
        foreach (products[i]) begin
            products[i] <= products[i];
        end
    end
end


// Accumulate

logic signed [($clog2(NUM_INPUTS)+2*DATA_WIDTH)-1:0] sum;

always_ff @(posedge clock or posedge reset) begin : accumulate
    if (reset || reset_outputs) begin
        sum <= 0;
    end else if (enable_accumulator) begin
        foreach (products[i]) begin
            sum <= sum + products[i];
        end
    end else begin
        sum <= sum;
    end
end


// Activate

if (ACTIVATION == "sigmoid") begin
    // Generate LUT
    // logic [] sigmoid_rom [];
end

always_ff @(posedge clock or posedge reset) begin : activate
    if (reset || reset_outputs) begin
        out <= 0;
    end else if (enable_activator) begin
        unique case (ACTIVATION)
            "relu": begin
                out <= (sum > 0) ? sum : 0;
            end
            "sigmoid": begin
                out <= (sum > 0) ? sum : 0;
                // out <= sigmoid_rom[sum];
            end
            default: begin
                $error("Invalid activation function");
                out <= sum;
            end
        endcase
    end else begin
        out <= out;
    end
end


// State machine

enum logic [2:0] {waiting, multiplying, accumulating, activating, done} present_state, next_state;

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        present_state <= waiting;
    end else begin
        present_state <= next_state;
    end
end

always_comb begin
    reset_outputs = 0;
    enable_multiplier = 0;
    enable_accumulator = 0;
    enable_activator = 0;
    output_ready = 0;
    next_state = present_state;
    unique case (present_state)
        waiting: begin
            reset_outputs = 1;
            if (input_ready) begin
                next_state = multiplying;
            end else begin
                next_state = waiting;
            end 
        end
        multiplying: begin
            enable_multiplier = 1;
            next_state = accumulating;
        end
        accumulating: begin
            enable_accumulator = 1;
            next_state = activating;
        end
        activating: begin
            enable_activator = 1;
            next_state = done;
        end
        done: begin
            output_ready = 1;
            next_state = waiting;
        end
        default: begin
            next_state = waiting;
        end
    endcase
end

endmodule
