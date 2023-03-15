`include "include.svh"

module neuron #(parameter
    int NUM_INPUTS = 16,
    activation_type ACTIVATION = RELU
) (
    input logic clock, reset,
    input logic inputs_ready,
    input logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[NUM_INPUTS],
    output logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] out,
    output logic output_ready
);
    
    // Weights
    
    localparam NUM_WEIGHTS = NUM_INPUTS;
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] weights[NUM_WEIGHTS];
    
    initial begin
        foreach (weights[i]) begin
//            weights[i][INTEGER_WIDTH-1:0] = $urandom_range(4) ? '0 : '1;
//            weights[i][-1:-FRACTION_WIDTH] = $urandom_range(2 ** (FRACTION_WIDTH - 1));
            weights[i][INTEGER_WIDTH-1:0] = 3;
            weights[i][-1:-FRACTION_WIDTH] = 0;
        end
    end
    
    
    // Bias
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] bias;
    
    initial begin
//        bias = 0;
        bias[INTEGER_WIDTH-1:0] = 3;
        bias[-1:-FRACTION_WIDTH] = 0;
    end
    
    
    // State machine outputs
    
    logic reset_units, multiply_accumulate, activate;
    
    
    // Multiply accumulation
    
    localparam INPUT_NUM_WIDTH = $clog2(NUM_INPUTS);
    
    logic [INPUT_NUM_WIDTH-1:0] input_num;
    
    always_ff @(posedge clock or posedge reset) begin: input_num_counter
        if (reset) begin
            input_num <= 0;
        end else if (reset_units) begin
            input_num <= 0;
        end else if (multiply_accumulate) begin
            input_num <= input_num + 1;
        end else begin
            input_num <= input_num;
        end
    end
    
    localparam SUM_INTEGER_WIDTH = INPUT_NUM_WIDTH + 2 * INTEGER_WIDTH;
    localparam SUM_FRACTION_WIDTH = 2 * FRACTION_WIDTH;
    
    logic signed [SUM_INTEGER_WIDTH-1:-SUM_FRACTION_WIDTH] sum;
    
    always_ff @(posedge clock or posedge reset) begin: multiply_accumulator
        if (reset) begin
            sum <= bias;
        end else if (reset_units) begin
            sum <= bias;
        end else if (multiply_accumulate) begin
            sum <= sum + inputs[input_num] * weights[input_num];
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
    
    localparam logic [SUM_FRACTION_WIDTH-1:0] NUM_SIGMOID_ENTRIES = 2 ** SUM_FRACTION_WIDTH - 1;
    
    logic signed [-1:-FRACTION_WIDTH] sigmoid[-NUM_SIGMOID_ENTRIES/2:NUM_SIGMOID_ENTRIES/2-1]; // TODO: only generate sigmoid rom if ACTIVATION is SIGMOID
    
    initial begin
        foreach (sigmoid[i]) begin
            sigmoid[i] = 2 ** (FRACTION_WIDTH - 1);
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
                    if (sum[SUM_INTEGER_WIDTH-1]) begin
                        out <= 0;
                    end else begin
                        if (sum[SUM_INTEGER_WIDTH-1]) begin
                            out <= 0;
                        end else begin 
                            if (sum[SUM_INTEGER_WIDTH-1:INTEGER_WIDTH-1]) begin
                                out <= 2 ** (INTEGER_WIDTH + FRACTION_WIDTH - 1) - 1;
                            end else begin
                                out <= sum[INTEGER_WIDTH-1:-FRACTION_WIDTH];
                            end
                        end
                    end
                end SIGMOID: begin
                    $display(sum[SUM_INTEGER_WIDTH-1:0]);
                    $display(NUM_SIGMOID_ENTRIES/2);
                    $display(-NUM_SIGMOID_ENTRIES/2);
                    if (sum[SUM_INTEGER_WIDTH-1:0] >= NUM_SIGMOID_ENTRIES/2) begin
                        out <= 2 ** FRACTION_WIDTH;
                    end else if (sum[SUM_INTEGER_WIDTH-1:0] < -NUM_SIGMOID_ENTRIES/2) begin
                        out <= 0;
                    end else begin
                        out <= sigmoid[sum[-1:-SUM_FRACTION_WIDTH]];
                    end
                end default: begin
                    $error("Invalid activation function %s", ACTIVATION.name());
                end
            endcase
        end else begin
            out <= out;
        end
    end
    
    
    // State machine
    
    enum logic [1:0] {waiting, multiply_accumulating, activating, outputting} present_state, next_state;
    
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            present_state <= waiting;
        end else begin
            present_state <= next_state;
        end
    end
    
    always_comb begin
        reset_units = 0;
        multiply_accumulate = 0;
        activate = 0;
        output_ready = 0;
        next_state = present_state;
        unique case (present_state)
            waiting: begin
                reset_units = 1;
                if (inputs_ready) begin
                    next_state = multiply_accumulating;
                end else begin
                    next_state = waiting;
                end 
            end
            multiply_accumulating: begin
                multiply_accumulate = 1;
                if (input_num < NUM_INPUTS - 1) begin
                    next_state = multiply_accumulating;
                end else if (input_num == NUM_INPUTS - 1) begin
                    next_state = activating;
                end else begin
                    next_state = waiting;
                end 
            end
            activating: begin
                activate = 1;
                next_state = outputting;
            end
            outputting: begin
                output_ready = 1;
                next_state = waiting;
            end
            default: begin
                next_state = waiting;
            end
        endcase
    end

endmodule
