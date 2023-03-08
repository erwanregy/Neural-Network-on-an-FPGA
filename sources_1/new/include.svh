`ifndef INCLUDE_SVH
`define INCLUDE_SVH

parameter INTEGER_WIDTH = 4;
parameter FRACTION_WIDTH = 4;

typedef enum logic [1:0] {RELU, SIGMOID, NONE} activation_type;

typedef enum logic [1:0] {INPUT, CONVOLUTIONAL, POOLING, DENSE} layer_type;

typedef struct {
    layer_type TYPE;
    int SIZE;
    activation_type ACTIVATION;
} layer_builder;

`endif