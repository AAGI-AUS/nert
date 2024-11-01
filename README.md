---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# nert

<!-- badges: start -->
[![R-CMD-check](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AAGI-AUS/nert/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/AAGI-AUS/nert/graph/badge.svg)](https://app.codecov.io/gh/AAGI-AUS/nert)
<!-- badges: end -->

The goal of {nert} is to provide access to Australian TERN (Terrestrial Ecosystem Research Network) data in your R session.

## Installation

You can install the development version of {nert} from [GitHub](https://github.com/AAGI-AUS/nert) with:


``` r
if (!require("pak")) {
  install.packages("pak")
}
#> Loading required package: pak

pak::pak("AAGI-AUS/nert")
#> 
#>  Found  1  deps for  0/1  pkgs [⠋] Resolving AAGI-AUS/nert Found  1  deps for  0/1  pkgs [⠙] Resolving AAGI-AUS/nert Found  1  deps for  0/1  pkgs [⠹] Resolving AAGI-AUS/nert Found  1  deps for  0/1  pkgs [⠸] Resolving AAGI-AUS/nert Found  1  deps for  0/1  pkgs [⠼] Resolving AAGI-AUS/nertℹ Loading metadata database                               ✔ Loading metadata database ... done
#>  Found  1  deps for  0/1  pkgs [⠼] Resolving AAGI-AUS/nert Found  7  deps for  1/1  pkgs [⠴] Checking installed packages Found  7  deps for  1/1  pkgs [⠦] Checking installed packages Found  7  deps for  1/1  pkgs [⠧] Resolving standard (CRAN/BioC) packages                                                                           
#> ℹ No downloads are needed
#> Installing...             ✔ 1 pkg + 8 deps: kept 8 [4.6s]
```

## Example

This is a basic example which shows you how you can fetch one day's data and visualise it:


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

<div class="figure">
<img src="man/figures/README-example-1.png" alt="plot of chunk example" width="100%" />
<p class="caption">plot of chunk example</p>
</div>
