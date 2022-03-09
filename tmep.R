library(dplyr)
library(babynames)
library(viridis)
library(hrbrthemes)
library(plotly)

# Load dataset from github
data <- babynames %>% 
    filter(name %in% c("Ashley", "Amanda", "Jessica",    "Patricia", "Linda", "Deborah",   "Dorothy", "Betty", "Helen")) %>%
    filter(sex=="F")
data
# Plot
p <- data %>% 
    ggplot( aes(x=year, y=n, fill=name, text=name)) +
    geom_area( ) +
    scale_fill_viridis(discrete = TRUE) +
    theme(legend.position="none") +
    ggtitle("Popularity of American names in the previous 30 years") +
    theme_ipsum() +
    theme_bw()+
    theme(legend.position="none")

# Turn it interactive
p <- ggplotly(p, tooltip="text")
p

# save the widget
# library(htmlwidgets)
# saveWidget(p, file=paste0( getwd(), "/HtmlWidget/ggplotlyStackedareachart.html"))