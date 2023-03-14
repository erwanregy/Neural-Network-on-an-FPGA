import os

integer_width, fraction_width = 8, 8


def float_to_fixed(line: str) -> str:
    integer = int(round(float(line) * 2**fraction_width))
    if integer < 0:
        integer = (1 << (integer_width + fraction_width)) + integer
    return bin(integer)[2:].zfill(integer_width + fraction_width)


def float_to_fixed_file(file_path: str) -> None:
    with open(file_path, "r") as file:
        lines = file.readlines()
    with open(file_path, "w") as file:
        for line in lines:
            file.write(float_to_fixed(line) + "\n")


def float_to_fixed_model(model_path: str) -> None:
    for layer in os.listdir(model_path):
        layer_path = os.path.join(model_path, layer)
        for neuron in os.listdir(layer_path):
            neuron_path = os.path.join(layer_path, neuron)
            for parameter in os.listdir(neuron_path):
                parameter_path = os.path.join(neuron_path, parameter)
                float_to_fixed_file(parameter_path)


def main() -> None:
    float_to_fixed_model("models/3b1b")


if __name__ == "__main__":
    # main()
    float_to_fixed_file("weights.txt")
    float_to_fixed_file("bias.txt")
