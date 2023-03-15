`include "include.svh"

module test_accumulator;

    localparam NUM_INPUTS = 128;
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] inputs[NUM_INPUTS];
    
    initial begin
        foreach (inputs[i]) begin
            inputs[i] = 2 ** (INTEGER_WIDTH+FRACTION_WIDTH-1) - 1;
        end
    end
    
    logic signed [$clog2(NUM_INPUTS)+INTEGER_WIDTH-1:-FRACTION_WIDTH] sum;
    
    initial begin
        sum = 0;
        foreach (inputs[i]) begin
            sum += inputs[i];
        end
    end

endmodule
