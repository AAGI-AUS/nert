# Validate date requested aligns with SMIPS collection extent

SMIPS daily COGs are published up to today, with a per-collection
earliest date on the TERN Data Portal: `"totalbucket"` and `"SMindex"`
are archived from 2005-01-01, while `"bucket1"`, `"bucket2"`, `"deepD"`,
and `"runoff"` are available from 2015-01-01. Requests outside the
collection's window will return HTTP 404 from the GDAL vsicurl driver,
resulting in a "file does not exist" error from
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).
This helper catches that case before any network I/O. (Note: the
requested raster may still be unavailable even if this check passes,
e.g., a very recent raster not yet added to the TERN server. This
function only rejects the obviously impossible cases.)

## Usage

``` r
.check_collection_agreement(.collection, .day)
```

## Arguments

- .collection:

  The user-supplied SMIPS collection being asked for.

- .day:

  The user-supplied date being asked for.
