
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nert

<!-- badges: start -->

[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg)](https://app.codecov.io/gh/AAGI-AUS/nert)
<!-- badges: end -->

The goal of {nert} is to provide access to Australian TERN (Terrestrial
Ecosystem Research Network) data.

## Installation

You can install the development version of {nert} from
[GitHub](https://github.com/AAGI-AUS/nert) with:

``` r
if (!require("pak")) {
  install.packages("pak")
}
#> Loading required package: pak

pak::pak("AAGI-AUS/nert")
#> ℹ Loading metadata database
#> ✔ Loading metadata database ... done
#>  
#> ℹ No downloads are needed
#> ✔ 1 pkg + 8 deps: kept 8 [3.1s]
```

## Example

This is a basic example which shows you how you can fetch one day’s data
and visualise it:

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
r <- get_smips(day = "2024-01-01")

plot(r)
```

<img src="man/figures/README-example-1.png" width="100%" />
