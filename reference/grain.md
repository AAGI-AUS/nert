# Synthetic dataset for a grain production experiment in South Australia

Data from a fabricated experiment investigating the effects of nitrogen
application and seeding rate on wheat grain production for a crop
conducted across 10 fictional sites in South Australia.

## Usage

``` r
data(grain)
```

## Format

A `data.frame` with 2880 rows and 10 variables.

## Details

The variables are as follows:

- Site:

  The experiment site locations. (Factor)

- Latitude:

  Latitude for the site. (Numeric)

- Longitude:

  Longitude for the site. (Numeric)

- SowDate:

  The date that the crops were sown. (Date)

- NitrogenDate:

  The date that the nitrogen applications were made. (Date)

- Rep:

  Replicate number. (Each site has 3 replicates.) (Factor)

- Variety:

  The anonymised variety (8 levels). (Factor)

- Nitrogen_kgNha:

  The applied nitrogen rate treatment, in kg N/ha. (Factor)

- SeedRate_plantsm2:

  The seeding rate, measured in target establishment plants/m2. (Factor)

- Yield_Tha:

  The measured grain yield for the plot in T/ha. (Numeric)
