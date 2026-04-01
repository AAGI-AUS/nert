# Normalise a TERN dataset key for switch() dispatch

Checks alias table first (case-insensitive), then strips any `TERN/`,
`CSIRO/`, `AEKOS/`, or `NCI/` prefix and extracts the first 8 lower-case
characters of the UUID. Non-UUID identifiers (e.g.\\ `"AusEFlux_v2"`)
are returned as-is after prefix removal.

## Usage

``` r
.tern_dispatch_id(id)
```

## Arguments

- id:

  The raw `dataset_id` string supplied by the user.

## Value

A normalised `character` string for use in
[`switch()`](https://rdrr.io/r/base/switch.html).
