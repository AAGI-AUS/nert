<!-- README.md is generated from README.Rmd. Please edit that file -->



# nert

<!-- badges: start -->
[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
<<<<<<< HEAD
[![Codecov test coverage](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg)](https://app.codecov.io/gh/AAGI-AUS/nert)
=======
[![codecov](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg?token=WgBeTrqQnQ)](https://codecov.io/gh/AAGI-AUS/nert)
>>>>>>> f8be0c1 (add static results, update badge)
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
#> <SpatRaster> resampled to 501270 cells.
```

<<<<<<< HEAD
<div class="figure">
<img src="man/figures/README-example_cog-1.png" alt="plot of chunk example_cog" width="100%" />
<p class="caption">plot of chunk example_cog</p>
</div>
=======
<figure>
<img src="./man/figures/README-example_cog-1.png" alt="example plot" />
<figcaption aria-hidden="true">example plot</figcaption>
</figure>
>>>>>>> f8be0c1 (add static results, update badge)

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

<<<<<<< HEAD
## Citing {nert}

To cite nert:


``` r
citation("nert")
#> Warning in citation("nert"): could not determine year for 'nert' from package DESCRIPTION file
#> To cite package 'nert' in publications use:
#> 
#>   Sparks A, Pipattungsakul W, Edson R, Rogers S, Moldovan M (????). _nert: An API Client for TERN Data_. R package version 0.0.0.9000,
#>   https://github.com/AAGI-AUS/nert, <https://aagi-aus.github.io/nert/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {nert: An API Client for TERN Data},
#>     author = {Adam H. Sparks and Wasin Pipattungsakul and Russell Edson and Sam Rogers and Max Moldovan},
#>     note = {R package version 0.0.0.9000, https://github.com/AAGI-AUS/nert},
#>     url = {https://aagi-aus.github.io/nert/},
#>   }
=======
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
>>>>>>> 91b1468 (add development section)
```
