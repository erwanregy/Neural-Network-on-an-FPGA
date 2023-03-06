`timescale 1ns / 1ps

`include "include.svh"

module neuron #(parameter
    int NUM_INPUTS = 16,
    activation_type ACTIVATION = RELU
) (
    input logic clock, reset, inputs_ready,
    input fixed_point inputs[NUM_INPUTS],
    output fixed_point out,
    output logic output_ready
);

    localparam DATA_WIDTH = INTEGRAL_WIDTH + FRACTION_WIDTH;
    
    
    // Weights
    
    localparam NUM_WEIGHTS = NUM_INPUTS;
    
    fixed_point weights[NUM_WEIGHTS];
    
    initial begin
        foreach (weights[i]) begin
            weights[i].integral = 0;
            weights[i].integral[INTEGRAL_WIDTH-1] = $random;
            weights[i].fraction = $urandom_range((2 ** (FRACTION_WIDTH - 1)) / 10);
        end
    end
    
    
    // Bias
    
    fixed_point bias;
    
    initial begin
        bias = 0;
    end
    
    
    // State machine outputs
    
    logic reset_units, multiply, accumulate, activate;
    
    
    // Multiplication
    
    localparam PRODUCT_WIDTH = 2 * DATA_WIDTH;
    localparam NUM_PRODUCTS = NUM_INPUTS;
    
    logic signed [PRODUCT_WIDTH-1:0] products[NUM_PRODUCTS];
    
    always_ff @(posedge clock or posedge reset) begin: multipliers
        if (reset) begin
            foreach (products[i]) begin
                products[i] <= 0;
            end
        end else if (reset_units) begin
            foreach (products[i]) begin
                products[i] <= 0;
            end
        end else if (multiply) begin
            foreach (products[i]) begin
                products[i] <= inputs[i] * weights[i];
            end
        end else begin
            foreach (products[i]) begin
                products[i] <= products[i];
            end
        end
    end
    
    
    // Accumulation
    
    localparam PRODUCT_NUM_WIDTH = $clog2(NUM_INPUTS);
    
    logic [PRODUCT_NUM_WIDTH-1:0] product_num;
    
    always_ff @(posedge clock or posedge reset) begin: product_num_counter
        if (reset) begin
            product_num <= 0;
        end else if (reset_units) begin
            product_num <= 0;
        end else if (accumulate) begin
            product_num <= product_num + 1;
        end else begin
            product_num <= product_num;
        end
    end
    
    localparam SUM_WIDTH = PRODUCT_WIDTH + PRODUCT_NUM_WIDTH;
    
    typedef struct packed {
        logic signed [SUM_WIDTH-FRACTION_WIDTH-1:0] integral;
        logic [FRACTION_WIDTH-1:0] fraction;
    } fixed_point_sum;
    
    fixed_point_sum sum;
    
    always_ff @(posedge clock or posedge reset) begin : accumulator
        if (reset) begin
            sum <= 0;
        end else if (reset_units) begin
            sum <= 0;
        end else if (accumulate) begin
            // TODO: parallelise or optimise
            sum <= sum + products[product_num];
        end else begin
            sum <= sum;
        end
    end
    
    
    // Activation
    // TODO: add sigmoid
    
    // I want to have 2**FRACTION_WIDTH - 1 number of entries in sigmoid to keep FRAC_WIDTH precision
    // values of sum greater than or less than the range specified can be rounded to 1 or 0 respectively
    // need to calculate a reasonable domain to calc sigmoid values for, (depending on frac_width precision?)
    // then precompute these values and store in sigmoid

    localparam NUM_SIGMOID_ENTRIES = 2 ** FRACTION_WIDTH - 1;
    
    logic signed [DATA_WIDTH-1:0] sigmoid[-NUM_SIGMOID_ENTRIES/2:NUM_SIGMOID_ENTRIES/2 - 1]; // TODO: only generate sigmoid rom if ACTIVATION is SIGMOID
    
    initial begin
        foreach (sigmoid[i]) begin

        end
    end
    
    always_ff @(posedge clock or posedge reset) begin : activator
        if (reset) begin
            out <= 0;
        end else if (reset_units) begin
            out <= 0;
        end else if (activate) begin
            unique case (ACTIVATION)
                RELU: begin
                    if (sum[SUM_WIDTH-1] == 0) begin
                        if (sum >= (2 ** DATA_WIDTH - 1)) begin
                            out <= 2 ** (DATA_WIDTH - 1) - 1;
                        end else begin
                            out <= sum;
                        end
                    end else begin
                        out <= 0;
                    end
                end SIGMOID: begin
                    if (sum >= NUM_SIGMOID_ENTRIES/2) begin
                        out <= 1 << FRACTION_WIDTH;
                    end else if (sum < -NUM_SIGMOID_ENTRIES/2) begin
                        out <= 0;
                    end else begin
                        out <= sigmoid[sum.fraction];
                    end
                end default: begin
                    $fatal("Invalid activation function %s", ACTIVATION.name());
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
        multiply = 0;
        accumulate = 0;
        activate = 0;
        output_ready = 0;
        next_state = present_state;
        unique case (present_state)
            waiting: begin
                reset_units = 1;
                if (inputs_ready) begin
                    next_state = multiplying;
                end else begin
                    next_state = waiting;
                end 
            end
            multiplying: begin
                multiply = 1;
                next_state = accumulating;
            end
            accumulating: begin
                accumulate = 1;
                if (product_num < NUM_PRODUCTS - 1) begin
                    next_state = accumulating;
                end else if (product_num == NUM_PRODUCTS - 1) begin
                    next_state = activating;
                end else begin
                    next_state = waiting;
                end 
            end
            activating: begin
                activate = 1;
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
