# Internal handler for Canopy Height (TERN/36c98155)

Reads OzTreeMap canopy height composite at 30 m resolution. Note: CRS is
EPSG:3577 (projected).

## Usage

``` r
.read_tern_canopy(dots, api_key, max_tries, initial_delay)
```

## Arguments

- dots:

  Named list (unused; provided for consistency).

- api_key, max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
