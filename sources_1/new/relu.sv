`include "include.svh"

module relu #(parameter
    int INPUT_WIDTH = 32,
    int OUTPUT_WIDTH = 16
) (
    input logic clock, reset,
    input logic reset_output, enable,
    input logic signed [INPUT_WIDTH-1:0] in,
    output logic signed [OUTPUT_WIDTH-1:0] out
);

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            out <= 0;
        end else if (reset_output) begin
            out <= 0;
        end else if (enable) begin
            if (in[INPUT_WIDTH-1]) begin
                out <= 0;
            end else begin
                if (in >= (2 ** OUTPUT_WIDTH - 1)) begin
                    out <= 2 ** (OUTPUT_WIDTH - 1) - 1;
                end else begin
                    out <= in;
                end
            end
        end else begin
            out <= out;
        end
    end

endmodule
