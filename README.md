
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nert

<!-- badges: start -->

[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg)](https://app.codecov.io/gh/AAGI-AUS/nert)
<!-- badges: end -->

The goal of {nert} is to provide access to Australian TERN (Terrestrial
Ecosystem Research Network) data in your R session.

## Installation

You can install the development version of {nert} from
[GitHub](https://github.com/AAGI-AUS/nert) with:

``` r
if (!require("pak")) {
  install.packages("pak")
}

pak::pak("AAGI-AUS/nert")
```

## Example: reading a COG as a spatial object

This is a basic example which shows you how you can fetch one day’s data
from the SMIPS data (currently the only supported data set in TERN) and
visualise it:

``` r
library(nert)
#> 
#> Attaching package: 'nert'
#> The following object is masked from 'package:graphics':
#> 
#>     plot
#> The following object is masked from 'package:base':
#> 
#>     plot
r <- read_cog(day = "2024-01-01")

plot(r)
```

<img src="man/figures/README-example_cog-1.png" width="100%" />

## Example reading a COG as a data.table

This is a basic example which shows you how you can fetch one day’s data
from the SMIPS data as a data.table:

``` r
library(nert)
r <- read_cog_dt(day = "2024-01-01")

r
#>               lon       lat smips_totalbucket_mm_20240101
#>             <num>     <num>                         <num>
#>       1: 142.5328 -10.69951                      38.68500
#>       2: 142.5228 -10.70951                      43.40917
#>       3: 142.5328 -10.70951                      41.99442
#>       4: 142.4428 -10.71951                      38.94186
#>       5: 142.4928 -10.71951                      43.28778
#>      ---                                                 
#> 6873516: 146.8517 -43.62003                      40.96997
#> 6873517: 146.8617 -43.62003                      38.49732
#> 6873518: 146.8717 -43.62003                      48.08897
#> 6873519: 146.8517 -43.63003                      33.92958
#> 6873520: 146.8617 -43.63003                      32.85794
```
