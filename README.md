---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# nert

<!-- badges: start -->
[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg?token=WgBeTrqQnQ)](https://codecov.io/gh/AAGI-AUS/nert)
<!-- badges: end -->

The goal of {nert} is to provide access to Australian TERN (Terrestrial Ecosystem Research Network) data in your R session.

## Installation instructions

{nert} is available through the [R-Universe](https://r-universe.dev/search) with pre-built binaries (this is the easy way).

To get started:

### Enable this universe

```r
options(repos = c(
    aagi_aus = "https://aagi-aus.r-universe.dev",
    CRAN = "https://cloud.r-project.org"))
```

### Install

```r
install.packages("nert")
```

### The hard(er) way

Note that for Linux users, you will need to install system libraries to support geospatial packages in R, _e.g._, {sf} and {terra} as well as some packages for downloading data via [curl](https://curl.se/download.html), please see [Note for Linux Installers](#Note-for-Linux-Installers).
If you run into errors, _e.g._, `Bad GitHub Credentials`, please read this: [Managing Git(Hub) Credentials](https://usethis.r-lib.org/articles/git-credentials.html) and set up your GitHub credentials in R and try again.

You can install the development version of {nert} from [GitHub](https://github.com/AAGI-AUS/nert) with:


``` r
o <- options() # store original options

options(pkg.build_vignettes = TRUE)

if (!require("pak")) {
  install.packages("pak")
}

pak::pak("AAGI-AUS/nert")
options(o) # reset options
```

## Example: reading a COG as a spatial object

This is a basic example which shows you how you can fetch one day's data from the SMIPS data and visualise it:


``` r
library(nert)
r <- read_smips(day = "2024-01-01")

# `autoplot` is re-exported from {tidyterra}
autoplot(r)
#> <SpatRaster> resampled to 501270 cells.
```

<img src="man/figures/README-example_cog-1.png" width="100%" />

## Extract Values Given Lat/Lon Values

Extract Soil Moisture for Corrigin and Merriden, WA and Tamworth, NSW given latitude and longitude values for each.


``` r
library(terra)
df <- structure(
  list(
    location = c("Corrigin", "Merredin", "Tamworth"),
    x = c(117.87, 118.28, 150.84),
    y = c(-32.33, -31.48, -31.07)
  ),
  row.names = c(NA, -3L),
  class = "data.frame"
)

cog_df <- extract(x = r, y = df[, c("x", "y")], xy = TRUE)

cog_df <- cbind(df$location, cog_df)
names(cog_df) <- c("location", "ID", "smips_totalbucket_mm_20240101", "x", "y")
cog_df
#>   location ID smips_totalbucket_mm_20240101        x         y
#> 1 Corrigin  1                    0.06715473 117.8688 -32.33328
#> 2 Merredin  2                    0.22716530 118.2787 -31.48353
#> 3 Tamworth  3                   93.44989014 150.8408 -31.07365
```

## Keeping {nert} Updated 

{nert} is undergoing active development and is not yet on CRAN.
If you installed {nert} using the R-Universe (the preferred method), you can keep {nert} up-to-date locally like so:


``` r
update.packages()
```

and answering `yes` or `y` when asked if you would like to upgrade {nert}.

## Note for Linux Installers

If you are using Linux, you will likely need to install several system-level libraries, {pak} will do it's best to install most of them but some may not be installable this way.
For [Nectar](https://ardc.edu.au/services/ardc-nectar-research-cloud/) with a fresh Ubuntu image, you can use the following command to install system libraries to install {pak} and then install {fifo}.
In your Linux terminal (not your R console, the "terminal" tab in RStudio should do here in most cases) type:

```bash
sudo apt update && sudo apt install libcurl4-openssl-dev libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev libudunits2-dev libxml2-dev
```

## Development

### Dev Container

Set up the container.


``` bash
devcontainer up --workspace-folder .
```

Run tests and check stuff.


``` bash
devcontainer exec --workspace-folder . R -e "devtools::check()"
```

Render this file.


``` bash
devcontainer exec --workspace-folder . R -e "devtools::build_readme()"
```

## Citing {nert}

To cite nert:


``` r
citation("nert")
#> To cite package 'nert' in publications use:
#> 
#>   Sparks A, Pipattungsakul W, Edson R, Rogers S, Moldovan M (2025).
#>   _nert: An API Client for TERN Data_. R package version 0.0.1.9000,
#>   commit 39ab8b7f2f03152ea3702f3089f095b9adebb9ee,
#>   <https://github.com/AAGI-AUS/nert>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {nert: An API Client for TERN Data},
#>     author = {Adam H. Sparks and Wasin Pipattungsakul and Russell Edson and Sam Rogers and Max Moldovan},
#>     year = {2025},
#>     note = {R package version 0.0.1.9000, commit 39ab8b7f2f03152ea3702f3089f095b9adebb9ee},
#>     url = {https://github.com/AAGI-AUS/nert},
#>   }
```
