# Validate Days Requested Align With Collection

SMIPS daily COGs are published from 2015-11-20 (the earliest archived
national mosaic on the TERN portal) up to approximately seven days
before today. Requests outside that window return HTTP 404 from the GDAL
vsicurl driver, which surfaces as an opaque "file does not exist" error
from
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).
This helper catches that case before any network I/O.

## Usage

``` r
.check_collection_agreement(.collection, .day)
```

## Arguments

- .collection:

  The user-supplied SMIPS collection being asked for.

- .day:

  The user-supplied date being asked for.
