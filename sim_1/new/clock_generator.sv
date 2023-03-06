`timescale 1ns / 1ps

module clock_generator #(parameter
    real CLOCK_PERIOD = 10,
    real RESET_PERIOD = 10
) (
    output logic clock, reset
);

    localparam CLOCK_WIDTH = CLOCK_PERIOD / 2;
    localparam RESET_WIDTH = RESET_PERIOD / 2;

    initial begin
        clock = 0;

        reset = 0;
        #RESET_WIDTH
        reset = 1;
        #RESET_WIDTH
        reset = 0;

        forever begin
            clock = ~clock;
            #CLOCK_WIDTH;
        end
    end

endmodule