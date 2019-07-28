# Generate races list from campaign committees list with additional hardcoded variables

if(exists('races2') && is.data.frame(races2)) {
  races_custom <- select(races2, -c(raceId)) %>% 
    mutate(raceTypeCustom = raceTypeDetail %>% str_replace_all(c("Chair" = "Chairman", "U.S." = "Delegation - US", " \\(Special\\)" = "")))
  
  races_custom_refined <- races_custom[c("raceTypeCustom", "electionYear", "contributionLimit")]
  
  rm(races2)
}

# start with list of campaigns created in "import_committee_data.R" script
if(exists('all_committees') && is.data.frame(all_committees)) {
  races_list <- all_committees %>% 
    filter(!is.na(office) & !is.na(electionYear)) %>% 
    distinct(office, electionYear) %>% 
    mutate(raceType = case_when(
      office %in% c("Mayor","Attorney General") ~ office,
      grepl("Council", office) ~ "Council",
      grepl("Board", office) ~ "School Board",
      grepl("Representative|Senator", office) ~ "Shadow Delegation",
      grepl("Democratic|Republican", office) ~ "Partisan Positions",
      TRUE ~ "Other"
    ),
    raceTypeDetail = case_when(
      office %in% c("Mayor", "Attorney General") ~ "",
      grepl("Council", office) ~ sub(".*Council ", "", office),
      grepl("Education", office) ~ sub(".*Education ", "", office),
      grepl("School", office) ~ sub(".*Board ", "", office),
      grepl("Representative|Senator|Democratic|Republican", office) ~ office,
      TRUE ~ ""
    )) %>% 
    na_if("") %>% 
    mutate(raceTypeDisplay = case_when(
      is.na(raceTypeDetail) ~ raceType,
      raceTypeDetail == "" ~ raceType,
      TRUE ~ str_c(raceType,raceTypeDetail, sep=" - ")
    )) %>% 
    mutate(raceTypeCustom = str_replace_all(raceTypeDisplay, 
                                          c("District 1" = "District I", 
                                            "District 2" = "District II", 
                                            "District 3" = "District III", 
                                            "District 4" = "District IV"))
    ) %>% 
    left_join(races_custom_refined, by=c("raceTypeCustom", "electionYear")) %>% 
    mutate(raceId = str_c(as.character(electionYear), office, sep=" - "))
  
  races_list <- races_list[c("raceId","electionYear","raceType","raceTypeDetail", "raceTypeDisplay","contributionLimit")]
}

  # race_types <- races_list %>% 
  #   group_by(office) %>% 
  #   summarize(numRaces=n())


write_json(races_list, "updated/seeds/races.json", pretty=2)
  
    