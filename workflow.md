# 1. Phage genome acquisition

- [INPHARED](https://github.com/RyanCook94/inphared) is an excellent resource for acquiring sequenced phage genome data. We can navigate the date_data_excluding_refseq.tsv file in excel and use the filter and search function to get the information of our desired phage genomes. The description is sometimes ambiguous in species level, so, manual inspection may be required. Alternatively, if you are lazy like me, you can just skip opening the tsv file with nearly ~25K genome data and prefilter to get only the desired phage info by searching genus name (e.g.: escherichia/klebsiella) using [this](./python_codes/inphared_subset_extractor.py) code.

## 1.1. Extracting Fasta from NCBI entrez

- From the previous step, we should have a tsv file containing metadata of our desired phage genomes.
- Copy all the accession numbers to a text file, each accession on a separate line.
- Go to [ncbi batch entrez](https://www.ncbi.nlm.nih.gov/sites/batchentrez) and upload the text file containing the accessions. Should give us a long list of records. All that's left is to download the genomes as a multifasta file.
   
## 1.2. Duplicate sequence removal using CD-HIT

```bash
cd-hit-est -i [inputfile] -o [outputfile] -c 1 -n 10 # word size may be subjected to change with regards to identity threshold
```
- Check the .clstr file \for the number of clusters and see if there are any duplicate genomes.
- The other output file is a multifasta file containing unique (cluster representative) genomes.
- We can use this file for subsequent analyses.

## 1.3. Lifestyle Prediction

- [Bacphlip](https://github.com/adamhockenberry/bacphlip) can be used to predict if our phages are lytic or temperate.
- Given that the software is properly installed, the command is fairly straightforward.
```bash
bacphlip -i [path/to/the/multifasta file] --multi_fasta
```
- Providing the local hmmsearch path may be necessary if not installed in the system.

## 1.4. Genome annotation using Pharokka

- [Pharokka](https://github.com/gbouras13/pharokka) is a phage annotation tool with many handy features.
- We can use the following command to run pharokka:
```bash
pharokka.py -i [multifasta] -o [output_folder] -t [cpu threads] -m -s 
```
- If there are issues with pharokka installation or database installation:
    - git clone the repository
      ```bash
      git clone [repository_URL]
      ```
    - 'cd' (or open the terminal in the bin folder) to the bin folder and run pharokka.py manually (be sure to create a separate environment first and install the dependencies)
    - the PHROGs database can be downloaded separately, use the '-d' flag to direct to local path to the database

## 1.5. Generating some basic statistical figure

- Pharokka generates a summary tsv file containing genome length, GC (%), and CDS density. We can add one additional attribute to the file which is no. of coding sequences (CDS) per genome. Using these data we can generate two figures - A scatterplot depicting genome length distribution and a correlation scatterplot of GC (%), no. of CDS, coding density in relation to genome length.
    - The genome length scatterplot code is given in [here](./R_codes/length_scatterplot.R).
    - The correlation scatterplot code is given in [here](./R_codes/scatter_corr_linear.R).

# 2. Clustering the genomes

- We went with protein-sharing-based clustering in our study.
- For that, we have some preprocessing to do.

## 2.1. Phage proteins into Phams using Phammseqs

- To run [phammseqs](https://github.com/chg60/PhaMMseqs), we need proteome files of the phage genomes.
- After running pharokka, we should have a "prodigal.faa" file that contains all the proteins encoded by the phage genomes. We have to split that file if we want to run phammseqs with pangenome enabled. The single-file approach does have its use. We can assort any type of proteins into phams or homologs.
- To split the proteome files into proteomes of individual genome we will use [seqkit](https://bioinf.shenwei.me/seqkit/). Seqkit is an excellent tool for sequence file manipulation, offers tons of functionality.
- The approach to split is based on regex (regular expression). In the proteome file, the accessions are written such as this - ">CP011970.1_CDS_0003 portal protein". There may be a more sophisticated approach but my approach was to match the genome accession up to the dot. Regex is a whole other world, so it may not make much sense, and I haven't even scratched the surface in my opinion. However, this command should work:
```bash
seqkit split -i --id-regexp "(.*\.)" prodigal.faa
```
- The output files may look a little weird with names like "prodigal.part_CP011970..faa", so they should be suitably renamed. If there are not hundreds of genomes, group rename should work - "ctrl + a" --> "F2", otherwise a simple python code may be needed.
- Finally, run phammseqs:
```bash
phammseqs [path/to/the/proteomes] -p -c [cpu thread] -o [output_folder] --identity [value] --coverage [value]
```
## 2.2. Phamclust to cluster genomes

- From the previous step (given that phammseqs ran with the flag "-p"; pangenome option enabled, we would get a file called "strain_genes.tsv". This is basically a genome to pham mapping file with protein sequences. This file would be our input file for running [phamclust](https://github.com/chg60/phamclust). Phamclust does have a workaround to this by providing a flag "-g" if the input is genome sequences. However, my system always returned an error whenever I tried to input genome FASTAs instead of the mapping file.
```bash
phamclust [path/to/strain_genes.tsv] [output_folder] -n -r -c [value]
```
- "-n" for no subclustering (exclude if your goal is to subcluster), "-r" removes intermediate files, "-c" similarity threshold.

## 2.3. Genome comparison figures

- [gggenome](https://github.com/thackl/gggenomes) is a great tool for generating genome comparison figures or just genome maps. However, I have found the documentation to be a little difficult to understand. Here, I have tried to be as straightforward as I could. We can compare genomes from the same cluster to see how conserved they are or from different clusters to how dissimilar they are. Additionally, this can be a neat way to observe the mosaicism of phage genomes.
- Prerequisites:
    - FASTA files of genomes (optional, as the read function of gggenome can read the sequence information from the gff3 file)
    - GFF3 files
    - All vs all BLASTp result files to create links (indicates similarity) between genes
- Genomes, if uploaded as a batch, are arranged in the figure alphabetically.
- Based on that arrangement we can just do pairwise all vs all BLASTp. What I mean by that is
    - let's say A, B, C, and D are accessions of four genomes that are uploaded as batch
    - the corresponding proteome files should also be named as accessions A, B, C, and D. If the proteome files are placed in the same folder, a simple python [code](./python_codes/sequential_blastp.py) is sufficient to run pairwise BLASTp without having to run the same command over and over.

- The codes to generate comparative genome figures are given [here](./R_codes/synteny_cluster_wise.R).

## 2.4. Pangenome analysis

- We can use [pirate](https://github.com/SionBayliss/PIRATE) to construct pangenome and identify core genes.
- The usual command goes like this:
```bash
PIRATE -i [path to gff files] -o [output folder] -s 30,35 -a -r -t [cpu thread] -q
```
- This is for 35% similarity. A gene is defined as a core gene if the gene is in 95 to 100% isolates in pirate, but this is usually dependent on the researcher and the aspect of one's study.

# 3. Phylogenetics

- For whole genome phylogeny [VICTOR](https://victor.dsmz.de) is a great resource. It also provides taxonomic inferences. Unfortunately, one major limitation is that the no. of sequences is capped at 100.
- Another great option for phylogeny and taxonomic inference is [VipTree](https://www.genome.jp/viptree/).
- The resulting phylogenetic trees can be annotated and visualized at [iTOL](https://itol.embl.de/).
- Annotation can be made easier with a well-structured tsv/csv file containing the IDs (accessions) of the genomes (or proteins for protein phylogeny) and other attributes combined with a simple tool like [iTOLparser](https://github.com/boasvdp/itolparser).
```bash
itolparser -i [table.tsv] -o [output_folder] 
```
- Network-based phylogeny is often suggested for phages which could be achieved by running [vContact2](https://bitbucket.org/MAVERICLab/vcontact2/src)
- Prerequisites
    - raw protein file; this is the "prodigal.faa" file from pharokka annotation
    - a gene-to-genome (g2g) mapping file; basically a comma-separated (csv) file linking protein accessions to their corresponding genomes.
    - [clusterone](https://paccanarolab.org/clusterone/)
    - raw protein file and g2g file should be merged with reference if you want to infer taxonomy from known genomes.
  
## 3.1. Generating a g2g file:

- g2g file is structured like this - 'protein id','contig id','keywords'. An [example file](./python_codes/gene2genome.csv) is given to provide a representation of a typical g2g file.
- Protein ids in the g2g file should match the raw protein file's accessions as well.
- We can start with "prodigal.faa" file. For example: an accession in "prodigal.faa" looks like this: ">CP011970.1_CDS_0003 portal protein", the g2g entry for this protein would be - CP011970.1_0003,CP011970.1,none.
- If the file is not too large, we can get away without coding for it.
- Open the file in text editor -> "ctrl+h" -> first replace the "_CDS" with empty string.
- Click on the ".\*" to opt for regex -> enter the regex " .\*" (without quotes, space is included) to match everything after the space, replace with empty string, save the file (let's call it "prots.faa").
- Extract the protein ids:
```bash
grep ">" prots.faa > protein_ids.txt
```
   - replace ">" in the protein_ids.txt file with empty string and save the file.
- This file can be used to create contig_ids. Use the regex "_\d+$" (without quotes) to select the "_0001" portion and replace with empty string. Now we only have the contig_ids, save the file as contig_id.txt.
- Combine the two files to create g2g.
```bash
paste -d ',' protein_ids.txt contig_ids.txt > g2g.txt
```
- Add "protein_id,contig_id,keywords" as the first line. Finally, we can run vcontact2 (phew!).
```bash
vcontact2 -r prots.faa -p g2g.csv --db None --c1-bin [path to clusterone.jar] -o [output_folder]
```
- c1.ntw is a network file that can be visualized using [cytoscape](https://cytoscape.org/).
- [This](https://www.protocols.io/view/applying-vcontact-to-viral-sequences-and-visualizi-kqdg3pnql25z/v5) is a good tutorial on how to visualize the network file.
- Additionally, [this](https://github.com/miriamposner/cytoscape_tutorials) repository offers basic introduction to cytoscape.

# 4. Exploring Endolysins and Holins

- With a good reference dataset, specific proteins can be extracted from large proteome files like the one we discussed, "prodigal.faa".
- We initially used a previously [published](https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2018.01033/full) database of endolysins. The [diamond](https://github.com/bbuchfink/diamond) commands are given below:
```bash
diamond makedb --in [reference_sequence_database.faa] -d reference_db
diamond blastp -d reference_db -q prodigal.faa --id 30 -k 1 -p 4 -o matches.tsv -f 6 qseqid full_qseq qlen sseqid slen pident nident length evalue --ultra-sensitive
```
- We used less stringent parameters to extract all possible endolysin sequences. Still, there were endolysins that we could not extract using diamond. 
- Thus in addition to diamond, we can use another approach. In step 2.1, we assorted proteins into groups of homologs or phams. A little manual search using 'grep' can give us the phams of endolysins.
```bash
grep "endolysin" pham_fastas/*.faa > endolysin_phams.txt
```
- In addition to the keyword "endolysin", searching should be commenced with domain names too like "amidase", "lysozyme" etc.
- Once we get the pham list, we can extract the phams using the 'xargs' command.
```bash
xargs -a pham_list.txt -I {} cp pham_fastas/{} /destination/folder
```
- For domain prediction and phylogenetics, we need to combine all the endolysins sequences. Given that all endolysin phams are in the same folder ->
```bash
cat endolysin_phams/*.faa > all_endolysins.faa
```
- Same exact steps can be run for holins as well.
  
## 4.1. Domain prediction

- The most straightforward way to predict domains is using [DAVI](http://genome.lcqb.upmc.fr/Domain-Architecture-Viewer/help.php)
- DAVI may fail to identify some domains. Another way to predict domains is to use [Hmmer](https://www.ebi.ac.uk/Tools/hmmer/).
- If you have a lot of sequences, using local hmmer suite may serve your purpose better.
- For that we'll need Pfam-A.hmm; hmm profiles of pfam database to run "hmmscan" program. The file can be downloaded from [here](https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/).
- We can run domain prediction using the following commands:
```bash
hmmpress Pfam-A.hmm
hmmscan --domtblout [file_name] --noali Pfam-A.hmm all_endolysins.faa
```

## 4.2. Phylogenetic tree and evolutionary analysis

- Phylogenetic tree can be constructed using the [ETE3](https://www.genome.jp/tools/ete/) pipeline using the following parameters:
    - aligner -> mafft_default
    - alignment cleaner -> trimal_gappyout
    - tree builder -> iqtree_bestmodel
- The resulting tree can be annotated using the previously described method discussed in section 3.
- For selection pressure analysis we can utilize the [datamonkey](https://www.datamonkey.org/) server.
- We need the genes for this step. We can use grep to get the accessions from a particular pham and save them as a list. Using seqkit, we can get the gene sequences. Previously, we extracted the endolysins from "prodigal.faa" file, generated from pharokka annotation. Similarly, pharokka generates "prodigal.ffn" that contains the gene sequences.
```bash
seqkit grep -n -f [accession.txt] -o [output_filename] prodigal.ffn
```
- The gene sequences need some preprocessing before we can go ahead with observing selection pressure. The preprocessing includes removing stop codons and cleaning the alignment.
- We can utilize the [Macse](https://www.agap-ge2pop.org/macse/) program to generate codon aware alignments.
- Then, use [trimal](https://github.com/inab/trimal) to clean the alignment.
```bash
trimal -in [input_alignment_file] -out [output_folder] -gappyout #cd to trimal main folder if not installed in the system, use './' (w/o quotes) before calling trimal [applicable for some other programs as well]
```




### P.S. All codes, data used to run the codes and some results are included in the repository.
