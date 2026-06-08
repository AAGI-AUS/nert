# SMIPS URLs are stable across all six collections

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/totalbucket/2024/smips_totalbucket_mm_20240115.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/SMindex/2024/smips_smi_perc_20240115.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/bucket1/2024/smips_bucket1_mm_20240115.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/bucket2/2024/smips_bucket2_mm_20240115.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/deepD/2024/smips_deepD_mm_20240115.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/smips/v1_0/runoff/2024/smips_runoff_mm_20240115.tif

# ASC URLs are stable for EV and CI

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_EV_C_P_AU_TRN_N.cog.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_CI_C_P_AU_TRN_N.cog.tif

# AET URLs are stable for ETa and pixel_qa

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/aet/v2_2/2023/2023_06_01/CMRSET_LANDSAT_V2_2_2023_06_01_ETa.vrt
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/aet/v2_2/2023/2023_06_01/CMRSET_LANDSAT_V2_2_2023_06_01_pixel_qa.vrt

# SLGA URLs are stable across all attributes

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_000_005_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/CLY/v2/CLY_000_005_EV_N_P_AU_TRN_N_20210902.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/SND/v2/SND_000_005_EV_N_P_AU_TRN_N_20210902.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/SLT/v2/SLT_000_005_EV_N_P_AU_TRN_N_20210902.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/BDW/v2/BDW_000_005_EV_N_P_AU_TRN_N_20230607.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/pHc/v2/PHC_000_005_EV_N_P_AU_NAT_C_20210913.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/PHW/v1/PHW_000_005_EV_N_P_AU_TRN_N_20220520.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/NTO/v2/NTO_000_005_EV_N_P_AU_NAT_C_20231101.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AVP/v1/AVP_000_005_EV_N_P_AU_TRN_N_20220826.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/PTO/v2/PTO_000_005_EV_N_P_AU_NAT_C_20231101.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/CEC/v1/CEC_000_005_EV_N_P_AU_TRN_N_20220826.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/ECE/v1/ECE_000_005_EV_N_P_AU_NAT_C_20140801.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/DUL/v1/DUL_000_005_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/L15/v1/L15_000_005_EV_N_P_AU_TRN_N_20210614.tif

# SLGA URLs are stable across all six depth intervals

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_000_005_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_005_015_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_015_030_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_030_060_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_060_100_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_100_200_EV_N_P_AU_TRN_N_20210614.tif

# SLGA EV vs CI (05, 95) URLs are stable

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_000_005_EV_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_000_005_05_N_P_AU_TRN_N_20210614.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/AWC/v2/AWC_000_005_95_N_P_AU_TRN_N_20210614.tif

# Soil Beta Diversity URLs are stable across collections and axes

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Bacteria_1_Bacteria_pred.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Bacteria_2_Bacteria_pred.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Bacteria_3_Bacteria_pred.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Fungi_1_Fungi_pred.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Fungi_2_Fungi_pred.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/NMDS_Fungi_3_Fungi_pred.tif

# Canopy Height URL is stable

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/model-derived/OzTreeMap/CanopyHeightComposite/best_pick_files_bhLNnun.tif

# Phenology URLs are stable across all ten metrics

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/1_Start_of_the_growing_season/SGS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/2_Peak_of_the_growing_season/PGS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/3_End_of_the_growing_season/EGS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/4_Length_of_the_growing_season/LGS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/5_Start_of_season/SOS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/6_Peak_of_season/POS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/7_End_of_season/EOS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/8_Length_of_season/LOS_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/9_Rate_of_greening/ROG_2018_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/10_Rate_of_senescence/ROS_2018_Season1.tif

# Phenology URLs are stable across seasons and years

    Code
      cat(sink$urls, sep = "\n")
    Output
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/1_Start_of_the_growing_season/SGS_2003_Season1.tif
      /vsicurl/https://apikey:test-key-0000@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/1_Start_of_the_growing_season/SGS_2018_Season2.tif

