

# Variables for tabs/mods -------------------------------------------------


tabvars <- c(
  "shf_sex", "shf_age",
  "scb_famtype", "scb_child",
  "scb_education",
  "scb_dispincome_cat",
  "shf_bmi_cat",
  "shf_location",
  "shf_indexyear_cat",
  "shf_followuphfunit", "shf_followuplocation",
  "shf_smoking",
  "shf_durationhf",
  "shf_nyha",
  "shf_efproc",
  "shf_bpsys",
  "shf_bpdia",
  "shf_map",
  "shf_heartrate",
  "shf_hb",
  "shf_potassium",
  "shf_gfrckdepi",
  "shf_ntpropbnp",
  "shf_logntpropbnp",
  # "shf_diuretic",
  "shf_loopdiuretic",
  "shf_rasarni",
  "shf_mra",
  "shf_digoxin",
  "shf_asaantiplatelet",
  "shf_anticoagulantia",
  "shf_statin",
  "shf_nitrate",
  "shf_device_cat",
  "sos_com_hypertension",
  "sos_com_diabetes",
  "sos_com_mi",
  "sos_com_pci",
  "sos_com_cabg",
  "sos_com_peripheralartery",
  "sos_com_af",
  "sos_com_stroketia",
  "sos_com_bleed",
  "sos_com_valvular",
  "sos_com_copd",
  "sos_com_alcohol",
  "sos_com_muscoloskeletal3y",
  "sos_com_cancer3y",
  "sos_com_depression"
)

# vars fox log reg and cox reg
tabvars_not_in_mod <- c(
  "shf_map",
  "shf_bpdia",
  "shf_ef",
  "shf_efproc",
  "shf_logntpropbnp"
)

modvars <- tabvars[!(tabvars %in% tabvars_not_in_mod)]

kontvars <- c(
  "shf_age", "shf_bpsys", "shf_heartrate", "shf_hb",
  "shf_potassium", "shf_gfrckdepi", "shf_ntpropbnp"
)

stratavars <- c("shf_location", "shf_rasarni")

modvarspartial <- c(
  "shf_age", "shf_sex",
  "sos_com_mi", "sos_com_pci",
  "sos_com_cabg",
  "sos_com_af",
  "sos_com_copd",
  "sos_com_hypertension"
)


modvarsns <- modvars
modvarsns[modvarsns %in% kontvars] <-
  paste0("ns(", kontvars, ", 3)")

modvarsnsstrata <- modvarsns
modvarsnsstrata[modvarsnsstrata %in% stratavars] <-
  paste0("strata(", stratavars, ")")


# sens analysis excl NT-proBNP
modvarsns_sens <- modvarsns[modvarsns != "ns(shf_ntpropbnp, 3)"]

modvarspartialns <- modvarspartial
modvarspartialns[modvarspartialns %in% kontvars] <-
  paste0("ns(", modvarspartialns[modvarspartialns %in% kontvars], ", 3)")
