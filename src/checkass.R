
ProjectTemplate::reload.project()

dataass <- mice::complete(imp, 6)


# Cox regression ----------------------------------------------------------


modm_hf <- coxph(Surv(sos_outtime_hosphf, sos_out_hosphf == "Yes") ~ shf_bbl, data = matchp)
modm_cv <- coxph(Surv(sos_outtime_death, sos_out_deathcv == "Yes") ~ shf_bbl, data = matchp)

mod_hf <- coxph(formula(paste0(
  "Surv(sos_outtime_hosphf, sos_out_hosphf == 'Yes') ~ shf_bbl +",
  paste(modvarsns, collapse = " + ")
)),
data = dataass
)

mod_cv <- coxph(formula(paste0(
  "Surv(sos_outtime_death, sos_out_deathcv == 'Yes') ~ shf_bbl +",
  paste(modvarsns, collapse = " + ")
)),
data = dataass
)

# Checking for non-prop hazards -------------------------------------------

print(testpat <- cox.zph(mod_hf))
(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

print(testpat <- cox.zph(mod_cv))
(sig <- testpat$table[testpat$table[, 3] < 0.05, ])

# Checking for outliers ---------------------------------------------------

ggcoxdiagnostics(mod_hf,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)
ggcoxdiagnostics(mod_cv,
  type = "dfbeta",
  linear.predictions = FALSE, ggtheme = theme_bw()
)
