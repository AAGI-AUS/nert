# Validate SMIPS arguments before the API key is checked

SMIPS requires a daily `date` (the legacy `day` name is also accepted).
Invoked by
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
via the
[.tern_datasets](https://aagi-aus.github.io/nert/reference/dot-tern_datasets.md)
registry.

## Usage

``` r
.validate_smips(dots, dataset_id)
```

## Arguments

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- dataset_id:

  Raw `dataset_id` (unused; uniform validator signature).

## Value

`NULL` (invisibly); called for its side effects (errors).
