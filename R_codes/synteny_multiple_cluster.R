# This code also generates comparative genomics figure but this time it combines multiple clusters
# The code uses cluster 7,8,9 genomes of c. difficile phages as described in our study (see the readme.md)

library(tidyverse)
library(gggenomes)
library(patchwork)

s0 <- read_seqs(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_7",
                           pattern = "*.fasta", full.names = TRUE))
g0 <- read_feats(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_7",
                            pattern = "*.gff", full.names = TRUE))
e0 <- read_sublinks(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_7",
                               pattern = "*.o6", full.names = TRUE))

s1 <- read_seqs(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_8",
                           pattern = "*.fasta", full.names = TRUE))
g1 <- read_feats(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_8",
                            pattern = "*.gff", full.names = TRUE))
e1 <- read_sublinks(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_8",
                               pattern = "*.o6", full.names = TRUE))

s2 <- read_seqs(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_9",
                           pattern = "*.fasta", full.names = TRUE))
g2 <- read_feats(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_9",
                            pattern = "*.gff", full.names = TRUE))
e2 <- read_sublinks(list.files(path = "C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/for_gggenome_multiple_cluster/clu_9",
                               pattern = "*.o6", full.names = TRUE))


c0 <- c("unknown category" = "#808080", "head and packaging" = "#33A02C", "tail" = "#B2DF8A",
        "lysis" = "#E31A1C", "integration and excision" = "#FB9A99", "connector" = "#A6CEE3",
        "moron, auxiliary metabolic gene and host takeover" = "#FF7F00",
        "DNA, RNA and nucleotide metabolism" = "#6A3D9A", "other" = "#FDBF6F",
        "transcription regulation" = "#CAB2D6")

p1 <- gggenomes(g0,s0) %>%
  add_sublinks(blast=e0) + 
  geom_seq() + geom_gene(aes(fill = category)) + geom_link(alpha = 0.5) + 
  scale_fill_brewer(palette = "Paired") + geom_seq_label(hjust = +1.12, vjust = -0.5759) + 
  theme(legend.position = "none")  + scale_fill_manual(values = c0)

p2 <- gggenomes(g1,s1) %>%
  add_sublinks(blast=e1) + 
  geom_seq() + geom_gene(aes(fill = category)) + geom_link(alpha = 0.5) + 
  scale_fill_brewer(palette = "Paired") + geom_seq_label(hjust = +1.12, vjust = -0.5759) + 
  theme(legend.position = "none")  + scale_fill_manual(values = c0)

p3 <- gggenomes(g2,s2) %>%
  add_sublinks(blast=e2) + 
  geom_seq() + geom_gene(aes(fill = category)) + geom_link(alpha = 0.5) + 
  scale_fill_brewer(palette = "Paired") + geom_seq_label(hjust = +1.12, vjust = -0.5759) + 
  theme(legend.position = "bottom")  + scale_fill_manual(values = c0)

p2 <- flip_seqs(p2, 2)
p1 + p2 + p3 + plot_layout(ncol = 1)
