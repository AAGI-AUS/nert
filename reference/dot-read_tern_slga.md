# Internal handler for SLGA soil attributes

Reads any of 8 SLGA attributes (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO)
at one or more depth intervals (or all 6).

## Usage

``` r
.read_tern_slga(collection, dots, api_key, max_tries, initial_delay)
```

## Arguments

- collection:

  SLGA attribute code (e.g. "AWC", "CLY").

- dots:

  Named list including `depth` and `stat` if provided.

- api_key, max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
