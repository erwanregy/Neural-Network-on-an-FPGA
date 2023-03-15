import os


def float_to_fixed(value: float, integer_width: int, fraction_width: int) -> str:
    integer = int(round(value * 2**fraction_width))
    if integer < 0:
        integer = (1 << (integer_width + fraction_width)) + integer
    return bin(integer)[2:].zfill(integer_width + fraction_width)


def float_to_fixed_file(file_path: str, integer_width: int, fraction_width: int) -> None:
    with open(file_path, "r") as file:
        lines = file.readlines()
    with open(file_path, "w") as file:
        for line in lines:
            file.write(float_to_fixed(float(line), integer_width, fraction_width) + "\n")


def float_to_fixed_model(model_path: str, integer_width: int, fraction_width: int) -> None:
    for layer in os.listdir(model_path):
        layer_path = os.path.join(model_path, layer)
        for neuron in os.listdir(layer_path):
            neuron_path = os.path.join(layer_path, neuron)
            for parameter in os.listdir(neuron_path):
                parameter_path = os.path.join(neuron_path, parameter)
                float_to_fixed_file(parameter_path, integer_width, fraction_width)


def main() -> None:
    integer_width, fraction_width = 8, 8
    float_to_fixed_model("models/3b1b", integer_width, fraction_width)


if __name__ == "__main__":
    main()
