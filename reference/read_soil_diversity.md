# Read Soil Beta Diversity (Bacteria and Fungi)

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for Soil Beta Diversity (TERN/4a428d52). Provides NMDS ordination axes
(1-3) derived from soil surveys for Bacteria and Fungi at 90 m
resolution (static product).

## Usage

``` r
read_soil_diversity(
  kingdom = "Bacteria",
  axis = 1,
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- kingdom:

  Organism kingdom. One of `"Bacteria"` (default) or `"Fungi"`. Use
  `"all"` to return all 6 axes stacked (Bacteria 1-3, then Fungi 1-3).

- axis:

  Ordination axis (default 1). Options: 1, 2, or 3. Use `"all"` to
  return all 3 axes for the specified kingdom stacked.

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
object. Single axis: one layer. When `kingdom = "all"`: 6-layer raster
with layers named `NMDS_Bacteria_1`, `NMDS_Bacteria_2`,
`NMDS_Bacteria_3`, `NMDS_Fungi_1`, `NMDS_Fungi_2`, `NMDS_Fungi_3`.

## References

TERN portal: <https://portal.tern.org.au/metadata/TERN/4a428d52>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md)

## Examples

``` r
if (FALSE) { # interactive()
# Bacteria NMDS axis 1 (default)
r_bacteria_1 <- read_soil_diversity()
autoplot(r_bacteria_1)

# Bacteria axis 3
r_bacteria_3 <- read_soil_diversity("Bacteria", axis = 3)

# Fungi axis 2
r_fungi_2 <- read_soil_diversity("Fungi", axis = 2)

# Bacteria all 3 axes stacked
r_bacteria_all <- read_soil_diversity("Bacteria", axis = "all")
names(r_bacteria_all)  # NMDS_Bacteria_1, NMDS_Bacteria_2, NMDS_Bacteria_3

# Fungi all axes
r_fungi_all <- read_soil_diversity("Fungi", axis = "all")

# All kingdoms (Bacteria 1-3 + Fungi 1-3) - 6 layers
r_all <- read_soil_diversity(kingdom = "all")
names(r_all)
}
```
