
# irec recreational catch -------------------------------------------------

# Path on Region\ (R:\) network drive
path <- list.files(
  path = "R:/iREC reporting program/",
  pattern = "^iREC estimates CALIBRATED.*\\.xlsx$",
  full.names = TRUE
)

s <- readxl::excel_sheets(path = path)
sheet <- s[2] # "calibrated iREC estimates"

d <- readxl::read_xlsx(
  path = path,
  sheet = sheet
) |>
  dplyr::rename_with(.fn = tolower) |>
  dplyr::filter(
    item %in% c("Dogfish"),
    area %in% c(paste("Area", 12:20),
                paste("Area", 28:29),
                paste("Area 19", c("(GS)", "(JDF)")),
                paste("Area 20", c("(East)", "(West)")),
                paste("Area 29", c("(Marine)")))
  ) |>
  dplyr::select(
    logistical_area,
    year,
    month,
    area,
    method,
    item,
    disposition,
    retainable,
    estimate,
    variance
  )

saveRDS(d, file = "data/raw/catch-recreational-irec.rds")


# CREEL recreational catch ------------------------------------------------

# Path on Salmon$ (S:\) network drive
p <- "S:/FMCR_Fishery_Monitoring_Catch_Reporting/Recreational_CM/Catch_Data"
f <- "SC Sport Catch (Master Do Not Edit).xlsx"
path <- file.path(p, f)
s <- readxl::excel_sheets(path = path) #check file path, nolonger working
sheet <- s[1] # "YTD"

d <- readxl::read_xlsx(
  path = path,
  sheet = sheet,
) |>
  dplyr::rename_with(.fn = tolower) |>
  dplyr::filter(
    species %in% c("NORTH PACIFIC SPINY DOGFISH"),
    pfma %in% c(
      paste("PFMA", 12:20),
      paste("PFMA", 28:29)
    )
  ) |>
  dplyr::select(
    pfma,
    year,
    month,
    disposition,
    species,
    species_code,
    scientific_name,
    estimate,
    standard_error,
    percent_standard_error
  )

saveRDS(d, file = "data/raw/catch-recreational-creel.rds")


# FSC catch ---------------------------------------------------------------
p <- "C:/Users/rogersl/data/fsc/"
f <- "LingcodDogfishGroundfishFSCforallyears_BasicEstimate_21-Feb-24.xlsx"
pf <- paste0(p, f)

d <- readxl::read_xlsx( #<- check path name, nolonger working
  path = pf,
  sheet = "Interview Data_LingcodDogfishGr"
) |>
  dplyr::rename_with(.fn = tolower) |>
  dplyr::filter(
    species %in% c("NORTH PACIFIC SPINY DOGFISH", "UNIDENTIFIED GROUNDFISH"),
    estimation_area %in% c(paste("PFMA", 12:20), paste("PFMA", 28:29))
  ) |>
  dplyr::mutate(
    pfma = estimation_area,
    year = lubridate::year(start_time),
    month = lubridate::month(start_time),
    catch = catch_count,
    units = tolower(units),
    comment = catch_data_comment
  ) |>
  dplyr::select(
    purpose,
    pfma,
    gear_type,
    year,
    month,
    disposition,
    species,
    catch,
    units,
    comment
  )

tibble::view(d)
saveRDS(d, file = "data/raw/catch-fsc.rds")

