## load libraries ####
library(data.table) # fast data loading and manipulation
library(ggplot2)  # visualization

## import data: avl and schedule ####
avl <- fread('workshop/exercise-2/exercise-2-AVL-data.csv')
gtfs <- fread('workshop/exercise-2/exercise-2-GTFS-data.csv')

## first look & summarize data ####
scales::comma(nrow(avl)) # 275,626 rows of AVL data 
summary(avl) # check range of Date - one day of bus operations!

avl[, .N, line_id] # how many routes included?
avl[, .(trips = uniqueN(trip_id)), line_id] # how many unique trips per route?
avl[, uniqueN(stop_id)] #how many stops included? 

# histograms can help view data intuitively sometimes to see what they are
avl[, hist(door_open)] # hint: how many seconds in a day?


## What are the columns of the data that might allow joining? ####
names(avl)
names(gtfs)

# could get lucky if your source uses common definitions
names(avl)[names(avl) %in% names(gtfs)]

# but dangerous to trust...
setdiff(avl$trip_id, gtfs$trip_id) # return which trips are in the AVL but NOT the gtfs

# because the names match but not the contents
avl[1:10, trip_id]
gtfs[1:10, trip_id]

## create a new trip_id to match
gtfs[, trip_id_short := as.integer(tstrsplit(trip_id, '-')[[1]])] # tstrplit = Split String by character indicated; creates list of values like "22845888, DEC22, MVS, BUS, Weekday, 01" and we want element 1 so: [[1]], whole thing wrapped in as.integer() to match avl file


setdiff(avl$stop_id, gtfs$stop_id) # lots of non-scheduled stops! 

## Join datasets on common fields #### 
dat_both <- avl[gtfs, on = .(trip_id = trip_id_short, stop_id)] # left join to schedule

## how many scheduled trips have at least one missing AVL record? ####
dat_both[, .N, is.na(depart)] # total relative number of observed and missing
dat_both[is.na(depart), uniqueN(i.trip_id)] # number of trips with one or more missing
dat_both[, uniqueN(i.trip_id)] # total number of trips in dataset

## what is the average adherence (scheduled time - actual time) for the day? ####
names(dat_both)[grep('depart', names(dat_both))] # one from avl, one from gtfs...
# use ITime from data.table
dat_both[, sched_time := as.ITime(departure_time)]
dat_both[, actual_time := as.ITime(depart)]
dat_both[, adherence := sched_time - actual_time]

# take raw average adherence
dat_both[, .(avg_adherence_sec = mean(as.numeric(adherence), na.rm = TRUE))] # have to remove the NA values

## specify a standard for being on time #### 
## Metro Transit: on time is between 1 minute early and 5 minutes late
dat_both[, on_time := ifelse(adherence %between% c(-5*60, 1*60), TRUE, FALSE)] # min x 60, negative is late

# what % of stop visits are on time
dat_both[, .N, on_time][, .(on_time, count = N, pct = scales::percent(N/sum(N)))]

## design a map view of these data #### 
library(leaflet) # very useful javascript baby GIS library

# aggregate to stops which can be mapped 
tomap <- dat_both[, .(OTP = sum(on_time, na.rm = TRUE)/.N), keyby = .(stop_id, stop_lat, stop_lon)]

leaflet(tomap) %>% 
  addTiles() %>% 
  addCircleMarkers(lng = ~stop_lon, lat = ~stop_lat, radius = ~7*OTP, popup = ~paste0('site_id: ', stop_id, 
  '<br>OTP: ', scales::percent(OTP)))
