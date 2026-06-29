# Plan the list of COG fetches

A *work item* is one COG-shaped request: a tuple of
`(dataset, date_idx, variant, depth)`. Each item maps to exactly one
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md) +
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
round-trip and produces one or more columns in the output table.

## Usage

``` r
.build_work_items(
  datasets,
  dates,
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

- dates:

  Resolved `Date` vector.

- depth:

  SLGA depth selector.

- stat:

  SLGA stat selector.

- smips_collection:

  SMIPS collection selector.

- asc_collection:

  ASC collection selector.

- aet_collection:

  AET collection selector.

- soildiv_collection:

  SOILDIV collection selector.

- phenology_collection:

  PHENOLOGY collection selector.

## Value

A list of work-item lists.

## Details

For time-series datasets (SMIPS, AET) we emit one work item per (date,
variant); for PHENOLOGY datasets we emit two work items per (date,
variant), one for each season; for SLGA datasets we emit one work item
per (depth, variant) combination. For temporally-static datasets, the
item values are replicated across the date axis
(`date_idx = NA_integer_`).
