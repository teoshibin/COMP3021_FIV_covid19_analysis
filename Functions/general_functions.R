
### CUSTOM FUNCTIONS ###
# this file contains functions that I frequently use

# add comma to large number
# commaNum <- function(num) {
#     return(prettyNum(num, big.mark = ",", scientific = F))
# }

myShrinkNum <- function(num){
    if (num >= 1e9) {
        return(patse(round(num/1e9, 2), "B"))
    }
    if (num >= 1e6) {
        return(paste(round(num/1e6, 2), "M"))
    }
    if (num >= 1e3) {
        return(paste(round(num/1e3, 2), "K"))
    }
    return(paste0(num))
}
