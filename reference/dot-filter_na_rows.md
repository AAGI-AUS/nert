# Drop all-NA data rows from the output table

When `na.rm` is `TRUE` and data columns are present, removes rows where
every data column is `NA`.

## Usage

``` r
.filter_na_rows(out, data_cols, na.rm)
```

## Arguments

- out:

  A `data.table` containing the collected data.

- data_cols:

  A `character` vector of column names to check (excludes `date`, `lon`,
  `lat`).

- na.rm:

  Logical. If `TRUE`, drop all-NA rows.

## Value

A (possibly filtered) `data.table`.
