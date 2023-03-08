`timescale 1ns / 1ps

module test_multiplication;

    localparam WIDTH = 4;

    logic signed [WIDTH-1:0] a;
    logic signed [WIDTH-1:0] b;
    logic signed [2*WIDTH-1:0] product;
    
    initial begin
        a = 2;
        b = -3;
        product = a * b;
        $stop;
    end

endmodule
