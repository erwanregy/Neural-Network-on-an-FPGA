`timescale 1ns/1ns

module neuron #(parameter
    DATA_WIDTH = 32,
    NUM_INPUTS = 16,
    ACTIVATION = RELU
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
        weights[i] = 1;
    end
end


// Bias

logic signed [DATA_WIDTH-1:0] bias;

initial begin
    bias = 0;
end


// State machine outputs

logic reset_units, enable_multiplier, enable_accumulator, enable_activator;


// Multiplier

logic signed [(2*DATA_WIDTH)-1:0] products[NUM_INPUTS];

always_ff @(posedge clock or posedge reset) begin : multiply
    if (reset) begin
        foreach (products[i]) begin
            products[i] <= 0;
        end
    end else if (reset_units) begin
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


// Input number counter

logic [$clog2(NUM_INPUTS)-1:0] input_num;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        input_num <= 0;
    end else if (reset_units) begin
        input_num <= 0;
    end else if (enable_accumulator) begin
        input_num <= input_num + 1;
    end else begin
        input_num <= input_num;
    end
end


// Accumulator

logic signed [($clog2(NUM_INPUTS)+2*DATA_WIDTH)-1:0] sum;

always_ff @(posedge clock or posedge reset) begin : accumulate
    if (reset) begin
        sum <= 0;
    end else if (reset_units) begin
        sum <= 0;
    end else if (enable_accumulator) begin
        sum <= sum + products[input_num];
    end else begin
        sum <= sum;
    end
end

// always_ff @(posedge clock or posedge reset) begin : accumulate
//     if (reset) begin
//         sum <= 0;
//     end else if (reset_units) begin
//         sum <= 0;
//     end else if (enable_accumulator) begin
//         foreach (products[i]) begin
//             sum <= sum + products[i];
//         end
//     end else begin
//         sum <= sum;
//     end
// end


// Sigmoid LUT

localparam NUM_ENTRIES = 256;
localparam RANGE = 6;

logic signed [DATA_WIDTH-1:0] sigmoid[NUM_ENTRIES];
initial begin
    foreach (sigmoid[i]) begin
        automatic real x = ((i / NUM_ENTRIES) * (2 * RANGE)) - RANGE;
        automatic real e = 2.71;
        automatic real y = 1 / (1 + e**(-x));
        sigmoid[i] = y * 255;
    end
end


// Activator

always_ff @(posedge clock or posedge reset) begin : activate
    if (reset) begin
        out <= 0;
    end else if (reset_units) begin
        out <= 0;
    end else if (enable_activator) begin
        unique case (ACTIVATION)
            RELU: begin
                if (sum == 0) begin
                    out <= 0;
                end else begin
                    out <= (sum > 0) ? sum : 0;
                end
            end SIGMOID: begin
                if (sum > RANGE) begin
                    out <= 255;
                end else if (sum < -RANGE) begin
                    out <= 0;
                end else begin
                    out <= sigmoid[sum];
                end
                // out <= sigmoid[sum];
            end default: begin
                $fatal("Invalid activation function %0s", ACTIVATION);
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
    reset_units = 0;
    enable_multiplier = 0;
    enable_accumulator = 0;
    enable_activator = 0;
    output_ready = 0;
    next_state = present_state;
    unique case (present_state)
        waiting: begin
            reset_units = 1;
            if (input_ready) begin
                next_state = multiplying;
            end else begin
                next_state = waiting;
            end 
        end multiplying: begin
            enable_multiplier = 1;
            next_state = accumulating;
        end accumulating: begin
            enable_accumulator = 1;
            if (input_num == NUM_INPUTS-1) begin
                next_state = activating;
            end else begin
                next_state = accumulating;
            end
        end activating: begin
            enable_activator = 1;
            next_state = done;
        end done: begin
            output_ready = 1;
            next_state = waiting;
        end default: begin
            next_state = waiting;
        end
    endcase
end

endmodule