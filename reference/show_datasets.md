# Show the Available TERN Datasets

Returns one row for each dataset that
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
and
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
can read.

## Usage

``` r
show_datasets()
```

## Value

A `data.frame` with columns `alias` (the short name to pass as
`dataset_id` or in `datasets`), `id` (the TERN dataset ID), `temporal`
(how often the data are published), `resolution` and `description`.

## Examples

``` r
show_datasets()
#>        alias            id temporal resolution
#> 1      SMIPS TERN/d1995ee8    Daily       1 km
#> 2        ASC TERN/15728dba   Static       90 m
#> 3        AET TERN/9fefa68b  Monthly       30 m
#> 4    SOILDIV TERN/4a428d52   Static       90 m
#> 5     CANOPY TERN/36c98155   Static       30 m
#> 6  PHENOLOGY TERN/2bb0c81a   Annual      500 m
#> 7        AWC TERN/482301c2   Static       90 m
#> 8        CLY TERN/f95dc442   Static       90 m
#> 9        SND TERN/4224ddff   Static       90 m
#> 10       SLT TERN/11375f04   Static       90 m
#> 11       BDW TERN/95978aec   Static       90 m
#> 12       PHC TERN/258afc98   Static       90 m
#> 13       PHW TERN/c37439a5   Static       90 m
#> 14       NTO TERN/e9484508   Static       90 m
#> 15       AVP TERN/c6ef289b   Static       90 m
#> 16       PTO TERN/be382e63   Static       90 m
#> 17       CEC TERN/5b4b2991   Static       90 m
#> 18       ECE TERN/0d27cf8b   Static       90 m
#> 19       DUL TERN/de9ddc12   Static       90 m
#> 20       L15 TERN/4443f5df   Static       90 m
#>                                             description
#> 1         Soil Moisture Integration & Prediction System
#> 2           Australian Soil Classification (soil order)
#> 3                  Actual Evapotranspiration via CMRSET
#> 4                 Soil Beta Diversity (NMDS components)
#> 5                  Canopy Height composites (OzTreeMap)
#> 6                                Land Surface Phenology
#> 7                     Available Water Capacity % (SLGA)
#> 8                                 Clay content % (SLGA)
#> 9                                 Sand content % (SLGA)
#> 10                                Silt content % (SLGA)
#> 11              Bulk Density whole earth (g/cm3) (SLGA)
#> 12                                    pH (CaCl2) (SLGA)
#> 13                                    pH (water) (SLGA)
#> 14                              Total Nitrogen % (SLGA)
#> 15                  Available Phosphorus (mg/kg) (SLGA)
#> 16                            Total Phosphorus % (SLGA)
#> 17           Cation Exchange Capacity (meq/100g) (SLGA)
#> 18 Effective Cation Exchange Capacity (meq/100g) (SLGA)
#> 19           Drained upper limit water content % (SLGA)
#> 20            15 bar lower limit water content % (SLGA)
```
