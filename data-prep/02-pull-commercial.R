### Pull commercial data
library(gfdata)
library(tidyverse)

sp <- c("north pacific spiny dogfish")

commercial_samples <- get_commercial_samples(
  sp,
  unsorted_only = FALSE,
  return_all_lengths = FALSE
)

# privacy (and extra) removals:
commercial_samples$vessel_id <- NULL
commercial_samples$dna_sample_type <- NULL
commercial_samples$dna_container_id <- NULL
saveRDS(commercial_samples, "data/raw/dogfish-inside-commercial-samples.rds")

catch <- get_catch(sp)
saveRDS(catch, "data/raw/dogfish-inside-catch-2026-11-06.rds")

# get commercial samples
comm_samples <- gfdata::get_commercial_samples(
  species = sp
  # years = year_range,
  # tidy = TRUE
)
glimpse(comm_samples)
saveRDS(comm_samples, "data/raw/samples_comm_trawl_inside_dogfish.rds")


ll <- gfdata::get_cpue_index(gear = "longline")
ll <- ll |>
  mutate(best_date2 = as.Date(best_date, format = "%Y/%m/%d hh:mm:ss")) |>
  mutate(year = year(best_date2))

numevents <- ll |>
  distinct(trip_id, fishing_event_id) |>
  n_distinct() # this is the total number of events

ll <- ll |> mutate(total.num.trips = numevents)

saveRDS(ll, "data/raw/data_longline_trawl_inside_dogfish.rds") # this saves encounters but not all fishing events?
ll <- readRDS("data/raw/data_longline_trawl_inside_dogfish.rds")

df <- gfdata::get_cpue_index(gear = "bottom trawl")
saveRDS(df, "data/raw/data_commercial_bottom_trawl")
unique(df$species_common_name)
df2 <- filter(df, species_common_name == "NORTH PACIFIC SPINY DOGFISH")
# tr2 <- df[str_detect(df$species_common_name, regex(pattern, ignore_case = TRUE)), ]
tr2 <- df2 |>
  mutate(best_date2 = as.Date(best_date, format = "%Y/%m/%d hh:mm:ss")) |>
  mutate(year = year(best_date2))
numevents <- tr2 |>
  distinct(trip_id, fishing_event_id) |>
  n_distinct()
tr <- tr2 |> mutate(total.num.trips = numevents)
tr <- tr |> filter(is.na(year) != TRUE)
tr$fishing_event_id_unique <- paste0(tr$vessel_registration_number, "-", tr$trip_id, "-", tr$fishing_event_id)
# tr <- tr |> dplyr::mutate(best_date = as.POSIXct(best_date))


# calculate hours fished
tr <- tr |>
  mutate(hours_fished = as.numeric(difftime(fe_end_date, fe_start_date, units = "hours")))
glimpse(tr)
range(tr$hours_fished, na.rm = TRUE) # calculate hours fished from get_cpue_index for effort data
tr <- filter(tr, hours_fished < 2000) # this was the cutoff in dogfish assess
saveRDS(tr, "data/raw/data_comm_trawl_sharks_rays.rds") # this saves encounters but not all fishing events?

tr <- readRDS("data/raw/data_comm_trawl_sharks_rays.rds")
