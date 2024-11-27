# get_vep_totals.R

# This script loads data from the 5 year ACS (American Community Survey) to obtain best-estimate population
# counts at the county level. For the 2012 election we use 2014 5yr ACS data, which is based on the sum
# of estimates in the respective 1yr ACS data from 2010, 2011, 2012, 2013, and 2014. The idea is that
# we want to center the 5yr data on the election year (2012). Thus, for 2012 election data we use 2014 5yr ACS data,
# for 2016 election data we use 2018 5yr ACS data, and so on.

# Population county-level population estimates are not available in 1yr ACS data for geographies with fewer 
# than 65,000 people and have a higher standard error, which makes them unusable for smaller, rural counties.

library(tidycensus)
library(tidyverse)

# Store your own Census Key below. You can get a census key here:
# https://api.census.gov/data/key_signup.html

get_vep_totals <- function()
{
  
  apikey <- rstudioapi::askForPassword(prompt = "Please enter your USCB API Key")
  census_api_key(apikey)
  
  # Load all variables for ACS 5-year data (2020) and store them in a data frame. For estimating the total
  # voting-eligible population (VEP), we will use the following four variables:
  
  # name          | description  
  # -----------------------------------------------------------------------------
  # B05003_008    | Estimate!!Total!!Male!!18 years and over
  # B05003_012    | Estimate!!Total!!Male!!18 years and over!!Foreign born!!Not a U.S. citizen
  # B05003_019    | Estimate!!Total!!Female!!18 years and over
  # B05003_023    | Estimate!!Total!!Female!!18 years and over!!Foreign born!!Not a U.S. citizen
  
  variables <- load_variables(2014, "acs5", cache = TRUE) %>% 
    filter(name %in% c("B05003_008", "B05003_012", "B05003_019", "B05003_023"))
  
  # Note that these Voter eligible population also excludes felons in some states, so our
  # total counts here are likely to be overcounts of "true" VEP, but it's VEP-ish enough
  # for our purposes.
  
  # We will define VEP as the estimate of total voting age population (VAP) defined in
  # variables B05003_008 (males) and B05003_019 (females) less the number of 18+ year-old
  # foreign-born noncitizens reflected in variables B05003_012 (males) and B05003_023 (females).
  
  # VEP = B05003_008 + B05003_019 - B05003_012 - B05003_023
  
  # Note that these are ESTIMATES and can vary substantially from the true count of indviduals,
  # especially in smaller and harder-to-survey (typically rural) geographies.
  
  # Therefore, in a few cases, vote totals will exceed the totals of VEP at the county level.
  # Put your tinfoil hat away - this does not mean that people are voting illegally.
  # This is a false narrative. Read a book sometime.
  
  # Import VEPish numbers by county
  us_vep_data_2012 <- get_acs(
    geography = "county",
    variables = c("B05003_008", "B05003_012", "B05003_019", "B05003_023"),
    year = 2010,
    survey = "acs5",
    output = "wide"
  ) %>% 
    mutate(VAP_denom = (B05003_008E + B05003_019E),
           VEP_denom = VAP_denom - (B05003_012E + B05003_023E)) %>% 
    select(GEOID, NAME, VAP_denom, VEP_denom) %>% 
    mutate(year = 2012,
           county_fips = as.numeric(GEOID))
  
  us_vep_data_2016 <- get_acs(
      geography = "county",
      variables = c("B05003_008", "B05003_012", "B05003_019", "B05003_023"),
      year = 2014,
      survey = "acs5",
      output = "wide"
    ) %>% 
    mutate(VAP_denom = (B05003_008E + B05003_019E),
           VEP_denom = VAP_denom - (B05003_012E + B05003_023E)) %>% 
    select(GEOID, NAME, VAP_denom, VEP_denom) %>% 
    mutate(year = 2016,
           county_fips = as.numeric(GEOID))
  
  # Import 2020 VEPish numbers by county
  us_vep_data_2020 <- get_acs(
    geography = "county",
    variables = c("B05003_008", "B05003_012", "B05003_019", "B05003_023"),
    year = 2018,
    survey = "acs5",
    output = "wide"
  ) %>% 
    mutate(VAP_denom = (B05003_008E + B05003_019E),
           VEP_denom = VAP_denom - (B05003_012E + B05003_023E)) %>% 
    select(GEOID, NAME, VAP_denom, VEP_denom) %>% 
    mutate(year = 2020,
           county_fips = as.numeric(GEOID))
  
  # Import 2024 VEPish numbers by county
  us_vep_data_2024 <- get_acs(
    geography = "county",
    variables = c("B05003_008", "B05003_012", "B05003_019", "B05003_023"),
    year = 2022,
    state = "NC",
    survey = "acs5",
    output = "wide"
  ) %>% 
    mutate(VAP_denom = (B05003_008E + B05003_019E),
           VEP_denom = VAP_denom - (B05003_012E + B05003_023E)) %>% 
    select(GEOID, NAME, VAP_denom, VEP_denom) %>% 
    mutate(year = 2024,
           county_fips = as.numeric(GEOID))
  
  # Combine into single dataset
  us_vep_data <- us_vep_data_2012 %>% 
    union_all(us_vep_data_2016) %>% 
    union_all(us_vep_data_2020) %>% 
    union_all(us_vep_data_2024)
  
  return(us_vep_data)
  
}

us_vep_data <- get_vep_totals()


