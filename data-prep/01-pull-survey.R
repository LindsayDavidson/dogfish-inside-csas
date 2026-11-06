# load survey data (sets and samples)

library(here)
library(gfdata)

sp <-
  "north pacific spiny dogfish"

x <- get_ssids()
# inside jig surveys?

ssid <- c(
  76, 92, 48, # dogfish circle and j hook and comp work
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
# unique(sog_miudwater_sets$year)

if (!file.exists("data-raw/inside-dogfish_2026.rds")) {
  # data_surveysets <- get_all_survey_sets(sp) #, ssid = ssid)
  data_surveysets <- get_survey_sets(species = sp, ssid = ssid)
  saveRDS(data_surveysets, "data/raw/dogfish-inside-sets_2026.rds")
}

if (!file.exists("data-raw/inside-dogfish_2026.rds")) {
  test <- get_all_survey_samples(species = sp, ssid = ssid) # , ssid = ssid)
  data_survey_samples <- get_survey_samples(species = sp, ssid = ssid)
  saveRDS(data_survey_samples, "data/raw/dogfish-inside-samples_2026.rds")
}

hookll <- gfdata::get_ll_hook_data(species = sp, ssid = c(39, 40)) |>
  dplyr::select(fishing_event_id, year, count_bait_only, count_empty_hooks,
                count_bent_broken, count_non_target_species, count_target_species)
saveRDS(hookll, "data/raw/HBLL_ins_hookinfo.rds")


