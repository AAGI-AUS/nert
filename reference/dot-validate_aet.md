# Validate AET arguments before the API key is checked

AET requires a monthly `date` (the legacy `month` name is also accepted)
within the data-availability window (from 1987-05-01). Invoked by
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
via the
[.tern_datasets](https://aagi-aus.github.io/nert/reference/dot-tern_datasets.md)
registry.

## Usage

``` r
.validate_aet(dots, dataset_id)
```

## Arguments

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- dataset_id:

  Raw `dataset_id` (unused; uniform validator signature).

## Value

`NULL` (invisibly); called for its side effects (errors).
