# This code generates a comparative genomic figure using some streptococcus phage genomes.
# For easier input path, all files are kept at the same folder


library(tidyverse)
library(gggenomes)

#read sequences
s0 <- read_seqs(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_cluster_wise",
                           pattern = "*.fasta", full.names = TRUE))
#read features from gff3 files
g0 <- read_feats(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_cluster_wise",
                            pattern = "*.gff", full.names = TRUE))
#read blastp results for linking proteins
e0 <- read_sublinks(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_cluster_wise",
                               pattern = "*.o6", full.names = TRUE))
#providing a customized color palette for phrogs functional categories
c0 <- c("unknown category" = "#808080", "head and packaging" = "#33A02C", "tail" = "#B2DF8A",
        "lysis" = "#E31A1C", "integration and excision" = "#FB9A99", "connector" = "#A6CEE3",
        "moron, auxiliary metabolic gene and host takeover" = "#FF7F00",
        "DNA, RNA and nucleotide metabolism" = "#6A3D9A", "other" = "#FDBF6F",
        "transcription regulation" = "#CAB2D6")
  
p1 <- gggenomes(g0,s0) %>%
  add_sublinks(blast=e0) + 
  geom_seq() + geom_gene(aes(fill = category)) + geom_link(alpha = 0.5) + 
  scale_fill_brewer(palette = "Paired") + geom_seq_label(hjust = +1.12, vjust = -0.5759) + 
  theme(legend.position = "bottom")  + scale_fill_manual(values = c0)

p1

#sometimes flipping the genomes are necessary for better visualization, the following commands flips all 8 sequences
flip_seqs(p1, 1:8) 
#the 'sync' function automates the process but not all the time, for example, in this case, flipping all the sequences works better
#sync(p1)
