
# Installs pacman package if needed
if (!require("pacman")) install.packages("pacman")

# load packages
pacman::p_load(
    pacman,     # package installer
    installr,   # software installer
    rio,        # data importing
    dplyr,      # data manipulation
    tidyr,      # data manipulation (gather etc.)
    ggplot2,    # ploting
    stringr,    # string formatting
    scales,     # plot scales and color etc. 
    viridis,    # color palette
    hrbrthemes, # plot themes
    plotly,     # interactive plot
    treemap,    # tree plot
    htmlwidgets, # save interactive plot into html
    maps,
    gifski,
    gtools
)

# This is needed if packages are giving errors for incompatible binary distribution
# install.Rtools() 

devtools::install_github("timelyportfolio/d3treeR")
library(d3treeR) # interactive tree plot

# load custom functions
source("./functions/general_functions.R")

# inputs
dataset_path <- "./Data/"
function_path <- "./Functions/"

# outputs
itrt_plot_path <- "./Output/InteractivePlot/"
sttc_plot_path <- "./Output/StaticPlot/"
out_data_path <- "./Output/Data/"

daily_covid <- import(
    paste0(dataset_path, "worldometer_coronavirus_daily_data.csv")
)

summary_covid <- import(
    paste0(dataset_path, "worldometer_coronavirus_summary_data.csv")
)

head(daily_covid)
head(summary_covid)

daily_covid <-
    daily_covid %>%
    replace(is.na(.), 0) %>% 
    mutate(date = as.Date(date))

###############################################################################

# data
world <- map_data("world")

# loop config
date_seq <- seq(as.Date(min(daily_covid$date)), 
                as.Date(max(daily_covid$date)), "days")
print_frequrency <- 50
len_date_seq <- length(date_seq)

max_active_cases <- max(daily_covid$active_cases)
min_active_cases <- min(daily_covid$active_cases)

# generate active cases world map images
for (i in c(1:len_date_seq)) {
    
    current_date <- as.Date(date_seq[i])
    date_daily_covid <- filter(daily_covid, date == current_date)
    mapdata <- left_join(world, date_daily_covid, by= c("region" = "country"))
    
    map <-
        ggplot(mapdata, aes(x=long, y=lat, group=group)) +
        geom_polygon(
            aes(fill = active_cases), 
            color="black",
            size= 0.2
        ) +
        scale_fill_distiller(
            name="Active Cases", 
            palette = "Spectral",
            na.value = "grey50",
            trans = "log10",
            limits= c(min_active_cases, max_active_cases)
        ) +
        ggtitle(paste0("Date: ", current_date)) +
        xlab(element_blank()) +
        ylab(element_blank()) +
        guides(fill = guide_colourbar(
            barwidth = 0.5, 
            barheight = 10,
            ticks = F
        )) +
        # theme_light() +
        theme(
            plot.title = element_text(size=12),
            panel.background = element_rect(
                colour = "black", 
                fill = "white",
                size = 0.2
            ),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_blank(),
            panel.grid.minor.y = element_blank()
        )
    
    # save plot
    suppressMessages(ggsave(
        plot = map,
        filename = paste0(itrt_plot_path, "/qa5_map/", i,".png")
    ))
    
    # print log
    if ((i %% print_frequrency) == 0) {
        print(paste(i, "/", len_date_seq))
    }
    
}

# load png paths and convert it into GIF
png_files <- list.files(paste0(itrt_plot_path, "qa5_map/"), 
                        pattern = ".*png$", full.names = TRUE)
png_files <- mixedsort(sort(png_files))
gifski(png_files, gif_file = paste0(itrt_plot_path, "qa5_map_08fps.gif"), 
       width = 1920, height = 1065, delay = 0.125)

pacman::p_unload(all)