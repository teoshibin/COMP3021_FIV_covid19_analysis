# Get data:
library(gapminder)

# Charge libraries:
library(ggplot2)
library(gganimate)
library(gifski)

# Make a ggplot, but add frame=year: one image per year
p <- ggplot(gapminder, aes(gdpPercap, lifeExp, size = pop, colour = country)) +
    geom_point(alpha = 0.7, show.legend = FALSE) +
    scale_colour_manual(values = country_colors) +
    scale_size(range = c(2, 12)) +
    scale_x_log10() +
    facet_wrap(~continent) +
    # Here comes the gganimate specific bits
    labs(title = 'Year: {frame_time}', x = 'GDP per capita', y = 'life expectancy') +
    transition_time(year) +
    ease_aes('linear')

# Save at gif:
animate(p, start_pause = 10, end_pause = 10,renderer=gifski_renderer("test.gif"))


View(gapminder)
