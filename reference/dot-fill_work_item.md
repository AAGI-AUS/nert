# Fetch one work item and write its values into the output table by reference.

For a time-series work item, exactly one row block (`length(coords)`
rows) is filled. For a static work item, the value is replicated across
every date. Failures leave the predeclared `NA` values untouched and
surface as a
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html) with
the underlying error.

## Usage

``` r
.fill_work_item(out, wi, pts, n_dt, n_loc, api_key)
```

## Arguments

- out:

  The output `data.table` (modified in place).

- wi:

  A work item from
  [`.build_work_items()`](https://aagi-aus.github.io/nert/reference/dot-build_work_items.md).

- pts:

  A `SpatVector` of points.

- n_dt:

  Number of dates.

- n_loc:

  Number of locations.

- api_key:

  TERN API key.
