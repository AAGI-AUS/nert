# Pre-initialise output columns for all work items

Adds one `NA`-filled column per work item to the output `data.table`,
using the correct storage type (`NA_character_` or `NA_real_`) for each.
The table is modified in place.

## Usage

``` r
.initialize_output_columns(out, work_items)
```

## Arguments

- out:

  The output `data.table` (modified in place).

- work_items:

  A list of work items from
  [`.build_work_items()`](https://aagi-aus.github.io/nert/reference/dot-build_work_items.md).

## Value

`invisible(NULL)`. Called for its side effects.
