`timescale 1ns / 1ps

module rom #(parameter
    int WIDTH = 16,
    int DEPTH = 10,
    string FILE = "file.mem"
) (
    input logic clock,
    input logic [$clog2(DEPTH)-1:0] address,
    output logic [WIDTH-1:0] out
);

    logic [WIDTH-1:0] elements[DEPTH];

    initial begin
        $readmemb(FILE, elements);
    end

    always_ff @(posedge clock) begin
        out <= elements[address];
    end

endmodule
