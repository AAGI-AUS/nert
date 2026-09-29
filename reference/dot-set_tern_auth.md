# Pass the TERN API key to GDAL

Sets the GDAL `GDAL_HTTP_USERPWD` option, which stays set for the rest
of the R session because terra reads raster values only when they are
used. Warns the first time it is set. When the key changes, TERN files
are no longer cached, so a read that failed with the old key is not
reused.

## Usage

``` r
.set_tern_auth(api_key)
```

## Arguments

- api_key:

  A `string` value containing a TERN API key.

## Value

`invisible(NULL)`. This function is called for its side effect.
