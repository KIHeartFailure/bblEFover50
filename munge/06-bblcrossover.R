

# Define bbl crossover from DDR -------------------------------------------

matchplm <- left_join(matchp,
  lm,
  by = "LopNr"
) %>%
  filter(
    ANTAL > 0,
    EDATUM <= ymd("2018-12-31"),
    EDATUM >= shf_indexdtm
  ) %>%
  select(LopNr, shf_bbl, EDATUM)

# Censor for bbl No

matchplmNo <- matchplm %>%
  filter(shf_bbl == "No") %>%
  group_by(LopNr) %>%
  arrange(EDATUM) %>%
  slice(1) %>%
  ungroup()

# Censor bbl yes, if > 6 mo between dispensed drugs

matchplmYes1 <- matchplm %>%
  filter(shf_bbl == "Yes") %>%
  group_by(LopNr) %>%
  arrange(EDATUM) %>%
  mutate(diffmed = lead(EDATUM) - EDATUM) %>%
  ungroup() %>%
  arrange(LopNr, EDATUM) %>%
  filter(diffmed >= 30.5 * 6) %>%
  group_by(LopNr) %>%
  arrange(EDATUM) %>%
  slice(1) %>%
  ungroup()

# Censor bbl yes, check last disp (so will censor at last + 3 mo)

matchplmYes2 <- matchplm %>%
  filter(shf_bbl == "Yes") %>%
  group_by(LopNr) %>%
  arrange(EDATUM) %>%
  slice(n()) %>%
  ungroup()

matchplmYes <- bind_rows(matchplmYes1, matchplmYes2) %>%
  group_by(LopNr) %>%
  arrange(EDATUM) %>%
  slice(1) %>%
  ungroup()

matchplmBoth <- bind_rows(matchplmNo, matchplmYes)

matchplm2 <- left_join(matchp, matchplmBoth %>% select(-shf_bbl), by = "LopNr")

matchp <- matchplm2 %>%
  mutate(
    bblcensdate = case_when(
      shf_bbl == "No" ~ EDATUM,
      shf_bbl == "Yes" &
        EDATUM <= shf_indexdtm + sos_outtime_death - 31 * 6 ~
      EDATUM + 31 * 3,
      shf_bbl == "Yes" & is.na(EDATUM) ~ shf_indexdtm + 31 * 3,
    ),
    bblcenstime = as.numeric(bblcensdate - shf_indexdtm),

    sos_outtime_hosphf_bbl = pmin(sos_outtime_hosphf, bblcenstime, na.rm = TRUE),
    sos_outtime_death_bbl = pmin(sos_outtime_death, bblcenstime, na.rm = TRUE),
    sos_out_hosphf_bbl = case_when(
      sos_outtime_hosphf_bbl < sos_outtime_hosphf ~ "No",
      TRUE ~ as.character(sos_out_hosphf)
    ),
    sos_out_deathcv_bbl = case_when(
      sos_outtime_death_bbl < sos_outtime_death ~ "No",
      TRUE ~ as.character(sos_out_deathcv)
    )
  ) %>%
  select(-EDATUM, -diffmed, -bblcenstime, bblcensdate)
