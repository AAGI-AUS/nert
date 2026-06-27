# Validate phenology arguments before the API key is checked

Phenology requires an integer `year` in 2003–2018. The `season` and
`collection` arguments are optional and validated downstream in the
handler. Invoked by
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
via the
[.tern_datasets](https://aagi-aus.github.io/nert/reference/dot-tern_datasets.md)
registry.

## Usage

``` r
.validate_phenology(dots, dataset_id)
```

## Arguments

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- dataset_id:

  Raw `dataset_id` (unused; uniform validator signature).
