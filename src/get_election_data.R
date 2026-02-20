# get_election_data.R

# This script stages the county-level election returns data for use in our analysis
# and combines it with the population estimates drawn from get_vep_totals.R at the
# county level for 2012, 2016, 2020, and 2024.

# You will need to download "countypres_2000-2024.csv" from the following URL:
# https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ

#... and then place it in the 'election_data' folder in this directory.

library(tidyverse)

get_election_data <- function()
{

  countypres_2000_2024 <- read_csv(here::here("election_data/countypres_2000-2024.csv")) %>%
    filter(office == "US PRESIDENT",
           year %in% c(2012, 2016, 2020, 2024)) %>%
    select(year, state, state_po, county_name, county_fips, party, candidatevotes, totalvotes, mode)


    # NEED TO RECLASSIFY ANY VOTES ATTRIBUTED TO FIPS CODE 2938000 (KANSAS CITY, MO) TO
    # FIPS CODE 29095 (JACKSON COUNTY, MO)
  kcmo_votes <- countypres_2000_2024 %>%
    filter(county_fips == 2938000 | county_fips == 29095) %>%
    mutate(county_name = "JACKSON",
           county_fips = 29095) %>%
    group_by(year, state, state_po, county_name, county_fips, party, mode) %>%
    summarize(totalvotes = sum(totalvotes),
              candidatevotes = sum(candidatevotes))

  countypres_2000_2024 <- countypres_2000_2024 %>%
    filter(!(county_fips == 2938000 | county_fips == 29095)) %>%
    union_all(kcmo_votes)

  # Aggregate across voting modes for 2020 and 2024 (which have mode breakdowns)
  countypres_aggregated <- countypres_2000_2024 %>%
    group_by(year, state, state_po, county_name, county_fips, party) %>%
    summarize(candidatevotes = sum(candidatevotes),
              totalvotes = first(totalvotes),
              .groups = "drop")

  election_data <- countypres_aggregated %>%
    group_by(year, state, state_po, county_name, county_fips) %>%
    mutate(winning_party_flag = max(candidatevotes) == candidatevotes) %>%
    ungroup() %>%
    filter(winning_party_flag) %>%
    distinct(year, state, state_po, county_name, county_fips, totalvotes, winning_party=party)

  return(election_data)
}

election_data <- get_election_data()
