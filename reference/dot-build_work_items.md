# Plan the list of COG fetches

A *work item* is one COG-shaped request: a tuple of
`(dataset, date_idx, variant, depth)`. Each item maps to exactly one
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md) +
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
round-trip and produces one or more columns in the output table.

## Usage

``` r
.build_work_items(datasets, dates, depth, stat, smips_collection)
```

## Arguments

- datasets:

  Normalised alias vector.

- dates:

  Resolved `Date` vector.

- depth:

  SLGA depth selector.

- stat:

  SLGA stat selector (`"EV"`, `"05"` or `"95"`).

- smips_collection:

  SMIPS collection selector.

## Value

A list of work-item lists.

## Details

For time-series datasets (SMIPS, AET) we emit one work item per (date,
variant); for SLGA `depth = "all"` we emit one work item per depth
interval; for static datasets we emit a single work item whose value is
replicated across the date axis (`date_idx = NA_integer_`).
