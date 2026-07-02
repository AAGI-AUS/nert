# nert: Curated Access to TERN Environmental Raster Data

Provides curated access to gridded environmental data published by
Australia's Terrestrial Ecosystem Research Network (TERN;
<https://www.tern.org.au/>), spanning national soil attribute, soil
classification, soil biodiversity, soil moisture, actual
evapotranspiration, vegetation canopy height and phenology products. The
package reads Cloud-Optimised GeoTIFF and virtual raster files directly
from the TERN data server via GDAL '/vsicurl' range requests, streaming
only the requested spatial and temporal subset for efficient data
transfer. The environmental raster data are returned as
terra::SpatRaster objects. A convenient helper function is also provided
that provides a batch-download capability given specific locations and
dates, returning the extracted data values in an analysis-ready
data.table. Access to the TERN datasets using this package requires a
TERN API key.

## See also

Useful links:

- <https://aagi-aus.github.io/nert/>

- <https://github.com/AAGI-AUS/nert>

- Report bugs at <https://github.com/AAGI-AUS/nert/issues>

## Author

**Maintainer**: Sam Rogers <sam.rogers@adelaide.edu.au>
([ORCID](https://orcid.org/0000-0002-8147-1239))

Authors:

- Sam Rogers <sam.rogers@adelaide.edu.au>
  ([ORCID](https://orcid.org/0000-0002-8147-1239))

- Adam H. Sparks <adamhsparks@gmail.com>
  ([ORCID](https://orcid.org/0000-0002-0061-8359))

- Wasin Pipattungsakul <wasin.pipattungsakul@adelaide.edu.au>

- Russell Edson <russell.edson@adelaide.edu.au>
  ([ORCID](https://orcid.org/0000-0002-4607-5396))

- Max Moldovan <max.moldovan@adelaide.edu.au>
  ([ORCID](https://orcid.org/0000-0001-9680-8474))

Other contributors:

- Grains Research and Development Corporation
  ([ROR](https://ror.org/02xwr1996)) (GRDC Project CUR2210-005OPX
  (AAGI-CU), UOA2301-005OPX (AAGI-AU)) \[funder, copyright holder\]
