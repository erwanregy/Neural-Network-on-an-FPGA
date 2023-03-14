import os


def main():
    model = "models/3b1b"
    for layer in os.listdir(model):
        layer_path = os.path.join(model, layer)
        for neuron in os.listdir(layer_path):
            neuron_path = os.path.join(layer_path, neuron)
            for parameter in os.listdir(neuron_path):
                # rename parameter.txt to parameter.mem
                parameter_path = os.path.join(neuron_path, parameter)
                os.rename(parameter_path, parameter_path[:-4] + ".mem")
    
    
if __name__ == "__main__":
    main()