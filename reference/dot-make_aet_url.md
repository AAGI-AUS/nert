# Build a GDAL vsicurl URL to retrieve AET data

Build a GDAL vsicurl URL to retrieve AET data

## Usage

``` r
.make_aet_url(.collection, .month)
```

## Arguments

- .collection:

  The user-supplied AET collection (`"ETa"` or `"pixel_qa"`).

- .month:

  The validated `POSIXct` date snapped to the first of the month.

## Value

A `character` GDAL vsicurl URL string.
