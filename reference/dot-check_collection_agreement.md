# Validate date requested aligns with SMIPS collection extent

SMIPS daily COGs are published from 2015-01-01 (the earliest archived
complete set of soil moisture GeoTIFFs available on the TERN Data
Portal), up to today. Requests outside that window will definitely
return HTTP 404 from the GDAL vsicurl driver, resulting in a "file does
not exist" error from
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).
This helper function catches this case before any network I/O. (Note:
the requested rasters may still be unavailable even if this check
passes, e.g., if the user has requested a very recent raster that has
not been added to the TERN server yet. This validation function simply
checks for the obviously impossible cases.)

## Usage

``` r
.check_collection_agreement(.collection, .day)
```

## Arguments

- .collection:

  The user-supplied SMIPS collection being asked for.

- .day:

  The user-supplied date being asked for.
