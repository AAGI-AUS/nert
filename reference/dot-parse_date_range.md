# Normalise a date_range argument

If a `Date` vector or `character` vector of length 2 is given, parses
into a contiguous range of dates. If a vector of length greater than 2
is given, this function does nothing (besides the date conversion).

## Usage

``` r
.parse_date_range(date_range)
```

## Arguments

- date_range:

  A `Date` vector or `character` vector containing the date range
  supplied by the user.

## Value

A `Date` vector.
