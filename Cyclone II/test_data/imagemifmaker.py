import os

# Directory containing the test_data files
directory = 'C:/Thesis/test_data'

# Output file paths
mif_file_path = 'images.mif'
txt_file_path = '65th_values.txt'

# Open the output MIF file in write mode
with open(mif_file_path, 'w') as mif_file, open(txt_file_path, 'w') as txt_file:
    # Process the first 100 files in the directory
    for i, filename in enumerate(sorted(os.listdir(directory))):
        if filename.startswith('test_data_') and i < 128:
            file_path = os.path.join(directory, filename)
            with open(file_path, 'r') as input_file:
                lines = input_file.readlines()
                # Write the first 64 values to the MIF file
                for line in lines[:64]:
                    mif_file.write(line.strip() + '\n')
                # Write the 65th value to the TXT file
                if len(lines) >= 65:
                    txt_file.write(lines[64].strip() + '\n')

print(f"Data successfully written to {mif_file_path} and {txt_file_path}")
