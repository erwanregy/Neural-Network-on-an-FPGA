import os


def main():
    model = "models/3b1b"
    integer_width, fraction_width = 8, 8
    for layer in os.listdir(model):
        layer_path = os.path.join(model, layer)
        for neuron in os.listdir(layer_path):
            neuron_path = os.path.join(layer_path, neuron)
            for parameter in os.listdir(neuron_path):
                parameter_path = os.path.join(neuron_path, parameter)
                with open(parameter_path, "r") as file:
                    lines = file.readlines()
                with open(parameter_path, "w") as file:
                    for line in lines:
                        if "." not in line:
                            continue
                        integer = int(round(float(line) * 2**fraction_width))
                        if integer < 0:
                            integer = (1 << (integer_width + fraction_width)) + integer
                        fixed = bin(integer)[2:].zfill(integer_width + fraction_width)
                        file.write(fixed + "\n")


if __name__ == "__main__":
    main()
