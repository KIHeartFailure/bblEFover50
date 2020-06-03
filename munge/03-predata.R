
# Creating variables needed for project PRIOR to imputation ---------------

pdata <- pdata %>%
  mutate(
    shf_bmi_cat = case_when(
      is.na(shf_bmi) ~ NA_character_,
      shf_bmi <= 30 ~ "<=30",
      shf_bmi > 30 ~ ">30"
    ),
    shf_indexyear_cat = case_when(
      shf_indexyear <= 2005 ~ "2000-2005",
      shf_indexyear <= 2010 ~ "2006-2010",
      shf_indexyear <= 2015 ~ "2011-2015",
      shf_indexyear <= 2018 ~ "2016-2018"
    ),
    ## Device
    shf_device_cat = case_when(
      is.na(shf_device) ~ NA_character_,
      shf_device %in% c("CRT", "CRT & ICD", "ICD") ~ "ICD/CRT",
      TRUE ~ "No/Pacemaker"
    ),
    shf_bbldosemax = case_when(
      shf_bblsub == "Atenolol" ~ shf_bbldose / 100,
      shf_bblsub == "Betaxolol" ~ shf_bbldose / 40,
      shf_bblsub == "Bisoprolol" ~ shf_bbldose / 20,
      shf_bblsub == "Carvedilol" ~ shf_bbldose / 50,
      shf_bblsub == "Labetalol" ~ shf_bbldose / 1000,
      shf_bblsub == "Metoprolol" ~ shf_bbldose / 100,
      shf_bblsub == "Pindolol" ~ shf_bbldose / 60,
      shf_bblsub == "Propanolol" ~ shf_bbldose / 240,
      shf_bblsub == "Sotalol" ~ shf_bbldose / 320,
      shf_bblsub == "Timolol" ~ shf_bbldose / 40
    ),
    shf_dosebbl_Bisoprolol = case_when(shf_bblsub == "Bisoprolol" ~ shf_bbldose),
    shf_dosebbl_Carvedilol = case_when(shf_bblsub == "Carvedilol" ~ shf_bbldose),
    shf_dosebbl_Metoprolol = case_when(shf_bblsub == "Metoprolol" ~ shf_bbldose),

    # log
    shf_logntpropbnp = log(shf_ntpropbnp),

    # numeric bbl
    shf_bblnum = as.numeric(shf_bbl) - 1,

    # comp outcomes
    sos_out_hosphf_comp = case_when(
      sos_out_hosphf == "Yes" ~ 1,
      sos_out_death == "Yes" ~ 2,
      TRUE ~ 0
    ),
    sos_out_deathcv_comp = case_when(
      sos_out_deathcv == "Yes" ~ 1,
      sos_out_death == "Yes" ~ 2,
      TRUE ~ 0
    )
  ) %>%
  mutate_if(is_character, factor) %>%
  mutate(shf_device_cat = relevel(shf_device_cat, ref = "No/Pacemaker"))
