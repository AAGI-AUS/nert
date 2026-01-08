# Validate Days Requested Align With Collection

Not all dates are offered by all collections. This checks the user
inputs to be sure that unavailable dates are not requested from
collections that do not provide them.

## Usage

``` r
.check_collection_agreement(.collection, .day)
```

## Arguments

- .collection:

  The user-supplied SMIPS collection being asked for.

- .day:

  The user-supplied date being asked for.
