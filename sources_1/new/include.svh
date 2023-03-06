`ifndef INCLUDE_SVH
`define INCLUDE_SVH

parameter INTEGRAL_WIDTH = 16;
parameter FRACTION_WIDTH = 16;

typedef struct packed {
    logic signed [INTEGRAL_WIDTH-1:0] integral;
    logic [FRACTION_WIDTH-1:0] fraction;
} fixed_point; // signed fixed_point type

typedef enum logic [1:0] {RELU, SIGMOID, NONE} activation_type;

typedef enum logic [1:0] {INPUT, CONVOLUTIONAL, POOLING, DENSE} layer_type;

typedef struct {
    layer_type TYPE;
    int SIZE;
    activation_type ACTIVATION;
} layer_builder;

`endif