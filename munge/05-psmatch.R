

# Propensity scores -------------------------------------------------------

ps <- as_tibble(matrix(NA, nrow = nrow(pdata), ncol = 11), .name_repair = "universal")

for (i in 1:10) {
  impdata_ps <- mice::complete(imp, i)
  if (i == 1) ps[, 1] <- impdata_ps$LopNr
  pslog <- glm(formula(paste0(
    "shf_bblnum ~ ",
    paste(modvarsns,
      collapse = " + "
    )
  )),
  data = impdata_ps,
  family = binomial
  )
  ps[, i + 1] <- pslog$fitted
}

pdata <- left_join(pdata,
  ps %>%
    mutate(ps = rowSums(.[2:11]) / 10) %>%
    select(...1, ps),
  by = c("LopNr" = "...1")
)


# Matching ----------------------------------------------------------------


cal <- c(0.01 / sd(pdata$ps))
set.seed(2334325)

match <- Match(
  Tr = pdata$shf_bblnum,
  X = pdata$ps,
  estimand = "ATC",
  caliper = cal,
  replace = F,
  ties = F,
  M = 2
)

pdata$par <- rep(NA, nrow(pdata))

pdata$par[c(unique(match$index.control), match$index.treated)] <- c(1:match$wnobs, rep(1:match$wnobs, each = 2))
matchp <- pdata[c(unique(match$index.control), match$index.treated), ]

# Sensitivity ps analysis excl NT-proBNP -----------------------------------

ps_sens <- as_tibble(matrix(NA, nrow = nrow(pdata), ncol = 11), .name_repair = "universal")

for (i in 1:10) {
  impdata_ps <- mice::complete(imp_sens, i)
  if (i == 1) ps_sens[, 1] <- impdata_ps$LopNr
  pslog <- glm(formula(paste0(
    "shf_bblnum ~ ",
    paste(modvarsns_sens,
      collapse = " + "
    )
  )),
  data = impdata_ps,
  family = binomial
  )
  ps_sens[, i + 1] <- pslog$fitted
}

pdata <- left_join(pdata,
  ps_sens %>%
    mutate(ps_sens = rowSums(.[2:11]) / 10) %>%
    select(...1, ps_sens),
  by = c("LopNr" = "...1")
)

# Matching excl NT-proBNP ---------------------------------------------------

cal <- c(0.01 / sd(pdata$ps_sens))
set.seed(2334325)

match <- Match(
  Tr = pdata$shf_bblnum,
  X = pdata$ps_sens,
  estimand = "ATC",
  caliper = cal,
  replace = F,
  ties = F,
  M = 2
)

pdata$par_sens <- rep(NA, nrow(pdata))

pdata$par_sens[c(unique(match$index.control), match$index.treated)] <- c(1:match$wnobs, rep(1:match$wnobs, each = 2))
matchp_sens <- pdata[c(unique(match$index.control), match$index.treated), ]
