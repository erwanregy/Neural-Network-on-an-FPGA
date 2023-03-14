`timescale 1ns / 1ps

module rom #(parameter
    type T = logic signed [15:-16],
    int NUM_ELEMENTS = 10,
    string FILE_PATH = "rom.mem"
) (
    input logic clock, reset, enable,
    input logic [$clog2(NUM_ELEMENTS)-1:0] address,
    output T out
);

    T elements [NUM_ELEMENTS];

    initial begin
        $readmemb(FILE_PATH, elements);
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            out <= 0;
        end else if (enable) begin
            out <= elements[address];
        end else begin
            out <= out;
        end
    end

endmodule
