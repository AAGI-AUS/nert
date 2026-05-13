# Normalise coordinate input

Normalise coordinate input

## Usage

``` r
.parse_coordinates(lon, lat, xy)
```

## Arguments

- lon:

  Longitude(s).

- lat:

  Latitude(s).

- xy:

  Optional data.frame/matrix with lon/lat or x/y columns.

## Value

A 2-column `data.table` with columns `lon`, `lat`.
