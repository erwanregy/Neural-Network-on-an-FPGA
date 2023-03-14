`timescale 1ns / 1ps

module weight_rom #(parameter
    int INT_WIDTH = 8,
    int FRAC_WIDTH = 8,
    int NUM_WEIGHTS = 10,
    string FILENAME = "weights.txt"
) (
    input logic clock, reset,
    input logic [$clog2(NUM_WEIGHTS)-1:0] address,
    output logic [INT_WIDTH-1:-FRAC_WIDTH] out
);

    logic [INT_WIDTH-1:-FRAC_WIDTH] weights [NUM_WEIGHTS];

    // Read weights from file
    initial begin
        $readmemb(FILENAME, weights);
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            out <= 0;
        end else begin
            out <= weights[address];
        end
    end

endmodule
