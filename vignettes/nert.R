## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 7,
  fig.align = "center",
  fig.path = "vignettes/"
)


## ----get_key, eval = FALSE----------------------------------------------------
# library(nert)
# get_key()


## ----test-nert----------------------------------------------------------------
library(nert)
library(terra)

r <- read_smips(day = "2024-01-01")

extract(r, xy = TRUE, data.frame(lon = 138.6007, lat = -34.9285))


## ----keyring, eval=FALSE------------------------------------------------------
# install.packages("keyring")


## ----save-key, eval=FALSE-----------------------------------------------------
# library(keyring)
# 
# keyring_create("nert")
# 
# # add the key to your OS's credential store
# key_set("NERT_API_KEY", keyring = "nert")
# 
# # verify that the key was stored properly
# key_get("NERT_API_KEY", keyring = "nert")


## ----using-keyring, eval=FALSE------------------------------------------------
# library(nert)
# library(keyring)
# 
# r <- read_smips(
#   day = "2024-01-01",
#   api_key = key_get("NERT_API_KEY", keyring = "nert")
# )


## ----working-with-smips-------------------------------------------------------
library(nert)
r <- read_smips(day = "2024-01-01")


## ----test-plot, fig.cap = "A plot of SMIPS data for all of Australia on 2024-01-01."----
autoplot(r)


## ----points-------------------------------------------------------------------
library(terra)

extract(r, xy = TRUE, data.frame(lon = 138.6007, lat = -34.9285))

