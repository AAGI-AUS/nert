# Print the user-facing datasets-table summarising what will be fetched.

Print the user-facing datasets-table summarising what will be fetched.

## Usage

``` r
.print_datasets_table(
  datasets,
  depth,
  stat,
  smips_collection,
  asc_collection,
  aet_collection,
  soildiv_collection,
  phenology_collection
)
```

## Arguments

- datasets:

  Normalised alias vector.

- depth:

  Normalised SLGA depth selector.

- stat:

  Normalised SLGA statistic selector.

- smips_collection:

  Normalised SMIPS collection selector.

- asc_collection:

  Normalised ASC collection selector.

- aet_collection:

  Normalised AET collection selector.

- soildiv_collection:

  Normalised SOILDIV collection selector.

- phenology_collection:

  Normalised PHENOLOGY collection selector.

## Value

`invisible(NULL)`. This function is called for its side effects.
