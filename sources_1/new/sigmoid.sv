// end SIGMOID: begin
//     if (sum >= NUM_SIGMOID_ENTRIES/2) begin
//         out <= 1 << FRACTION_WIDTH;
//     end else if (sum < -NUM_SIGMOID_ENTRIES/2) begin
//         out <= 0;
//     end else begin
//         out <= sigmoid[sum[-1:-SUM_FRACTION_WIDTH]]];
//     end

`include "include.svh"

module sigmoid #(parameter
    int INPUT_INTEGER_WIDTH = 16,
    int INTPUT_FRACTION_WIDTH = 16,
    int OUTPUT_FRACTION_WIDTH = 8,
) (
    input logic clock, reset,
    input logic reset_output, enable,
    input logic signed [INPUT_INTEGER_WIDTH-1:INTPUT_FRACTION_WIDTH] in,
    output logic signed [-1:-OUTPUT_FRACTION_WIDTH] out
);

    localparam NUM_ENTRIES = 2 ** INTPUT_FRACTION_WIDTH;

    logic [OUTPUT_FRACTION_WIDTH-1:0] lut[NUM_ENTRIES];

    initial begin
        $readmemb("sigmoid.mem", lut);
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            out <= 0;
        end else if (reset_output) begin
            out <= 0;
        end else if (enable) begin
            if (in >= NUM_SIGMOID_ENTRIES/2) begin
                out <= 2 ** OUTPUT_FRACTION_WIDTH;
            end else if (in < -NUM_SIGMOID_ENTRIES/2) begin
                out <= 0;
            end else begin
                out <= lut[in[-1:-INPUT_FRACTION_WIDTH]];
            end
        end else begin
            out <= out;
        end
    end

endmodule
