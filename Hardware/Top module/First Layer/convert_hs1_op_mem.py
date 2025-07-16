# convert_hs1_op_mem.py
# Converts a single-line binary memory file to one value per line (hex)

input_file = "memory/hs1_op.mem"
output_file = "memory/hs1_op_fixed.mem"

with open(input_file, "r") as f:
    data = f.read().strip()

# Remove any whitespace just in case
data = ''.join(data.split())

# Each value is 16 bits
value_width = 16

with open(output_file, "w") as f:
    for i in range(0, len(data), value_width):
        chunk = data[i:i+value_width]
        if len(chunk) == value_width:
            # Convert binary to hex, pad to 4 hex digits
            hexval = f"{int(chunk, 2):04X}"
            f.write(hexval + "\n")

print(f"Done! Converted to {output_file}") 