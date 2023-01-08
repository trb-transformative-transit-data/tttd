## load libraries ####
library(data.table) # fast data loading and manipulation
library(ggplot2)  # visualization

## import data: afc data ####
afc <- fread('workshop/exercise-3/exercise-3-AFC-data.csv')
scales::comma(nrow(afc))

summary(afc) # one single hour on Sept 12, 2019

afc # simple table, but in "long" form with events in each row
setkeyv(afc, 'TRANSACTION_DTM')
# simplifying assumption, take origin as first in time, and destination as last per card
afc_OD <- afc[, .(orig = first(FACID), dest = last(FACID)), .(cardID)] 

## what is the busiest path segment during the 8AM hour? ####
afc_OD[, .N, .(orig, dest)][order(-N)][orig != dest] # tally by O-D combo, then sort descending, then filter out origin same as destination

## what is the most frequent destination from origin station 3099? ####
afc_OD[, .N, .(orig, dest)][order(-N)][orig == 3099]

# for a O-D matrix like form:
ODmat <- dcast(afc_OD, formula = orig ~ dest, value.var = 'cardID')


## visualization of passenger flows ####
to_sankey <- afc_OD[, .N, .(orig, dest)][order(-N)][orig != dest][1:22] # take a subset

## referencing https://plotly.com/r/sankey-diagram/
library(plotly)

fig <- plot_ly(
  
  type = "sankey",
  
  orientation = "h",
  
  node = list(
    
    label = as.character(to_sankey$orig),
    
    color = c(""),
    
    pad = 15,
    
    thickness = 20,
    
    line = list(
      
      color = 'black',
      
      width = 0.5
      
    )
    
  ),
  
  
  link = list(
    
    source = to_sankey$orig,
    
    target = to_sankey$dest,
    
    value =  to_sankey$N,
    
    label = paste0(to_sankey$orig, ' -> ', to_sankey$dest)
    
  )
  
)

fig <- fig %>% layout(
  
  title = "Basic Sankey Diagram",
  
  font = list(
    
    size = 10
    
  )
  
)


fig