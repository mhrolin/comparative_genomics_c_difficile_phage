### This is a very simple program that takes the metadata file from inphared database as input and based on a user given keyword which can be a phage name (or anything really, it won't return any matches unfortunately), extracts the metadata of phages which matches only the keyword. I wrote this for myself so that I don't have to deal with stupid excel sheets (I HATE EXCEL, but they can be really useful sometimes though). To find species level info, manual inspection is still necessary though ###

import os
import sys

#taking input from the terminal
if len(sys.argv) !=4:
    print("usage: python inphared_extractor.py [phage_name] [input_file_full_path] [output_file_full_path]")
    sys.exit(1)

phage = sys.argv[1].lower()
infile_dir = sys.argv[2]
outfile_dir = sys.argv[3]

#matching the phage keyword
with open(infile_dir) as infile:
    data = infile.read().rstrip().split('\n')
    phage_data = []
    for line in data:
        phage_info = line.split('\t')
        if phage in phage_info[1].lower():
            phage_data.append(phage_info)

#if the file already exists, should be removed first
if os.path.exists(outfile_dir):
    os.remove(outfile_dir)
with open(outfile_dir, 'a') as outfile:
    outfile.write(data[0] + '\n')
    for line in phage_data:
        outfile.write('\t'.join(line) + '\n')
    
print(f"No. of matches: {len(phage_data)}")