## ----include = FALSE-----------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 7,
  fig.align = "center",
  fig.path = "vignettes/"
)


## ----get_key, eval = FALSE-----------
# library(nert)
# get_key()


## ----test-nert-----------------------
library(nert)
library(terra)

r <- read_smips(day = "2024-01-01")

extract(r, xy = TRUE, data.frame(lon = 138.6007, lat = -34.9285))


## ----keyring, eval=FALSE-------------
# install.packages("keyring")


## ----save-key, eval=FALSE------------
# library(keyring)
# 
# keyring_create("nert")
# 
# # add the key to your OS's credential store
# key_set("NERT_API_KEY", keyring = "nert")
# 
# # verify that the key was stored properly
# key_get("NERT_API_KEY", keyring = "nert")


## ----using-keyring, eval=FALSE-------
# library(nert)
# library(keyring)
# 
# r <- read_smips(
#   day = "2024-01-01",
#   api_key = key_get("NERT_API_KEY", keyring = "nert")
# )


## ----working-with-smips--------------
library(nert)
r <- read_smips(day = "2024-01-01")


## ----test-plot, fig.cap = "A plot of SMIPS data for all of Australia on 2024-01-01."----
autoplot(r)


## ----points--------------------------
library(terra)

extract(r, xy = TRUE, data.frame(lon = 138.6007, lat = -34.9285))


## ----asc, fig.cap = "A plot of Australian Soils Classification data."----
asc <- read_asc()

autoplot(asc)


## ----asc_ci--------------------------
asc_ci <- read_asc(confusion_index = TRUE)


## ----example_aet, fig.cap = "A plot of AET data for Australia in January 2024."----
library(nert)
r_aet <- read_aet(year = 2024, month = 1)

# Visualize the AET data
library(tidyterra)
autoplot(r_aet)


## ----aet_different_month-------------
# Get July 2024 data
r_aet_july <- read_aet(year = 2024, month = 7)

# Get data from a different year
r_aet_2020 <- read_aet(year = 2020, month = 1)


## ----aet_qa--------------------------
r_aet_qa <- read_aet(year = 2024, month = 1, qa = TRUE)

# This shows the quality flags for each pixel
autoplot(r_aet_qa)


## ----extract_aet, eval=TRUE----------
library(terra)

# Define locations
locations <- data.frame(
  site = c("Adelaide", "Melbourne", "Sydney"),
  lon = c(139.0, 144.96, 151.21),
  lat = c(-34.93, -37.81, -33.87)
)

# Extract AET values
r_aet <- read_aet(year = 2024, month = 1)
aet_values <- extract(r_aet, locations[, c("lon", "lat")])

# Combine with location names
results <- cbind(locations, AET_mm = aet_values[, 2])
print(results)

