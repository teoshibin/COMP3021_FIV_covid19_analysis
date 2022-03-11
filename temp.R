data <-
    daily_covid %>%
    filter(country %in% high_variance_countries$country) %>% 
    mutate(text = paste0("New Cases: ", comma(daily_new_cases), 
                         "\nCountry: ", country, "\nDate: ", date))
# View(data)
p <-
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

p <- 
    ggplotly(p, tooltip = "text")

p
