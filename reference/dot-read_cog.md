# Read a COG from TERN

Read a COG from TERN

## Usage

``` r
.read_cog(full_url, max_tries, initial_delay)
```

## Arguments

- full_url:

  The URL providing access to the requested data.

- max_tries:

  The number of times to retry downloading before timing out.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the requested data.
