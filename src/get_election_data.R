# get_election_data.R

# This script stages the county-level election returns data for use in our analysis
# and combines it with the population estimates drawn from get_vep_totals.R at the
# county level for 2012, 2016, and 2020.

# You will need to download "countypres_2000-2020.csv" from the following URL:
# https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ

#... and then place it in the 'election_data' folder in this directory.

library(tidyverse)

get_election_data <- function()
{
  
  countypres_2000_2020 <- read_csv(here::here("election_data/countypres_2000-2020.csv")) %>% 
    filter(office == "US PRESIDENT",
           year %in% c(2012, 2016, 2020)) %>% 
    select(year, state, state_po, county_name, county_fips, party, candidatevotes, totalvotes, mode) 
  
  
    # NEED TO RECLASSIFY ANY VOTES ATTRIBUTED TO FIPS CODE 2938000 (KANSAS CITY, MO) TO 
    # FIPS CODE 29095 (JACKSON COUNTY, MO)
  kcmo_votes <- countypres_2000_2020 %>% 
    filter(county_fips == 2938000 | county_fips == 29095) %>% 
    mutate(county_name = "JACKSON",
           county_fips = 29095) %>% 
    group_by(year, state, state_po, county_name, county_fips, party, mode) %>% 
    summarize(totalvotes = sum(totalvotes),
              candidatevotes = sum(candidatevotes))
  
  countypres_2000_2020 <- countypres_2000_2020 %>% 
    filter(!(county_fips == 2938000 | county_fips == 29095)) %>% 
    union_all(kcmo_votes)
  
  total_2020 <- countypres_2000_2020 %>% 
    filter(year == 2020) %>% 
    group_by(year, state, state_po, county_name, county_fips, party, totalvotes) %>% 
    summarize(candidatevotes = sum(candidatevotes)) %>% 
    ungroup() %>% 
    mutate(mode = "TOTAL") %>% 
    relocate(candidatevotes, .before=totalvotes)
  
  total_2012_2016 <- countypres_2000_2020 %>% 
    filter(year %in% c(2012, 2016))
  
  countypres_x <- total_2012_2016 %>% 
    union_all(total_2020)
  
  election_data <- countypres_2000_2020 %>% 
    group_by(year, state, state_po, county_name, county_fips) %>% 
    mutate(winning_party_flag = max(candidatevotes) == candidatevotes) %>% 
    ungroup() %>% 
    filter(winning_party_flag) %>% 
    select(year, state, state_po, county_name, county_fips, totalvotes, winning_party=party) 
  
  nc_fips_map <- election_data %>% 
    filter(state_po == "NC") %>% 
    distinct(county_name, county_fips)

  nc_data_2024 <- read_tsv(here::here("election_data/results_pct_20241105.txt")) %>% 
    filter(str_trim(`Contest Name`) == 'US PRESIDENT') %>% 
    group_by(`County`, `Choice`, `Choice Party`) %>% 
    summarize(totalvotes = sum(`Total Votes`)) %>% 
    ungroup() %>% 
    group_by(county_name=`County`) %>% 
    mutate(winning_party_flag = totalvotes == max(totalvotes)) %>% 
    ungroup() 
  
  nc_data_2024_winners <- nc_data_2024 %>% 
    filter(winning_party_flag) %>% 
    mutate(winning_party = if_else(`Choice Party` == "DEM", "DEMOCRAT", "REPUBLICAN")) %>% 
    select(county_name=`County`, winning_party)
  
  election_data_nc <- nc_data_2024 %>% 
    group_by(county_name) %>% 
    summarize(totalvotes = sum(totalvotes)) %>% 
    mutate(year = 2024,
           state = "NORTH CAROLINA",
           state_po = "NC") %>% 
    left_join(nc_data_2024_winners) %>% 
    left_join(nc_fips_map) %>% 
    relocate(state, .after=year) %>% 
    relocate(state_po, .after=state) %>% 
    relocate(county_name, .after=state_po) %>% 
    relocate(county_fips, .after=county_name) %>% 
    relocate(totalvotes, .after=county_name)
  
  election_data_final <- election_data %>% 
    union_all(election_data_nc)
  
  return(election_data_final)
}

election_data <- get_election_data()
    

  
