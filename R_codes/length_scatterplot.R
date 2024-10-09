# This simple piece of code generates a scatterplot based on genome length.
# The supporting data is provided in 'data' folder.
# Change the directory accordingly, if you want to use the code

library(tidyverse)
library(ggExtra)
library(viridis)

vir_data = read.csv("C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/length_scatterplot.csv")

p1 <-
vir_data %>%
  ggplot(aes(reorder(phages,length), length, colour = Genus, stroke = 1))+
  geom_point(alpha = 0.7, size = 4) +
  scale_color_viridis(discrete = TRUE, alpha = 0.7, option = "C")+
  labs(title = "Genome Size of Phages", x = "Phages", y = "Genome Size (kb)")+
  scale_y_continuous(limits = c(0, 150), breaks = seq(25, 150, by = 50))+ theme_minimal()+
  theme(axis.text.x = element_text(face = "bold",angle = 90))+
  theme(panel.grid.major.x = element_blank())+
  theme(axis.title.x = element_text(face = "bold", size = 14))+
  theme(axis.title.y = element_text(face = "bold", size = 14))+
  theme(legend.position = "bottom left")+
  theme(legend.text = (element_text(face = "bold")))+
  theme(legend.title = element_text(face = "bold"))+
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5))
p1  

p2 <- ggMarginal(p1, margins = "y", type = "boxplot", size = 10, 
                 fill = "purple", alpha = 0.5)
p2
