# Create an sf Object from Point Locations

Accepts three coordinate input formats and returns an
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) POINT object
(EPSG:4326) with a `location` column for use in `extract_*()` functions.

## Usage

``` r
.create_sf(xy)
```

## Arguments

- xy:

  Point locations in one of three formats:

  - A named list, *e.g.,* `list("Corrigin" = c(x = 117.87, y = -32.33))`

  - A `data.frame` with columns `location`, `x` (longitude), and `y`
    (latitude)

  - An [sf::sf](https://r-spatial.github.io/sf/reference/sf.html) POINT
    object (with an optional `location` column; row names are used if
    the column is absent)

## Value

An [sf::sf](https://r-spatial.github.io/sf/reference/sf.html) POINT
object in EPSG:4326 with a `location` column.
