# Check User Input Months for AET Validity

Validates and snaps a user-supplied date value to the first of the
month, then checks it against the AET data availability window (from
2000-02-01 onwards).

## Usage

``` r
.check_aet_date(x)
```

## Arguments

- x:

  User-entered date value (any format accepted by
  [`.check_date()`](https://aagi-aus.github.io/nert/reference/dot-check_date.md)).

## Value

A `POSIXct` object snapped to the first of the requested month.
