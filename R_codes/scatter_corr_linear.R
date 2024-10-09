# This code generates a multi-faceted correlation scatterplot, relating genome length to attributes such as GC (%), CDS and coding efficiency (%)

library(tidyverse)
library(reshape2)
library(viridis)

vir_data <- read.csv("C:/Users/M H Rolin/Desktop/github/comparative_genomics/comparative_genomics_c_difficile_phage/R_codes/data/scatter_corr_linear.csv")
vir_data$length <- vir_data$length / 1000 

melted_data = melt(vir_data, id.vars = "length")

p1<-
melted_data %>%
  ggplot(aes(x = length, y = value, color = variable)) +
  geom_point (size = 3, stroke = 1) +
  scale_color_viridis(discrete = TRUE, alpha = 0.7, option = "C")+
  geom_smooth(method = "lm", formula = y ~ x, color = "cyan4") +
  facet_wrap(~ variable, scales = "free_y", nrow =3, switch = "y", labeller = 
               labeller(variable = c(gc = "GC(%)", cds = "CDS", 
                                     density = "Coding Efficiency (%)"))) +
  labs(x = "Genome Size (Kb)") + 
  scale_x_continuous(limits = c(0, 150), breaks = seq(0, 150, by = 30)) +
  theme_minimal() + 
  theme(strip.placement = "outside", strip.background = element_blank(),
        strip.text = element_text(size = 12, face = "bold", vjust = 2), 
        panel.spacing = unit(2, "lines"), 
        legend.position = "none")+
  theme(axis.title.y = element_blank())+
  theme(axis.title.x = element_text(size = 12, face = "bold", vjust = -1))+
  theme(panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())

p1

# use ggsave function to export the figure

