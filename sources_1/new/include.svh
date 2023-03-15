`ifndef INCLUDE_SVH

    `define INCLUDE_SVH
    
    timeunit 1ns;
    timeprecision 1ps;
    
    localparam real CLOCK_SPEED = 1.0; // GHz
    parameter real CLOCK_PERIOD = (1 / CLOCK_SPEED) / 2;
    parameter real RESET_PERIOD = 0.1;
    
    parameter INTEGER_WIDTH = 8;
    parameter FRACTION_WIDTH = 8;
    
    typedef enum logic [1:0] {RELU, SIGMOID, NONE} activation_type;
    
    typedef enum logic [1:0] {INPUT, CONVOLUTIONAL, POOLING, DENSE} layer_type;
    
    typedef struct {
        layer_type NAME;
        int SIZE;
        activation_type ACTIVATION;
    } layer_builder;

`endif