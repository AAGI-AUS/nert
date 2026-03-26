# Build a GDAL vsicurl URL for an AET Collection

Build a GDAL vsicurl URL for an AET Collection

## Usage

``` r
.make_aet_url(.collection, .month, .api_key)
```

## Arguments

- .collection:

  The user-supplied AET collection (`"ETa"` or `"pixel_qa"`).

- .month:

  The validated `POSIXct` date snapped to the first of the month.

- .api_key:

  The URL-encoded API key.

## Value

A `character` GDAL vsicurl URL string.
