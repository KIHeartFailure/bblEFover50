
ProjectTemplate::reload.project()

# Import LM from SoS -----------------------------------------------------

sospath <- "C:/Users/Lina/STATISTIK/Projects/20200225_shfdb3/dm/raw-data/SOS/lev3_15875_2019 Lina Benson/"

lm <- read_sas(paste0(sospath, "t_r_lmed__15875_2019.sas7bdat"))
lm <- zap_formats(lm)
lm <- zap_label(lm)


# Select ATC codes --------------------------------------------------------

lm <- lm %>%
  mutate(atcneed = stringr::str_detect(ATC, "^C07")) %>%
  filter(
    Fall == 1,
    ANTAL >= 0,
    atcneed
  )

# Store as RData in /data folder ------------------------------------------

save(file = "./data/lm.RData", list = c("lm"))