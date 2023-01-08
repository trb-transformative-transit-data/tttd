## load libraries ####
library(data.table) # fast data loading and manipulation
library(ggplot2)  # visualization

## import data ####
dat <- fread('workshop/exercise-1/exercise-1-APC-data.csv')

## first look & summarize data ####
scales::comma(nrow(dat)) # 1,387,869 rows of APC data
summary(dat) # check range of dates, distribution of ons and offs

dat[, .N, line_id] # how many routes included?
dat[, .N, .(line_id, line_direction)] # how many route-direction observations? 
dat[, .(trips = uniqueN(trip_id)), line_id] # how many unique trips per route?
dat[, uniqueN(stop_id)] #how many stops included? 
dat[, unique(TOD)] # what does the TOD variable contain?

dat[1:10, depart] # view a sample of the data - depart
 
## What are the dimensions of the data? ####


## What is the average weekday ridership by route? ####
# sum ons by date by route, for only weekday
rides_by_day <- dat[service_abbr == 'WK', .(daily_rides = sum(total_ons)), keyby = .(calendar_date, line_id)] # keyby gives an additional benefit of fast sorting by the aggregator columns... try using just 'by'

# then take the average across all the weekdays in the dataset
weekday_avg <- rides_by_day[, .(weekday_avg = mean(daily_rides)), line_id]
weekday_avg # print result
weekday_avg[, .(line_id, WK_avg = scales::comma(weekday_avg))] # round and format nicely



## what is the busiest stop in the dataset? ####
# decide: what does busiest mean? 
# assume: most total boardings

# create list of total boardings across all days by route, stop
stop_boards <- dat[, .(total_boardings = sum(total_ons)), .(stop_id, line_id)]

# sort by total boardings in dataset
stop_boards[order(-total_boardings)] # sorting by "-" means sort descending


## how does ridership correspond with peak times of day? ####
# take weekday average, by TOD, by line_id - similar to first aggregate but additional factor
rides_by_day_tod <- dat[service_abbr == 'WK', .(daily_rides = sum(total_ons)), keyby = .(calendar_date, line_id, TOD)] 

# summarize by taking median instead of mean to get better sense of regular activity
weekday_avg_tod <- rides_by_day_tod[, .(weekday_avg = mean(daily_rides)), .(line_id, TOD)]

# make a new variable to look at peak times only for ease of comparison
weekday_avg_tod[, peak := ifelse(TOD %in% c('AM Peak', 'PM Peak'), TRUE, FALSE)]
weekday_avg_tod[, sum(weekday_avg), peak]

## graph of ridership time series ####
# first aggregate to monthly average weekday boardings, using first aggregate
toplot <- rides_by_day[, .(avg_wkday = mean(daily_rides)), keyby = .(month(calendar_date), line_id)]

ggplot(toplot, aes(x = factor(month), y = avg_wkday, col = factor(line_id))) + 
  geom_path(aes(group = line_id)) +
  geom_point(alpha = 0.6) 
