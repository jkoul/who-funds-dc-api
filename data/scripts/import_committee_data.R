# Excel files exported from https://efiling.ocf.dc.gov/Disclosure (select each Filer Type, export each to Excel, and remove first two rows)

library(tidyverse)
library(readxl)

campaign_committees_raw <- read_excel("original/excel_downloads/all_campaign_committees_raw.xlsx", 
  col_types = c("text", "text", "numeric", "text", "text"))

campaign_committees_normalized <- campaign_committees_raw %>% 
  mutate(committeeType = "Campaign Committee") %>% 
  rename(committeeName = "Committee Name",
         candidateName = "Candidate Name",
         electionYear = "Election Year",
         office = "Office")
campaign_committees_normalized$Status <- NULL

pacs_raw <- read_excel("original/excel_downloads/all_pacs_raw.xlsx", 
  col_types = c("text", "numeric", "text"))

pacs_normalized <- pacs_raw %>% 
  mutate(candidateName = NA, office = NA, committeeType = "Political Action Committee") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year")

pacs_normalized <- pacs_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

initiatives_raw <- read_excel("original/excel_downloads/all_initiatives_raw.xlsx", 
  col_types = c("text", "numeric", "text"))

initiatives_normalized <- initiatives_raw %>% 
  mutate(candidateName = NA, office = NA, committeeType = "Ballot Initiative") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year")

initiatives_normalized <- initiatives_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

referenda_raw <- read_excel("original/excel_downloads/all_referenda_raw.xlsx", 
  col_types = c("text", "numeric", "text"))

referenda_normalized <- referenda_raw %>% 
  mutate(candidateName = NA, office = NA, committeeType = "Ballot Referendum") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year")

referenda_normalized <- referenda_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

recalls_raw <- read_excel("original/excel_downloads/all_recalls_raw.xlsx", 
  col_types = c("text", "numeric", "text", "text"))

recalls_normalized <- recalls_raw %>% 
  mutate(candidateName = NA, committeeType = "Recall Campaign") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year",
         office="Office")

recalls_normalized <- recalls_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

inaugural_raw <- read_excel("original/excel_downloads/all_inaugural_raw.xlsx", 
  col_types = c("text", "text", "numeric", "text"))

inaugural_normalized <- inaugural_raw %>% 
  mutate(office = "Mayor", committeeType = "Inaugural Committee") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year",
         candidateName = "Mayor Name")
  
inaugural_normalized <- inaugural_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

ie_committees_raw <- read_excel("original/excel_downloads/all_ie_committees_raw.xlsx", 
  col_types = c("text", "numeric", "text", "text"))

ie_committees_normalized <- ie_committees_raw %>% 
  mutate(candidateName = NA, committeeType = "Independent Expenditure Committee") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year",
         office="Office")

ie_committees_normalized$office <- NA
ie_committees_normalized <- ie_committees_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]


exploratory_committees_raw <- read_excel("original/excel_downloads/all_exploratory_committees_raw.xlsx", 
  col_types = c("text", "text", "numeric", "text", "text"))

exploratory_committees_normalized <- exploratory_committees_raw %>% 
  mutate(committeeType="Exploratory Committee") %>% 
  rename(committeeName = "Committee Name",
         electionYear = "Election Year",
         candidateName = "Explorer Name",
         office="Office")

exploratory_committees_normalized <- exploratory_committees_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]
  
statehood_delegation_funds_raw <- read_excel("original/excel_downloads/all_statehood_delegation_funds_raw.xlsx", 
  col_types = c("text", "numeric", "text", "text"))

statehood_delegation_funds_normalized <- statehood_delegation_funds_raw %>% 
  rename(committeeName = "Registrant Name",
         electionYear = "Election Year",
         office="Office") %>% 
  mutate(candidateName = committeeName, committeeType = "Statehood Delegation Fund")

statehood_delegation_funds_normalized <- statehood_delegation_funds_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

constituent_service_funds_raw <- read_excel("original/excel_downloads/all_constituent_service_funds_raw.xlsx", 
  col_types = c("text", "text", "numeric", "text", "text"))

constituent_service_funds_normalized <- constituent_service_funds_raw %>% 
  rename(committeeName = "Constituent Service Program Name",
         candidateName = "Candidate Name",
         electionYear = "Election Year",
         office="Office") %>% 
  mutate(committeeType = "Constituent Service Fund")

constituent_service_funds_normalized <- constituent_service_funds_normalized[c("committeeName","candidateName","electionYear","office","committeeType")]

rm(campaign_committees_raw, 
   pacs_raw, 
   initiatives_raw, 
   referenda_raw, 
   recalls_raw, 
   inaugural_raw, 
   ie_committees_raw, 
   exploratory_committees_raw, 
   statehood_delegation_funds_raw, 
   constituent_service_funds_raw)

all_committees <- bind_rows(campaign_committees_normalized,
                            pacs_normalized,
                            initiatives_normalized,
                            referenda_normalized,
                            recalls_normalized,
                            inaugural_normalized,
                            ie_committees_normalized,
                            exploratory_committees_normalized,
                            statehood_delegation_funds_normalized,
                            constituent_service_funds_normalized)

rm(campaign_committees_normalized,
   pacs_normalized,
   initiatives_normalized,
   referenda_normalized,
   recalls_normalized,
   inaugural_normalized,
   ie_committees_normalized,
   exploratory_committees_normalized,
   statehood_delegation_funds_normalized,
   constituent_service_funds_normalized)

all_committees$office[all_committees$office=="Ward Councilmember"] <- "Council Ward 6"
all_committees <- mutate(all_committees, raceId = str_c(as.character(electionYear), office, sep=" - "))
all_committees <- all_committees[c("committeeName","candidateName","raceId","electionYear","office","committeeType")]

# write finalized seed file to json in project folder
library(jsonlite)
write_json(all_committees, "updated/seeds/committees.json", pretty=2)

