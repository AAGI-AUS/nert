# Resolve the 'phenology_collection' argument to a clean vector

Resolve the 'phenology_collection' argument to a clean vector

## Usage

``` r
.normalise_phen_collection(phenology_collection)
```

## Arguments

- phenology_collection:

  User-supplied vector of PHENOLOGY datasets to collect (or
  `NULL`/`"all"`).

## Value

A `character` vector of valid PHENOLOGY datasets (de-duplicated, order
preserved).
