
### CUSTOM FUNCTIONS ###
# this file contains functions that I frequently use

# add comma to large number
commaNum <- function(num) {
    return(prettyNum(num, big.mark = ",", scientific = F))
}
