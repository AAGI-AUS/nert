# Create an AET URL

Builds the full GDAL vsicurl URL for a given AET collection and month.

## Usage

``` r
.make_aet_url(.collection, .month, .api_key)
```

## Arguments

- .collection:

  The user-supplied AET collection being asked for (`"ETa"` or
  `"pixel_qa"`).

- .month:

  The validated `POSIXct` date snapped to the first of the month.

- .api_key:

  The URL-encoded API key.
