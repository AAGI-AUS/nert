# Read Canopy Height Data (OzTreeMap)

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for Canopy Height Models from OzTreeMap (TERN/36c98155). Provides an
Australia-wide composite at 30 m resolution (static product).

**Important:** The coordinate reference system is `EPSG:3577`
(GDA94/Australian Albers, projected in metres). If you are extracting
values at point locations from geographic coordinates
(latitude/longitude), you must first reproject your points to EPSG:3577
using
[`terra::project()`](https://rspatial.github.io/terra/reference/project.html)
or
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html).

## Usage

``` r
read_canopy_height(api_key = NULL, max_tries = 3L, initial_delay = 1L)
```

## Arguments

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md)
  for setup.

- max_tries:

  An `integer` giving the maximum number of download retries before an
  error is raised. Defaults to `3`.

- initial_delay:

  An `integer` giving the initial retry delay in seconds (doubles with
  each attempt). Defaults to `1`.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object (single layer, EPSG:3577).

## References

TERN portal: <https://portal.tern.org.au/metadata/TERN/36c98155>

OzTreeMap: <https://www.tern.org.au/landscapes/>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read canopy height for all of Australia
r <- read_canopy_height()
plot(r)

# Extract at a location (Murray Bridge, SA) -- note: must reproject first
pt <- terra::vect(
  matrix(c(138.6, -34.9), ncol = 2),
  type = "points",
  crs = "EPSG:4326"  # geographic (lat/lon)
)
pt_proj <- terra::project(pt, "EPSG:3577")  # project to raster CRS
val <- terra::extract(r, pt_proj)
print(val)
}
```
