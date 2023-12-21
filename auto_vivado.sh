#!/bin/bash

# pip install pillow

image_path='C:/Users/akshi/Downloads/project_check/resources/my_test01.jpg'
filename=$(basename "$image_path")
filename=$(echo "$filename" | cut -d'.' -f1)

if [ -z "$1" ]; then
    echo "Input image path is not provided. Using default test image : $image_path"
else
    echo "Input image path : $1"
    image_path="$1"
fi

output_image_path="${image_path%.*}_output.jpg"

# Some Bash commands before Python execution
echo "Generating input file for image"

# Python code
python3 - <<END
from PIL import Image
import os

os.makedirs("./temp/",exist_ok = True)

# Load the image
image_path = '$image_path'  # Replace 'TEST_IMAGE.jpg' with the actual path to your image
img = Image.open(image_path)

# Convert the image to grayscale
img = img.convert('L')

# Resize the image to 256x256
img = img.resize((256, 256), Image.BICUBIC)

# Get image width and height
width, height = img.size

# Define a function to convert decimal to hexadecimal with padding
def to_hex(val):
    return format(val, '02X')

# Open a text file to write the hexadecimal values
with open('./temp/generated_input.txt', 'w') as file:
    # Loop through each pixel
    for y in range(height):
        for x in range(width):
            # Create a 3x3 window around the pixel
            window = img.crop((x - 1, y - 1, x + 2, y + 2)).load()
            
            # Extract pixel values from the window
            pixels = [window[i, j] for j in range(3) for i in range(3)]
            
            # Convert pixel values to hexadecimal
            hex_values = [to_hex(pixel) for pixel in pixels]
            
            # Write the hexadecimal values to the file separated by tabs
            file.write('\t'.join(hex_values) + '\t')
END

# More Bash commands after Python execution
echo "Launching Vivado Simulation"

# Launch Vivado in Tcl mode
vivado -mode tcl << EOF

# Vivado Tcl commands
open_project "C:/Users/akshi/Downloads/project_check/project_check.xpr"
launch_simulation

EOF

# Some Bash commands before Python execution
echo "Generating output image"

# Python code
python3 - <<END
from PIL import Image

# Read the whole content from the text file
with open('./temp/edgefile_canny.txt', 'r') as file:
    content = file.read()

# Split the content by tabs and convert to pixel values
numbers = [int(val.strip(), 16) for val in content.split(' ') if val.strip()]

# print(len(numbers))
# # Ensure there are 256x256 numbers
# if len(numbers) != 256 * 256:
#     print("Error: Number of pixels doesn't match 256x256")
#     exit()

# Create a new image
image = Image.new('L', (256, 256))  # 'L' mode for grayscale image

# Put the pixel values into the image
for y in range(256):
    for x in range(255):
        pixel_value = numbers[y * 256 + x]  # Index calculation for 2D array to 1D
        image.putpixel((x, y), pixel_value)

image.putpixel((255,255),0)

# Save the image
image.save('$output_image_path')  # Change the format as needed (e.g., JPG, BMP, etc.)
print("Output Image saved as : '$output_image_path'")

END
