
# 1 data input -----------------------------------------------------------

library(readr)
library(readxl)
library(tidyverse)
library(dplyr)
# data clean requirement:
# 1.Add the group column for each sample.
# 2.The column names of data are the samples.
# 3.The row names of data are the symbols, sampleid and group.
# data iris
data("iris")
data <- iris %>%
  rename(group = "Species") %>%
  mutate(sampleid = rownames(iris))

head(data)
# 1.2 color setting -------------------------------------------------------
# The names(value_colour) need to be the same as table(data$group)
# If you have more than two groups,
# you can change the "group name" to your group name.
value_colour <- c("setosa" = "#00A087FF",# control group
                  "versicolor" = "#E64B35FF",# Experimental group
                  "virginica" = "#4DBBD5FF",# other group1
                  "other group2" = "#3C5488FF")# other group2
# 2 data QC --------------------------------------------------------------
# we need to check data:
# 1. no abnormal sample data
# 2. no non-biological differences
## 2.1 boxplot ------------------------------------------------------------
library(ggplot2)
library(tidyr)
data_ggplot <- tidyr::gather(data,key = "key",
                             value = "value",
                             -c("sampleid","group")
)
# arrange
data_ggplot <- data_ggplot %>%
  mutate(group = factor(.$group)) %>%
  arrange(group) %>%
  mutate(sampleid = factor(.$sampleid,
                           levels = unique(.$sampleid))) %>%
  arrange(sampleid)
# Plot the boxplot with ggplot2.
ggplot(data_ggplot,aes(x = sampleid,
                       y = log2(value + 1),
                       fill = group)
) +
  geom_boxplot() +
  scale_fill_manual(values = value_colour) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1,
                                   colour = "black",
                                   size = 10),
        axis.text.y = element_text(hjust = 1,
                                   colour = "black",
                                   size = 10)
  ) +
  labs(x = "")
ggsave(filename = "QC_boxplot.pdf",
       height = 5,
       width = 5,
       plot = last_plot())
ggsave(filename = "QC_boxplot.png",
       height = 5,
       width = 5,
       plot = last_plot())

## 2.2 heatmap ------------------------------------------------------------
data_heatmap <- data %>%
  subset(.,select = (-c(group,sampleid))) %>%
  t() %>%
  as.data.frame() %>%
  {log2((. + 1))}

library(pheatmap)
# annotation_col requirements:
# 1.the annotation_col must be a data frame
# 2.the row names of annotation_col == the column names of data_heatmap
# 3.the column names of annotation_col is the annotation legend name
#
# annotation_colors requirements:
# 1.the annotation_colors must be a list.
# 2.if the group is more than two, you can add by format.
annotation_heatmap <- data %>%
  select(group)
annotation_colors <- list(group = value_colour)
dev.off()
pdf(file = "QC_heatmap.pdf",
    height = 5,
    width = 5
)
pheatmap(data_heatmap,
         show_rownames = F,
         annotation_col = annotation_heatmap,
         annotation_colors = annotation_colors)
dev.off()

png(filename = "QC_heatmap.png",
    height = 2000,
    width = 2000,
    res = 300# ppi
)
pheatmap(data_heatmap,
         show_rownames = F,
         annotation_col = annotation_heatmap,
         annotation_colors = annotation_colors)
dev.off()
## 2.3 PCA ----------------------------------------------------------------

library(FactoMineR)
library(factoextra)

# data_pca <- data_pca %>%
#   subset(.,select = -c(group,sampleid))
# dat.pca <- PCA(data_pca,
#                graph = FALSE)
dat.pca <- data %>%
  subset(.,select = -c(group,sampleid)) %>%
  PCA(.,
      graph = FALSE)
group_list <- data$group
dev.off()
pdf(file = "QC_PCA.pdf",
    height = 5,
    width = 5
)
fviz_pca_ind(dat.pca,
             geom.ind = c("text","point"), # show points only (nbut not "text")
             col.ind = group_list, # color by groups
             palette = value_colour,
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)
dev.off()

png(filename = "QC_PCA.png",
    height = 2000,
    width = 2000,
    res = 300# ppi
)

fviz_pca_ind(dat.pca,
             geom.ind = c("text","point"), # show points only (nbut not "text")
             col.ind = group_list, # color by groups
             palette = value_colour,
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)
dev.off()
