### This program takes proteome file directory as inputs and writes filtered blastp results in tsv format. The resulting files are to be used to create links among proteins of two genomes in gggenome (R). This program assumes, the genomes are arranged in gggenome alphabetically. Thus instead of generating all vs all blastp result only sequential blastp serves the purpose. Change the directory where necessary. ###

## running the code in the terminal: python sequential_blastp.py

import os
import subprocess as sp

files = os.listdir("./blastp") #change the directory to where the proteome files are (files that end with .faa, contains all encoded proteins)
proteomes = []
for file in files:
    if file.endswith(".faa"):
        proteomes.append(file)
        
proteomes.sort() #sorting the list alphabetically

for i in range(len(proteomes)-1):
    command = ['blastp', '-query', f'./blastp/{proteomes[i]}', '-subject', f'./blastp/{proteomes[i+1]}', '-evalue', '1e-5', '-outfmt', '6'] #change the directory here too
    run_cmd = sp.run(command, capture_output = True, text = True)
    blastp_output = run_cmd.stdout.rstrip().split('\n')
    
    with open(f"./blastp/blast_out_{i}.o6", 'a') as outfile: #creates a new file for each iteration to store pairwise results, change the directory accordinhly     
        
        #filtering
        for line in blastp_output:
            single_output = line.split('\t')
            if float(single_output[2]) >= 35.0 and float(single_output[11]) >= 40:
                outfile.write(line + '\n')

# The filtering here is done using a 35% identity threshold and 40 bitscore. The blast output is in outfmt 6 format, so changing the indexing would change the fields. Additionally other fields can be added (just add more 'and' condition).
        
    
    