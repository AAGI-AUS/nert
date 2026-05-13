# Read a COG from TERN

Read a COG from TERN

## Usage

``` r
.read_cog(full_url, max_tries = NULL, initial_delay = NULL)
```

## Arguments

- full_url:

  The URL providing access to the requested data.

- max_tries:

  Maximum number of download attempts before erroring. When `NULL`
  (default), resolved at call time from
  `getOption("nert.max_tries", 3L)`. Pass an integer to override for a
  single call.

- initial_delay:

  Initial retry delay in seconds (doubles each attempt). When `NULL`
  (default), resolved at call time from
  `getOption("nert.initial_delay", 1L)`. Pass an integer to override for
  a single call.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the requested data.
