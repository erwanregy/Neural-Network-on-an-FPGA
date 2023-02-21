# Neural Network on an FPGA

This project is focused on optimising the performance of neural networks by implementing them on an FPGA. By using an FPGA, we can achieve a high degree of parallelism, which can significantly improve the speed of neural network computations.

## Source Files

### `neuron.sv`

The `neuron` module is a hardware implementation of a neural network neuron. It takes in `NUM_INPUTS` inputs, each of `DATA_WIDTH` bits, and applies a set of weights to them. It then sums the weighted inputs and applies an activation function to produce an output. The activation function can be specified as a parameter and can be either ReLU or sigmoid.

The module has four main stages: `multiplying`, `accumulating`, `activating`, and `waiting`. In the `multiplying` stage, the inputs are multiplied by their corresponding weights. In the `accumulating` stage, the weighted inputs are accumulated. In the `activating` stage, the activation function is applied to the accumulated sum. In the `waiting` stage, the module waits for input_ready to become high, at which point it starts the next cycle.

The module uses a state machine to control the flow of data through the stages. The state machine has five states: `waiting`, `multiplying`, `accumulating`, `activating`, and `done`. The module starts in the `waiting` state and transitions to the `multiplying` state when input_ready becomes high. It then transitions to the `accumulating` state and, after `accumulating` all of the inputs, transitions to the `activating` state. Finally, it transitions to the `done` state, sets `output_ready` high, and then transitions back to the `waiting` state.

The weights for the inputs are initialized in an `initial` block in the module. The bias is also initialized in an `initial` block. The module supports signed inputs and weights, and the output is also signed. The module is designed to work with a clock with a period of 1ns and uses a timescale of 1ns/1ns.

### `dense_layer.sv`

The `dense_layer` module is a parameterized implementation of a neural network dense layer, which is designed to process a fixed number of input signals, each with a fixed data width. The module takes `clock`, `reset`, and `input_ready` signals as inputs and produces `outputs` and `output_ready` signals as outputs.

The module contains a `generate` block that instantiates a number of neuron modules equal to the specified number of neurons. Each neuron module processes the inputs using a specified activation function, and produces a single output signal. The outputs signals of the module are connected to the outputs of each of the instantiated neuron modules.

The `dense_layer` module has a combinatorial logic block that checks the `neuron_ready` signals produced by each neuron module. If any neuron module is not ready, the `output_ready` signal will be set to 0. Otherwise, the `output_ready` signal will be set to 1.

The `dense_layer` module is highly parameterized, allowing the user to configure the data width of the input and output signals, the number of input signals, the number of neurons in the layer, and the activation function used by the neurons.

### `neural_network.sv`

The `neural_network` module is a parameterized implementation of a feedforward neural network, with a fixed number of layers and a fixed number of neurons in each layer. The module takes in `clock`, `reset`, and `inputs_ready` signals as inputs, and produces outputs and `outputs_ready` signals as outputs.

The module consists of several `dense_layer` submodules, each with a specified number of input and output signals and a specified activation function. The input signals to the first `dense_layer` module are connected to the inputs signals of the `neural_network` module, while the output signals of each `dense_layer` module are connected to the input signals of the subsequent `dense_layer` module. The output signals of the final `dense_layer` module are connected to the outputs signals of the `neural_network` module.

The `neural_network` module is highly parameterized, allowing the user to configure the data width (`DATA_WIDTH`) of the input and output signals, the number of layers in the network, the number of neurons (`NUM_NEURONS`) in each layer, and the activation function used by each layer. The sizes of each layer are specified in the `SIZES` parameter, while the activation functions for each hidden layer are specified in the `ACTIVATIONS` parameter.
