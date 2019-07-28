# script to import, clean and standardize dummy data

library(tidyverse)
library(jsonlite)

campaigns_orig <- fromJSON("original/mock_api/campaign.json")
candidates_orig <- fromJSON("original/mock_api/candidate.json")
races_orig <- read_csv("original/mock_api/race.csv", 
            col_types = cols(id = col_skip()))
metadata_orig <- fromJSON("original/mock_api/metadata.json")


office_types <- data.frame(metadata_orig["officeType"]) %>% 
  rename(id = officeType.id, description = officeType.description)
  
committee_types <- data.frame(metadata_orig["committeeType"]) %>% 
  rename(id = committeeType.id, description = committeeType.description)

rm(metadata_orig)

races2 <- races_orig %>% 
  left_join(office_types, by=c("officeTypeId" = "id")) %>% 
  rename(raceType = description) %>% 
  left_join(candidates_orig,by=c("winners__001" = "id")) %>% 
  rename(winner = name) %>% 
  left_join(candidates_orig, by=c("winners__002" = "id")) %>% 
  rename(winner2 = name)
  
races2 <- races2[c("raceId", "raceType", "raceTypeDetail", "electionYear", "contributionLimit", "winner", "winner2")]

rm(races_orig)

campaigns2 <- campaigns_orig %>% 
  left_join(candidates_orig, by=c("candidateId" = "id")) %>% 
  left_join(committee_types, by=c("committeeTypeId" = "id")) %>% 
  rename(candidateName = name,
         committeeType = description)

campaigns2$candidateId <- NULL
campaigns2$committeeTypeId <- NULL
campaigns2[campaigns2 == ""] <- NA
campaigns2$id <- NULL

rm(campaigns_orig, candidates_orig)

# Convert back to JSON
write_json(campaigns2,"updated/mock_api/campaigns.json", pretty=2)
write_json(races2,"updated/mock_api/races.json", pretty=2)
  
  