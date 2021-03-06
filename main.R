# PLEASE USE THE R MARKDOWN INSTEAD OF THIS
# R MARKDOWN IS MORE VISUALLY PRESENTABLE
# THIS IS JUST A GENERATED R SCRIPT FROM R MARKDOWN

# NOTE: SOME SECTIONS OF THE CODES ARE LEGIT CODES, BUT COMMENTED OUT TO PREVENT
#       LONG TIME RENDERING, JUST IN CASE YOU WANT TO RUN THE WHOLE SCRIPT WITHOUT IT.
#       TO RUN IT SIMPLE UNCOMMENT THEM (CHECK COMMENTING TOGGLING HOTKEY)

## ---- warning=FALSE, results='hide', message=FALSE--------------------------------------------

# Installs pacman package if needed
if (!require("pacman")) install.packages("pacman")

# load packages
pacman::p_load(
    pacman,     # package installer
    installr,   # software installer
    rio,        # data importing
    plotly,     # interactive plot
    gganimate,  # animating ggplot
    hrbrthemes, # plot themes
    viridis,    # color palette
    treemap,    # tree plot
    htmlwidgets,# save interactive plot into html
    scales,     # plot scales and color etc. 
    egg,        # arrange multiple plots into one plot
    gifski,     # GIF renderer
    tidyr,      # data manipulation (gather etc.)
    stringr,    # string formatting
    maps,       # map dataset
    gtools,     # sort functions etc.
    dplyr,      # data manipulation
    ggplot2     # plot
    )

# This is needed if packages are giving errors for incompatible binary distribution
# install.Rtools() 

devtools::install_github("timelyportfolio/d3treeR")
library(d3treeR) # interactive tree plot


## ---------------------------------------------------------------------------------------------------------
# inputs
in_data_path <- "./Data/"
function_path <- "./Functions/"

# outputs
html_plot_path <- "./Output/HTML/"
png_plot_path <- "./Output/PNG/"
gif_plot_path <- "./Output/GIF/"
out_data_path <- "./Output/Data/"



## ---------------------------------------------------------------------------------------------------------

daily_covid <- import(
    paste0(in_data_path, "worldometer_coronavirus_daily_data.csv")
    )

summary_covid <- import(
    paste0(in_data_path, "worldometer_coronavirus_summary_data.csv")
    )

daily_vac <- import(
    paste0(in_data_path, "country_vaccinations.csv")
    )

head(daily_covid)
head(summary_covid)
head(daily_vac)



## ---------------------------------------------------------------------------------------------------------

daily_covid <-
    daily_covid %>%
    replace(is.na(.), 0) %>% 
    mutate(date = as.Date(date))

daily_vac <-
    daily_vac %>%
    replace(is.na(.), 0) %>% 
    mutate(date = as.Date(date))



## ---------------------------------------------------------------------------------------------------------

## global percentage of death, active case and recovered ##

# sum vertically
categories <- c("total_deaths", "total_recovered", "active_cases")
category <- str_replace_all(categories, pattern =  "_", replacement = " ")
category <- str_to_title(category)

data <- 
    summary_covid[, categories] %>%
    colSums(na.rm = T)
data <- data.frame(
  category=category,
  count=data
)

data$prettyCount <- prettyNum(data$count, big.mark = ",", scientific = F)

# Compute percentages
data$fraction <- data$count / sum(data$count)

# Compute the cumulative percentages (top of each rectangle)
data$ymax <- cumsum(data$fraction)

# Compute the bottom of each rectangle
data$ymin <- c(0, head(data$ymax, n=-1))

# Compute label position
data$labelPosition <- (data$ymax + data$ymin) / 2

# Compute display percentages
data$prettyFraction <- percent(data$fraction)

# Make the plot
p <- 
    ggplot(data, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=category)) +
    geom_rect() +
    geom_text( 
        x=4.3, 
        aes(y=labelPosition, label=prettyCount, color=category, fontface="bold"), 
        size=3.5
    ) + # x here controls label position (inner / outer)
    geom_text(
        x=3.5, 
        aes(y=labelPosition, label=prettyFraction, fontface="bold"), 
        color="white",
        size=4
    ) +
    scale_fill_brewer(palette="Set2") +
    scale_color_brewer(palette="Set2") +
    coord_polar(theta="y") +
    xlim(c(2, 4)) +
    annotate(
        geom = "text", 
        x = 2, 
        y = 0, 
        colour = "#eba834",
        label = paste0(
            "Total Cases\n", 
            prettyNum(sum(data$count), big.mark = ",", scientific = F)
        )
    ) +
    theme_void() +
    theme(
        plot.background = element_rect(fill='white', color="white")
    )

ggsave(paste0(png_plot_path, "qa1.png"), width = 1920, height=1080 , units = "px")

p

# clean up memory
rm(categories, category, data, p)
invisible(gc())



## ---------------------------------------------------------------------------------------------------------
## comparison of cases between different continent ##

p <- 
    summary_covid %>% # data
    select(country:active_cases) %>%
    group_by(continent) %>% # group_by 
    filter(total_confirmed > quantile(total_confirmed, 0.7)) %>% # removing small cases
    ungroup() %>% 
    group_by(continent, country) %>% 
    # turning 3 columes into sub sub group (wide to long conversion)
    gather(category, count, total_recovered, active_cases, total_deaths, factor_key=T) %>% 
    ungroup() %>% 
    mutate(category = factor(category, labels = c("Recovered", "Active Cases", "Deaths"))) %>% 
    treemap( index=c("continent","country","category"),
             vSize="count",
             type="index",
             palette = "Set2",
             title = "Group by continent top 70 percentile confirmed cases",
             align.labels=list(
                 c("center", "center"),
                 c("left", "top"),
                 c("left", "bottom")
             )
        )

itrt_p <- d3tree2( p ,  rootname = "Group by continent top 70 percentile confirmed cases" )
saveWidget(itrt_p, file = paste0(html_plot_path, "qa2.html"))

itrt_p

# clean up memory
rm(p, itrt_p)
invisible(gc())



## ---- warning=FALSE---------------------------------------------------------------------------------------

# overview of accumulated cases vs date for all the country

# global stacked area plot
data <- 
    
    # group by summation
    daily_covid %>% 
    group_by(date) %>% 
    summarise(
        cumulative_total_cases = sum(cumulative_total_cases, na.rm = T),
        cumulative_total_deaths = sum(cumulative_total_deaths, na.rm = T),
    ) %>% 
    
    # convert wide columns to long rows
    gather(categories, count,
           cumulative_total_cases, cumulative_total_deaths) %>% 
    
    # 
    rowwise() %>% 
    mutate(text = 
               paste(
                   str_to_title(last(strsplit(categories, "_")[[1]])),
                   "Count:", comma(count),
                   "\nDate:", as.Date(date, format = "%d %b %Y")
               )
    ) %>% 
    arrange(date) # this is just to check if text is appended properly

# write.csv(data, paste0(out_data_path, "qa3.csv"))

facet_labels <- c(
    'cumulative_total_cases'="Cumulative Cases",
    'cumulative_total_deaths'="Cumulative Deaths"
)

p <-          # I can't use any function in the text argument \|/
    ggplot(data, aes(x=date, y=count, group=categories, fill=categories, text = text)) +
    geom_area(alpha=0.8 , size=0.5, color="black") +
    facet_wrap(~categories, scales = "free_y",  labeller = as_labeller(facet_labels)) +
    scale_fill_viridis(discrete = T, option="B", begin = 0.3, end = 0.7) +
    scale_x_date(date_labels = "%b %Y") +
    scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6)) +
    ggtitle("Cumulative Covid Cases") +
    ylab("Covid Cases") +
    xlab("Date") +
    theme_ipsum() +
    theme(
        legend.position="none", 
        axis.text.x = element_text(angle=45, hjust = 1),
        plot.background = element_rect(fill='white', color="white"),
    )

ggsave(paste0(png_plot_path, "qa3.png"), width = 1920, height=1080 , units = "px")

itrt_p <- ggplotly(p, tooltip = "text")
saveWidget(itrt_p, file = paste0(html_plot_path, "qa3.html"))

itrt_p
p

# clean up memory
rm(data, facet_labels, p, itrt_p)
invisible(gc())



## ---- warning=FALSE, eval=FALSE---------------------------------------------------------------------------
## 
## # ranking of cases for the top n countries
## data <-
##     daily_covid %>%
##     group_by(date) %>% # The * 1 makes it possible to have non-integer ranks while sliding
##     mutate(
##         rank = rank(-active_cases),
##         # relative_value = active_cases / active_cases[rank==1],
##         value_label =
##             ifelse(
##                 active_cases >= 1e9,
##                 paste0(" ", round(active_cases/1e9, 4)," B"),
##                 ifelse(
##                     active_cases >= 1e6,
##                     paste0(" ", round(active_cases/1e6, 2), " M"),
##                     ifelse(
##                         active_cases >= 1e3,
##                         paste0(" ", round(active_cases/1e3, 1), " K"),
##                         paste0(" ", active_cases)
##                     )
##                 )
##             )
##     ) %>%
##     group_by(country) %>%
##     filter(rank <=10) %>%
##     ungroup()
## 
## # plot
## p <-
##     data %>%
##     ggplot(aes(rank, active_cases, fill = as.factor(country), color = as.factor(country))) +
##     # geom_col(width = 0.8, position="identity") +
##     geom_tile(aes(y = active_cases /2,
##                 height = active_cases,
##                 width = 0.9), alpha = 0.7, color = NA) +
##     geom_text(aes(y = 0, label = paste(country, " ")),
##               vjust = 0.2, hjust = 1, size=6) +
##     geom_text(aes(y = active_cases, label = value_label, hjust = 0),
##               size=6) + # value label
##     coord_flip(clip = "off", expand = FALSE) +
##     scale_x_reverse() +
##     guides(color = FALSE, fill = FALSE) +
##     theme(
##         axis.line=element_blank(),
##         axis.text.x=element_blank(),
##         axis.text.y=element_blank(),
##         axis.ticks=element_blank(),
##         axis.title.x=element_blank(),
##         axis.title.y=element_blank(),
##         legend.position="none",
##         panel.background=element_blank(),
##         panel.border=element_blank(),
##         panel.grid.major=element_blank(),
##         panel.grid.minor=element_blank(),
##         panel.grid.major.x = element_line( size=.1, color="grey" ),
##         panel.grid.minor.x = element_line( size=.1, color="grey" ),
##         plot.title=element_text(size=25, hjust=0.5, face="bold", colour="grey", vjust=-1),
##         plot.subtitle=element_text(size=18, hjust=0.5, face="italic", color="grey"),
##         plot.caption =element_text(size=12, hjust=0.5, face="italic", color="grey"),
##         plot.background=element_blank(),
##         plot.margin = margin(2, 6, 2, 8, "cm"))
## 
## # aniamtion
## p <-
##     p +
##     transition_states(date,36,8) +
##     view_follow(fixed_x = TRUE)  +
##     labs(title = 'Date : {closest_state}',
##        subtitle  =  "Top 10 Countries Covid 19 Active Cases",
##        caption  = "Covid 19 Dataset") +
##     enter_grow() +
##     exit_shrink() +
##     ease_aes('cubic-in-out')
## 
## animate(p, 200, fps = 24, duration = 120,width = 1280, height = 720,
##         renderer=gifski_renderer(paste0(gif_plot_path, "qa4.gif")))
## 
## rm(data, p)
## invisible(gc())
## 


## ---- eval=FALSE, warning=FALSE---------------------------------------------------------------------------
## # 100 MB of images will be generated during the process
## # The final GIF is around 20MD with a resolution of 1920 x 1065, 8 fps
## 
## # An extra standalone R script (./qa5.R) is available for this section
## # In case that it doesn't work in Rmarkdown
## 
## # map boarder data
## world <- map_data("world")
## 
## # loop config
## date_seq <- seq(as.Date(min(daily_covid$date)),
##                 as.Date(max(daily_covid$date)), "days")
## print_frequrency <- 50
## len_date_seq <- length(date_seq)
## 
## max_active_cases <- max(daily_covid$active_cases)
## min_active_cases <- min(daily_covid$active_cases)
## 
## # output settings
## gif_name <- "qa5"
## gif_frame_folder <- paste0(gif_plot_path, gif_name,"/")
## if (!file.exists(gif_frame_folder)) {
##  dir.create(gif_frame_folder)
## }
## 
## # generate active cases world map images
## for (i in c(1:len_date_seq)) {
## 
##     current_date <- as.Date(date_seq[i])
##     date_daily_covid <- filter(daily_covid, date == current_date)
##     mapdata <- left_join(world, date_daily_covid, by= c("region" = "country"))
## 
##     map <-
##         ggplot(mapdata, aes(x=long, y=lat, group=group)) +
##         geom_polygon(
##             aes(fill = active_cases),
##             color="black",
##             size= 0.2
##         ) +
##         scale_fill_distiller(
##             name="Active Cases",
##             palette = "Spectral",
##             na.value = "grey50",
##             trans = "log10",
##             limits= c(min_active_cases, max_active_cases)
##         ) +
##         ggtitle(paste0("Date: ", current_date)) +
##         xlab(element_blank()) +
##         ylab(element_blank()) +
##         guides(fill = guide_colourbar(
##             barwidth = 0.5,
##             barheight = 10,
##             ticks = F
##         )) +
##         theme(
##             plot.title = element_text(size=12),
##             panel.background = element_rect(
##                 colour = "black",
##                 fill = "white",
##                 size = 0.2
##             ),
##             axis.text.x = element_blank(),
##             axis.text.y = element_blank(),
##             axis.ticks = element_blank(),
##             panel.grid.major.x = element_blank(),
##             panel.grid.minor.x = element_blank(),
##             panel.grid.major.y = element_blank(),
##             panel.grid.minor.y = element_blank()
##         )
## 
##     # save plot
##     suppressMessages(ggsave(
##         plot = map,
##         filename = paste0(gif_frame_folder, i,".png"),
##         width = 2940, height=1632 , units = "px"
##     ))
## 
##     # print log
##     if ((i %% print_frequrency) == 0) {
##         print(paste(i, "/", len_date_seq))
##     }
## 
## }
## 
## # load png paths and convert it into gif
## png_files <- list.files(gif_frame_folder, pattern = ".*png$", full.names = TRUE)
## png_files <- mixedsort(sort(png_files))
## gifski(png_files, gif_file = paste0(gif_plot_path, gif_name,".gif"),
##        width = 1920, height = 1065, delay = 0.125)
## 
## # remove variables as they are too memory intensive
## rm(world, date_seq, print_frequrency, len_date_seq, max_active_cases,
##    min_active_cases, current_date, date_daily_covid, mapdata, map,
##    gif_name, gif_frame_folder, png_files, i)
## invisible(gc())
## 


## ----fig.align="center", fig.width = 10, fig.height = 6, eval=TRUE----------------------------------------

# we can easily tell from previous plots that most of the cases are from big
# countries. Now, I'm curious about the relation between population & Covid cases

p <- summary_covid %>%
    
    # Reorder countries to having big bubbles at the back
    arrange(desc(total_tests)) %>%
    
    # prepare text for tooltip
    mutate(text = 
               paste0(
                   "Country: ", country, 
                   "\nPopulation: ", comma(population), 
                   "\nTotal Cases:\t", comma(total_confirmed), 
                   "\nTotal Tests\t", comma(total_tests)
               )
           ) %>%
    
    ggplot( 
        aes(
            x = population, 
            y = total_confirmed, 
            fill = continent, 
            size = total_tests, 
            text = text
        )
    ) +
    geom_point(alpha=0.5, color = "black", shape = 21, na.rm = T) +
    scale_x_log10(
        labels = unit_format(unit = "M", scale = 1e-6),
        breaks = 1e+3 * 10^(seq(0,20,2)),
    ) +
    scale_y_log10(
        labels = unit_format(unit = "M", scale = 1e-6),
        breaks = 10^(seq(1,21,2)),
    ) +
    scale_size(range = c(2, 25), name="Total Tests (M), Size") +
    labs(fill = 'Continent, Color') +
    scale_fill_viridis(discrete=T, option = "D") +
    coord_cartesian(clip = "off") +
    ylab("Covid Cases (M), log10(n)") +
    xlab("Population (M), log10(n)") +
    theme_bw()
ggsave(paste0(png_plot_path, "qb1.png"), width = 3840, height=2160, units = "px")

# turn interactive ggplot with plotly and save it
itrt_p <- ggplotly(p, tooltip="text")
saveWidget(itrt_p, file = paste0(html_plot_path, "qb1.html"))

itrt_p
p

rm(p, itrt_p)
invisible(gc())



## ---------------------------------------------------------------------------------------------------------
# USA, UK, INDIA, BRAZIL

# our interest is on countries that have intensive drop and rise daily new cases
high_variance_countries <-
    daily_covid %>% 
    group_by(country) %>% 
    summarise(new_cases_variance = var(daily_new_cases)) %>% 
    mutate(rank = rank(-new_cases_variance)) %>% 
    filter(rank <= 5) %>% 
    arrange(rank)
high_variance_countries



## ---- fig.height=6, fig.width=10--------------------------------------------------------------------------

data <-
    daily_covid %>%
    filter(country %in% high_variance_countries$country) %>% 
    mutate(text = paste0("New Cases: ", comma(daily_new_cases), 
                         "\nCountry: ", country, "\nDate: ", date))

p1 <-
    ggplot(data, aes(date, daily_new_cases, group = country, color = country, text = text)) +
    geom_line() +
    scale_x_date(date_labels = "%b %Y") +
    scale_y_continuous(
        labels = unit_format(unit = "M", scale = 1e-6)
    ) +
    theme_ipsum() +
    scale_color_viridis(discrete = TRUE, begin = 0, end = 0.9, option = "H") +
    labs(color = "Country") +
    ylab("New Cases") +
    xlab("Date")

p2 <- ggplotly(p1, tooltip = "text")
saveWidget(p2, file = paste0(html_plot_path, "qb2_a.html"))

p2

rm(high_variance_countries, data, p1, p2)
invisible(gc())



## ---- warning=FALSE---------------------------------------------------------------------------------------

data_vac <- select(daily_vac, date, country, daily_vaccinations)

data <- daily_covid %>% 
    filter(country == "India")
    # mutate_at("country", str_replace, "UK", "England") %>% 
    # mutate_at("country", str_replace, "USA", "United States")

data_vac <- 
    left_join(data, data_vac, by = c("date", "country"))

p1 <- 
    ggplot(data_vac) +
    geom_line(aes(date, daily_new_cases), 
              color="#eb9e34", size=1, alpha=0.9, linetype=1) +
    # geom_line(aes(date, daily_vaccinations, group = country, text = text), na.rm = T) +
    scale_x_date(date_labels = "%b %Y") +
    scale_y_continuous(
        labels = unit_format(unit = "M", scale = 1e-6)
        # limits = c(0, 4 * 1e6), 
        # oob = squish
    ) +
    theme_ipsum() +
    scale_color_viridis(discrete = TRUE, begin = 0, end = 0.9, option = "H") +
    # labs(color = "Country") +
    ylab("New Cases") +
    xlab("Date") +
    theme(
        axis.title.x = element_text(size = 10),
        axis.title.y = element_text(size = 10),
        plot.margin = unit(c(.2,1,.4,1),"cm")
    )
# p1

p2 <- 
    ggplot(data_vac) +
    geom_line(aes(date, daily_vaccinations), 
              color="#4287f5", size=1, alpha=0.8, linetype=1) +
    scale_x_date(date_labels = "%b %Y") +
    scale_y_continuous(
        labels = unit_format(unit = "M", scale = 1e-6)
    ) +
    theme_ipsum() +
    scale_color_viridis(discrete = TRUE, begin = 0, end = 0.9, option = "H") +
    ylab("New Vaccinations") +
    xlab("Date") +
    ggtitle(label = "Daily New Cases & Vaccinations in India") +
    theme(
        plot.title = element_text(size = 12),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.title.y = element_text(size = 10),
        plot.margin = unit(c(.4,1,.2,1),"cm")
    )
# p2

p3 <- ggarrange(p2, p1, heights = c(0.4, 0.6))
ggsave(paste0(png_plot_path, "qb2_b.png"), plot = p3, width = 1920, height=1080 , units = "px")

rm(data_vac, data, p1, p2, p3)
invisible(gc())



## ---------------------------------------------------------------------------------------------------------

pacman::p_unload(all)


