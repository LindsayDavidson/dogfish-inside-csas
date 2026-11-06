# load survey data (sets and samples)

library(here)
library(gfdata)

sp <-
  "north pacific spiny dogfish"

x <- get_ssids()
x
# inside jig surveys?

# Note
# SURVEY_SERIES_ID == 48) #comp work 2004, 2019, 2022, 2023
# SURVEY_SERIES_ID == 93) #circle hook dog surveys 2005 onwards (2005, 2008, 2011, 2014, 2019)
# SURVEY_SERIES_ID == 76) #all jhook and circle hook dog surveys 1986 onwards does not include 2004 (1986, 1989, 2005, 2008, 2011, 2014, 2019)
# SURVEY_SERIES_ID == 92) #j hook dog surveys 1986, 1989 only


ssid <- c(
  92, 48, 93, # dogfish circle and j hook and comp work
  39, 40, # HBLL inside
  # 95 # Strait of Georgia midwater salmon trawl
  45, # Strait of Georgia synoptic bottom trawl, only two year but could plot
  15 # Strait of Georgia Lingcod Young-of-year Bottom Trawl, 4 years but spans the 90's so worth looking at
  # 13 # Inside Hard Bottom Longline Hook
)

# sog_hbhook <- get_survey_sets( # inside hard bottom longline hook? what is this
#   species = sp,
#   ssid = 13,
#   join_sample_ids = TRUE,
#   verbose = TRUE,
#   sleep = 0
# )
# unique(sog_hbhook$year) #not supported

sog_trawl_sets <- get_survey_sets( # pull SOG  trawl survey
  species = sp,
  ssid = 45,
  join_sample_ids = TRUE,
  verbose = TRUE,
  sleep = 0
)
unique(sog_trawl_sets$year) # two years

sog_lingcod_sets <- get_survey_sets( # ssid = 15 lingcod trawl
  species = sp,
  ssid = 15,
  join_sample_ids = TRUE,
  verbose = TRUE,
  sleep = 0
)
unique(sog_lingcod_sets$year) # ran four years

# 95 SOG mid water trawl
# sog_midwater_sets <- get_survey_sets( #not supported, Chris Nevilles data?I have it but it has a lot of preferential sampling...
#   species = spp,
#   ssid = 95,
#   join_sample_ids = TRUE,
#   verbose = TRUE,
#   sleep = 0
# )
# unique(sog_midwater_sets$year)

if (!file.exists("data/raw/inside-dogfish_2026.rds")) {
  data_surveysets <- get_survey_sets(species = sp, ssid = ssid)
  saveRDS(data_surveysets, "data/raw/dogfish-inside-sets_2026.rds")
}

if (!file.exists("data/raw/inside-dogfish_2026.rds")) {
  # data_survey_samples <- get_survey_samples(species = sp, ssid = ssid) #doesn't pull comp. work
  data_survey_samples <- get_all_survey_samples("north pacific spiny dogfish", ssid = ssid, include_event_info = TRUE)
  saveRDS(data_survey_samples, "data/raw/dogfish-inside-samples_2026.rds")
}


# distinguish J hook comp work, HBLL comp work, and Dogfish circle comp work...
jhookcomp <- data_survey_samples %>%
  filter(hook_desc == "J-HOOK" & year %in% c(2004, 2023, 2024)) %>%
  pull(fishing_event_id)

circlehookcomp <- data_survey_samples %>%
  filter(hook_desc == "CIRCLE HOOK" & hooksize_desc == "14/0" & year %in% c(2004, 2023)) |>
  filter(sample_date < "2023-08-11" | sample_date > "2023-09-06")
  pull(fishing_event_id) #id just the dogfish timing ones, not the hbll timing ones

hbllhookcomp <- data_survey_samples %>%
  filter(hook_desc == "CIRCLE HOOK" & hooksize_desc == "13/0" & activity_desc == "DOGFISH GEAR/TIMING COMPARISON SURVEYS" & year %in% c(2019, 2022, 2023)) |>
  filter(sample_date <= "2023-09-06") |>
  pull(fishing_event_id) #these are the HBLL/dogfish comp work completed during the HBLL survey timing

samps <- filter(samps, !fishing_event_id %in% id_remove) %>%
  arrange(year, fishing_event_id, survey_abbrev)


# pull empty hook data
hookll <- gfdata::get_ll_hook_data(species = sp, ssid = c(39, 40)) |>
  dplyr::select(
    fishing_event_id, year, count_bait_only, count_empty_hooks,
    count_bent_broken, count_non_target_species, count_target_species
  )
saveRDS(hookll, "data/raw/HBLL_ins_hookinfo.rds")


hook_dog_ll <- gfdata::get_ll_hook_data(species = sp, ssid = c(92, 48, 93)) |>
  dplyr::select(
    fishing_event_id, year, count_bait_only, count_empty_hooks,
    count_bent_broken, count_non_target_species, count_target_species
  )
sort(unique(hook_dog_ll$year)) # only 2019 dog and dogfish comp work includes counts of empty hooks
saveRDS(hook_dog_ll, "data/raw/SoGdog_ins_hookinfo.rds")
