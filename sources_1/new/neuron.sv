`timescale 1ns / 100ps

module neuron #(parameter
    INTG_WIDTH = 16,
    FRAC_WIDTH = 16,
    NUM_INPUTS = 16,
    ACTIVATION = "relu"
) (
    input logic clock, reset, input_ready,
    input logic signed [DATA_WIDTH-1:0] inputs[NUM_INPUTS],
    output logic signed [DATA_WIDTH-1:0] out,
    output logic output_ready
);

typedef struct packed {
    logic signed [INTG_WIDTH-1:0] intg;
    logic [FRAC_WIDTH-1:0] frac;
} fixed;


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

logic count, reset_accumulator, reset_multipliers;


// Multiply

logic signed [(2*DATA_WIDTH)-1:0] products[NUM_INPUTS];

always_ff @(posedge clock or posedge reset) begin : multiply
    if (reset) begin
        foreach (products[i]) begin
            products[i] <= 0;
        end
    end else if (reset_multipliers) begin
        foreach (products[i]) begin
            products[i] <= 0;
        end
    end else begin
        foreach (products[i]) begin
            products[i] <= inputs[i] * weights[i];
        end
    end
end


// Input number counter

logic [$clog2(NUM_INPUTS)-1:0] input_num;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        input_num <= 0;
    end else if (reset_accumulator) begin
        input_num <= 0;
    end else if (count) begin
        input_num <= input_num + 1;
    end else begin
        input_num <= input_num;
    end
end


// Accumulate

logic signed [($clog2(NUM_INPUTS)+2*DATA_WIDTH)-1:0] sum;

always_ff @(posedge clock or posedge reset) begin : accumulate
    if (reset || reset_accumulator) begin
        sum <= 0;
    end else begin
        sum <= sum + products[input_num];
    end
end


// Activate

always_ff @(posedge clock or posedge reset) begin : activate
    if (reset) begin
        out <= 0;
    end else begin
        out <= (sum > 0) ? sum : 0;
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
    count = 0;
    reset_accumulator = 0;
    reset_multipliers = 0;
    output_ready = 0;
    next_state = present_state;
    unique case (present_state)
        waiting: begin
            reset_accumulator = 1;
            reset_multipliers = 1;
            if (input_ready) begin
                next_state = multiplying;
            end else begin
                next_state = waiting;
            end 
        end
        multiplying: begin
            next_state = accumulating;
        end
        accumulating: begin
            count = 1;
            if (input_num == NUM_INPUTS - 1) begin
                next_state = activating;
            end else if (input_num < NUM_INPUTS) begin
                next_state = accumulating;
            end else begin
                next_state = waiting;
            end 
        end
        activating: begin
            next_state = done;
        end
        done: begin
            output_ready = 1;
            next_state = done;
        end
        default: begin
            next_state = waiting;
        end
    endcase
end

endmodule
