# Internal handler for Land Surface Phenology (TERN/2bb0c81a)

Reads MODIS-derived Start or End of Growing Season for 2003-2018.

## Usage

``` r
.read_tern_phenology(dots, api_key, max_tries, initial_delay)
```

## Arguments

- dots:

  Named list including `metric`, `year`, `season` if provided.

- api_key, max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
