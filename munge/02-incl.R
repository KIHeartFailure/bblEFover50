

# Inclusion/exclusion criteria --------------------------------------------------------

pdata <- rsdata312 %>%
  filter(casecontrol == "Case")

flow <- c("Number of posts (cases) in SHFDB3", nrow(pdata))

pdata <- pdata %>%
  filter(shf_ef == ">=50")
flow <- rbind(flow, c("EF >= 50% (incl no missing EF)", nrow(pdata)))

pdata <- pdata %>%
  filter(!is.na(shf_bbl))
flow <- rbind(flow, c("No missing bbl", nrow(pdata)))

pdata <- pdata %>%
  filter(shf_indexdtm >= ymd("2011-01-01"))
flow <- rbind(flow, c("Indexdate >= 1 Jan 2011, start of loop diuretics", nrow(pdata)))

pdata <- pdata %>%
  group_by(LopNr) %>%
  arrange(shf_indexdtm) %>%
  slice(1) %>%
  ungroup()

flow <- rbind(flow, c("First registration / patient", nrow(pdata)))

flow <- rbind(flow, c(
  "whereof patients with continuous EF",
  nrow(pdata %>%
    filter(!is.na(shf_efproc)))
))

colnames(flow) <- c("Criteria", "N")
