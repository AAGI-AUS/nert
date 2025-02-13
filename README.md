<!-- README.md is generated from README.Rmd. Please edit that file -->



# nert

<!-- badges: start -->
[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg?token=WgBeTrqQnQ)](https://codecov.io/gh/AAGI-AUS/nert)
<!-- badges: end -->

The goal of {nert} is to provide access to Australian TERN (Terrestrial Ecosystem Research Network) data in your R session.

## Installation

You can install the development version of {nert} from [GitHub](https://github.com/AAGI-AUS/nert) with:


``` r
if (!require("pak")) {
  install.packages("pak")
}

pak::pak("AAGI-AUS/nert")
```

## Example: reading a COG as a spatial object

This is a basic example which shows you how you can fetch one day's data from the SMIPS data (currently the only supported data set in TERN) and visualise it:


``` r
library(nert)
r <- read_smips(day = "2024-01-01")

# `autoplot` is re-exported from {tidyterra}
autoplot(r)
```

![example plot](./man/figures/README-example_cog-1.png)

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
#>   _nert: An API Client for TERN Data_. R package version 0.0.0.9000,
#>   https://github.com/AAGI-AUS/nert, <https://aagi-aus.github.io/nert/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {nert: An API Client for TERN Data},
#>     author = {Adam H. Sparks and Wasin Pipattungsakul and Russell Edson and Sam Rogers and Max Moldovan},
#>     year = {2025},
#>     note = {R package version 0.0.0.9000, https://github.com/AAGI-AUS/nert},
#>     url = {https://aagi-aus.github.io/nert/},
#>   }
```
