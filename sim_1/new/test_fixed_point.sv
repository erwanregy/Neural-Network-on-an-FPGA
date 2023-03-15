`include "include.svh"

module test_fixed_point;

    logic [INTEGER_WIDTH-1:-FRACTION_WIDTH] a;
    logic [INTEGER_WIDTH:-FRACTION_WIDTH] sum;
    logic [2*INTEGER_WIDTH-1:-2*FRACTION_WIDTH] product;

    initial begin
//        a = 65535.9999847412109375;
        a[INTEGER_WIDTH-1:0] = 2 ** (INTEGER_WIDTH) - 1;
        a[-1:-FRACTION_WIDTH] = '1;
        sum = a + a;
        product = a * a;
        $display("a = %d", a);
        $display("sum = %d", sum);
        $display("product = %d", product);
        #1
        $stop;
    end

endmodule
