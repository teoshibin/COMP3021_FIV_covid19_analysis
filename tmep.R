
devtools::install_github("timelyportfolio/d3treeR")

# library
library(treemap)
library(d3treeR)

# dataset
group <- c(rep("group-1",4),rep("group-2",2),rep("group-3",3))
subgroup <- paste("subgroup" , c(1,2,3,4,1,2,1,2,3), sep="-")
value <- c(13,5,22,12,11,7,3,1,23)
data <- data.frame(group,subgroup,value)

# basic treemap
p <- treemap(data,
             index=c("group","subgroup"),
             vSize="value",
             type="index",
             palette = "Set2",
             bg.labels=c("white"),
             align.labels=list(
                 c("center", "center"), 
                 c("right", "bottom")
             )  
)            
p

# make it interactive ("rootname" becomes the title of the plot):
inter <- d3tree2( p ,  rootname = "General" )
inter

# save the widget
# library(htmlwidgets)
# saveWidget(inter, file=paste0( getwd(), "/HtmlWidget/interactiveTreemap.html"))