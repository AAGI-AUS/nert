# Validate and prepare date and coordinate inputs

Validates and resolves the `dates`/`date_range` arguments and parses the
coordinate inputs into a `SpatVector` of points.

## Usage

``` r
.validate_and_prepare_inputs(dates, date_range, lon, lat, xy)
```

## Arguments

- dates:

  User-supplied exact dates (or missing).

- date_range:

  User-supplied date range (or missing).

- lon:

  Longitude(s).

- lat:

  Latitude(s).

- xy:

  Optional data.frame/matrix with coordinate columns.

## Value

A named list with elements `dates`, `n_dt`, `coords_df`, `n_loc`, and
`pts`.
