# Synthetic dataset for a grain production experiment in South Australia

Data from a fabricated experiment investigating the effects of Nitrogen
application and seeding rate on grain production for a crop, conducted
across 10 fictional sites in South Australia. The variables are as
follows:

- `Site`: The experiment site locations.

- `Latitude`: Latitude for the site, recorded in decimal degrees
  Northing.

- `Longitude`: Longitude for the site, in decimal degrees Easting.

- `SowDate`: The date that the crops were sown.

- `NitrogenDate`: The date that the Nitrogen treatments were applied.

- `Rep`: Replicate number. (Each site has 3 replicates.)

- `Variety`: The anonymised variety (10 levels).

- `Nitrogen_kgNha`: The applied Nitrogen rate treatment, in kg N/ha.

- `SeedRate_plantsm2`: The seeding rate, measured in target
  establishment plants/m2.

- `Yield_Tha`: The measured grain yield for the plot in T/ha.

## Usage

``` r
data(grain)
```

## Format

A data frame with 2880 rows and 10 variables
