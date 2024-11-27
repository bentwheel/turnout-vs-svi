# get_svi.R

# This script stages SVI data for analysis. You will need to place the SVI by county 
# files in the ./svi_data folder. They can be downloaded from here:
# https://www.atsdr.cdc.gov/placeandhealth/svi/data_documentation_download.html

# The idea behind using a SVI that lags the election year by two years is so
# that we can ultimately develop a model on turnout using SVI (and its contributing factors), 
# with the goal of using the most recently-available SVI (2022) to estimate 
# county-level turnout in 2024's presidential election.

library(tidyverse)

get_svi <- function() {
  
  SVI_2010_US_county <- read_csv(here::here("svi_data/SVI_2010_US_county.csv"))
  SVI_2014_US_county <- read_csv(here::here("svi_data/SVI_2014_US_county.csv"))
  SVI_2016_US_county <- read_csv(here::here("svi_data/SVI_2016_US_county.csv"))
  SVI_2018_US_county <- read_csv(here::here("svi_data/SVI_2018_US_county.csv"))
  SVI_2020_US_county <- read_csv(here::here("svi_data/SVI_2020_US_county.csv"))
  SVI_2022_US_county <- read_csv(here::here("svi_data/SVI_2022_US_county.csv"))
  
  # Plot 2010 SVI vs. turnout to visualize correlation
  svi_2010x <- SVI_2010_US_county %>% 
    select(ST=STATE, ST_ABBR=ST, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES = R_PL_THEMES, 
           RPL_THEME1 = R_PL_THEME1,
           RPL_THEME2 = R_PL_THEME2,
           RPL_THEME3 = R_PL_THEME3,
           RPL_THEME4 = R_PL_THEME4,
           EPL_POV = E_PL_POV, 
           EP_POV = E_P_POV,
           EPL_UNEMP = E_PL_UNEMP, 
           EP_UNEMP = E_P_UNEMP,
           #EPL_HBURD not included until 2020,
           #EP_HBURD not included until 2020,
           EPL_PCI = E_PL_PCI, 
           EP_PCI = E_P_PCI,
           EPL_NOHSDP = E_PL_NOHSDIP, 
           EP_NOHSDP = E_P_NOHSDIP,
           #EPL_UNINSUR not present in 2010,
           #EP_UNINSUR not present in 2010,
           EPL_AGE65 = PL_AGE65, 
           EP_AGE65 = P_AGE65, 
           EPL_AGE17 = PL_AGE17, 
           EP_AGE17 = P_AGE17,
           #EPL_DISABL not present in 2010,
           #EP_DISABL not present in 2010,
           EPL_SNGPNT = PL_SNGPRNT,
           EP_SNGPNT = P_SNGPRNT,
           EPL_MINRTY = PL_MINORITY, 
           EP_MINRTY = P_MINORITY,
           EPL_LIMENG = E_PL_LIMENG, 
           EP_LIMENG = E_P_LIMENG,
           EPL_MUNIT = E_PL_MUNIT, 
           EP_MUNIT = E_P_MUNIT,
           EPL_MOBILE = E_PL_MOBILE, 
           EP_MOBILE = E_P_MOBILE,
           EPL_CROWD = E_PL_CROWD, 
           EP_CROWD = E_P_CROWD,
           EPL_NOVEH = E_PL_NOVEH, 
           EP_NOVEH = E_P_NOVEH,
           EPL_GROUPQ = PL_GROUPQ,
           EP_GROUPQ = P_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_DISABL = NA_real_,
           EP_DISABL = NA_real_,
           EPL_UNINSUR = NA_real_,
           EP_UNINSUR = NA_real_,
           EPL_HBURD = NA_real_,
           EP_HBURD = NA_real_,
           year = 2010) %>% 
    relocate(EPL_DISABL, .after=EPL_AGE17) %>% 
    relocate(EP_DISABL, .after=EPL_DISABL) %>% 
    relocate(EPL_UNINSUR, .after=EPL_NOHSDP) %>% 
    relocate(EP_UNINSUR, .after=EPL_UNINSUR) %>% 
    relocate(EPL_HBURD, .after=EPL_UNEMP) %>% 
    relocate(EP_HBURD, .after=EPL_HBURD) %>%
    mutate_at(vars(starts_with("EP_")), ~ . * 100) # Fix the fact that EP_ variables need to be scaled to match later versions of SVI
  
  svi_2014x <- SVI_2014_US_county %>% 
    select(ST, ST_ABBR, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES,
           RPL_THEME1, 
           RPL_THEME2, 
           RPL_THEME3, 
           RPL_THEME4,
           EPL_POV, 
           EP_POV,
           EPL_UNEMP, 
           EP_UNEMP,
           #EPL_HBURD not included until 2020,
           #EP_HBURD not included until 2020,
           EPL_PCI, 
           EP_PCI,
           EPL_NOHSDP, 
           EP_NOHSDP,
           #EPL_UNINSUR not present in 2014,
           #EP_UNINSUR not present in 2014,
           EPL_AGE65, 
           EP_AGE65,
           EPL_AGE17, 
           EP_AGE17,
           EPL_DISABL, 
           EP_DISABL,
           EPL_SNGPNT,
           EP_SNGPNT,
           EPL_MINRTY, 
           EP_MINRTY,
           EPL_LIMENG, 
           EP_LIMENG, 
           EPL_MUNIT, 
           EP_MUNIT,
           EPL_MOBILE, 
           EP_MOBILE,
           EPL_CROWD, 
           EP_CROWD,
           EPL_NOVEH, 
           EP_NOVEH,
           EPL_GROUPQ,
           EP_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_UNINSUR = NA_real_,
           EP_UNINSUR = NA_real_,
           EPL_HBURD = NA_real_,
           EP_HBURD = NA_real_,
           year = 2014) %>% 
    relocate(EPL_UNINSUR, .after=EPL_NOHSDP) %>% 
    relocate(EP_UNINSUR, .after=EPL_UNINSUR) %>% 
    relocate(EPL_HBURD, .after=EPL_UNEMP) %>% 
    relocate(EP_HBURD, .after=EPL_HBURD) 
  
  svi_2016x <- SVI_2016_US_county %>% 
    select(ST, ST_ABBR, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES,
           RPL_THEME1, 
           RPL_THEME2, 
           RPL_THEME3, 
           RPL_THEME4,
           EPL_POV, 
           EP_POV,
           EPL_UNEMP, 
           EP_UNEMP,
           #EPL_HBURD not included until 2020,
           #EP_HBURD not included until 2020,
           EPL_PCI, 
           EP_PCI,
           EPL_NOHSDP, 
           EP_NOHSDP,
           #EPL_UNINSUR not present in 2016,
           #EP_UNINSUR not present in 2016,
           EPL_AGE65, 
           EP_AGE65,
           EPL_AGE17, 
           EP_AGE17,
           EPL_DISABL, 
           EP_DISABL,
           EPL_SNGPNT,
           EP_SNGPNT,
           EPL_MINRTY, 
           EP_MINRTY,
           EPL_LIMENG, 
           EP_LIMENG,
           EPL_MUNIT, 
           EP_MUNIT,
           EPL_MOBILE, 
           EP_MOBILE,
           EPL_CROWD, 
           EP_CROWD,
           EPL_NOVEH, 
           EP_NOVEH,
           EPL_GROUPQ,
           EP_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_UNINSUR = NA_real_,
           EP_UNINSUR = NA_real_,
           EPL_HBURD = NA_real_,
           EP_HBURD = NA_real_,
           year = 2016) %>% 
    relocate(EPL_UNINSUR, .after=EPL_NOHSDP) %>% 
    relocate(EP_UNINSUR, .after=EPL_UNINSUR) %>% 
    relocate(EPL_HBURD, .after=EPL_UNEMP) %>% 
    relocate(EP_HBURD, .after=EPL_HBURD) 
  
  svi_2018x <- SVI_2018_US_county %>% 
    select(ST, ST_ABBR, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES,
           RPL_THEME1, 
           RPL_THEME2, 
           RPL_THEME3, 
           RPL_THEME4,
           EPL_POV, 
           EP_POV,
           EPL_UNEMP, 
           EP_UNEMP,
           #EPL_HBURD not included until 2020,
           #EP_HBURD not included until 2020,
           EPL_PCI, 
           EP_PCI,
           EPL_NOHSDP, 
           EP_NOHSDP,
           #EPL_UNINSUR not present in 2018,
           #EP_UNINSUR not present in 2018,
           EPL_AGE65, 
           EP_AGE65,
           EPL_AGE17, 
           EP_AGE17,
           EPL_DISABL, 
           EP_DISABL,
           EPL_SNGPNT,
           EP_SNGPNT,
           EPL_MINRTY, 
           EP_MINRTY,
           EPL_LIMENG, 
           EP_LIMENG,
           EPL_MUNIT, 
           EP_MUNIT,
           EPL_MOBILE, 
           EP_MOBILE,
           EPL_CROWD, 
           EP_CROWD,
           EPL_NOVEH,
           EP_NOVEH,
           EPL_GROUPQ,
           EP_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_UNINSUR = NA_real_,
           EP_UNINSUR = NA_real_,
           EPL_HBURD = NA_real_,
           EP_HBURD = NA_real_,
           year = 2018) %>% 
    relocate(EPL_UNINSUR, .after=EPL_NOHSDP) %>% 
    relocate(EP_UNINSUR, .after=EPL_UNINSUR) %>% 
    relocate(EPL_HBURD, .after=EPL_UNEMP) %>% 
    relocate(EP_HBURD, .after=EPL_HBURD) 
    
  svi_2020x <- SVI_2020_US_county %>% 
    select(ST, ST_ABBR, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES,
           RPL_THEME1, 
           RPL_THEME2, 
           RPL_THEME3, 
           RPL_THEME4,
           EPL_POV=EPL_POV150, 
           EP_POV=EP_POV150,
           EPL_UNEMP, 
           EP_UNEMP,
           EPL_HBURD,
           EP_HBURD,
           #EPL_PCI no longer included in 2020+,
           #EP_PCI no longer included in 2020+,
           EPL_NOHSDP, 
           EP_NOHSDP,
           EPL_UNINSUR,
           EP_UNINSUR,
           EPL_AGE65, 
           EP_AGE65,
           EPL_AGE17, 
           EP_AGE17,
           EPL_DISABL, 
           EP_DISABL,
           EPL_SNGPNT,
           EP_SNGPNT,
           EPL_MINRTY, 
           EP_MINRTY,
           EPL_LIMENG, 
           EP_LIMENG,
           EPL_MUNIT, 
           EP_MUNIT,
           EPL_MOBILE, 
           EP_MOBILE,
           EPL_CROWD, 
           EP_CROWD,
           EPL_NOVEH,
           EP_NOVEH,
           EPL_GROUPQ,
           EP_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_PCI = NA_real_,
           EP_PCI = NA_real_,
           year = 2020) %>% 
    relocate(EPL_PCI, .after=EPL_UNEMP) %>% 
    relocate(EP_PCI, .after=EPL_PCI)
  
  svi_2022x <- SVI_2022_US_county %>% 
    select(ST, ST_ABBR, GEOID=FIPS, LOCATION, E_TOTPOP, M_TOTPOP,
           RPL_THEMES,
           RPL_THEME1, 
           RPL_THEME2, 
           RPL_THEME3, 
           RPL_THEME4,
           EPL_POV=EPL_POV150, 
           EP_POV=EP_POV150,
           EPL_UNEMP, 
           EP_UNEMP,
           EPL_HBURD,
           EP_HBURD,
           #EPL_PCI no longer included in 2020+,
           #EP_PCI no longer included in 2020+,
           EPL_NOHSDP, 
           EP_NOHSDP,
           EPL_UNINSUR,
           EP_UNINSUR,
           EPL_AGE65, 
           EP_AGE65,
           EPL_AGE17, 
           EP_AGE17,
           EPL_DISABL, 
           EP_DISABL,
           EPL_SNGPNT,
           EP_SNGPNT,
           EPL_MINRTY, 
           EP_MINRTY,
           EPL_LIMENG, 
           EP_LIMENG,
           EPL_MUNIT, 
           EP_MUNIT,
           EPL_MOBILE, 
           EP_MOBILE,
           EPL_CROWD, 
           EP_CROWD,
           EPL_NOVEH,
           EP_NOVEH,
           EPL_GROUPQ,
           EP_GROUPQ) %>% 
    #filter(RPL_THEMES >= 0) %>% 
    mutate(EPL_PCI = NA_real_,
           EP_PCI = NA_real_,
           year = 2022) %>% 
    relocate(EPL_PCI, .after=EPL_UNEMP) %>% 
    relocate(EP_PCI, .after=EPL_PCI)
  
  svi_all <- svi_2010x %>% 
    union_all(svi_2014x) %>% 
    union_all(svi_2016x) %>% 
    union_all(svi_2018x) %>% 
    union_all(svi_2020x) %>% 
    union_all(svi_2022x)
  
  return(svi_all)
}

svi_all <- get_svi()
