import re

# Function to parse words starting with '0000'
def parse_words(input_file, output_file):
    # Open the input file for reading
    with open(input_file, 'r') as infile:
        # Open the output file for writing
        with open(output_file, 'w') as outfile:
            # Loop through each line in the input file
            for line in infile:
                # Find all words starting with '0000' using regex
                words = re.findall(r'\b0000\w*\b', line)
                # Write each matching word to the output file
                for word in words:
                    outfile.write(word + '\n')

# Input and output file paths
input_file = 'input.txt'  # Replace with your input file path
output_file = 'done.txt'  # Replace with your output file path

# Call the function to parse and write words
parse_words(input_file, output_file)

print(f"Words starting with '0000' have been written to {output_file}")