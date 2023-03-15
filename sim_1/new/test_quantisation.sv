`include "include.svh"

module test_quantisation;

    localparam NUM_INPUTS = 16;

    localparam INTEGER_WIDTH = 4;
    localparam FRACTION_WIDTH = 4;

    localparam SUM_INTEGER_WIDTH = INTEGER_WIDTH * 2 + $clog2(NUM_INPUTS);
    localparam SUM_FRACTION_WIDTH = FRACTION_WIDTH * 2;
    
    logic signed [SUM_INTEGER_WIDTH-1:-SUM_FRACTION_WIDTH] sum;
    
    logic signed [INTEGER_WIDTH-1:-FRACTION_WIDTH] out;
    
    always_comb begin
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
    
    initial begin
        for (int i = 0; i < 2 ** (SUM_INTEGER_WIDTH + SUM_FRACTION_WIDTH); i++) begin
            sum = i;
            #1;
        end
        $stop;
    end

endmodule
