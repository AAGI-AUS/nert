# Resolve the 'smips_collection' argument to a clean vector

Resolve the 'smips_collection' argument to a clean vector

## Usage

``` r
.normalise_smips_collection(smips_collection)
```

## Arguments

- smips_collection:

  User-supplied vector of SMIPS datasets to collect (or `NULL`/`"all"`).

## Value

A `character` vector of valid SMIPS datasets (de-duplicated, order
preserved).
