`include "include.svh"

module test_image_rom;

    // Image ROM

    localparam int PIXEL_WIDTH = 9;
    localparam int NUM_PIXELS = 784;
    localparam int IMAGE_WIDTH = PIXEL_WIDTH * NUM_PIXELS;
    
    localparam int NUM_IMAGES = 100;
    localparam string IMAGE_FILE = "images.mem";

    logic clock, reset;
    logic [$clog2(NUM_IMAGES)-1:0] image_num;
    logic [0:NUM_PIXELS-1][PIXEL_WIDTH-1:0] image;

    rom #(
        .WIDTH(IMAGE_WIDTH),
        .DEPTH(NUM_IMAGES),
        .FILE(IMAGE_FILE)
    ) images (
        .clock(clock),
        .address(image_num),
        .out(image)
    );


    // Clock generator

    clock_generator cg (.*);


    // Testbench

    initial begin
        #RESET_PERIOD;
        for (int i = 0; i < NUM_IMAGES; i++) begin
            image_num = i;
            #CLOCK_PERIOD;
        end
        $finish;
    end

endmodule