module test_layer;

logic clock, reset, input_ready, output_ready;
logic [31:0] inputs[16], outputs[16];

dense_layer dl0 (.*);

initial begin
    clock = 0;
    reset = 0;
    #1ns
    reset = 1;
    #1ns
    reset = 0;
    forever begin
        #10ns
        clock = ~clock;
    end
end

initial begin
    #10ns
    foreach (inputs[i]) begin
        inputs[i] = i;
    end
    input_ready = 1;
    #500ns
    $stop;
end

endmodule
