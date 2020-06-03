

# Propensity scores -------------------------------------------------------

ps <- as_tibble(matrix(NA, nrow = nrow(pdata), ncol = 11), .name_repair = "universal")

for (i in 1:10) {
  impdata_ps <- mice::complete(imp, i)
  if (i == 1) ps[, 1] <- impdata_ps$LopNr
  pslog <- glm(formula(paste0("shf_bblnum ~ ", 
                              paste(modvarsns, 
                                    collapse = " + "))),
    data = impdata_ps,
    family = binomial
  )
  ps[, i + 1] <- pslog$fitted
}

pdata <- left_join(pdata, 
                   ps %>%
                     mutate(ps = rowSums(.[2:11]) / 10) %>%
                     select(...1, ps), 
                   by = c("LopNr" = "...1"))

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

index.control.unik <- as.numeric(names(table(match$index.control)))

(n <- length(index.control.unik))
nm <- dim(pdata)
pdata$par <- rep(NA, nm[1])

pdata$par[c(index.control.unik, match$index.treated)] <- c(1:n, rep(1:n, each = 2))
matchp <- pdata[c(index.control.unik, match$index.treated), ]


# Sensitivity ps analysis exckl NT-proBNP ----------------------------------

ps_sens <- as_tibble(matrix(NA, nrow = nrow(pdata), ncol = 11), .name_repair = "universal")

for (i in 1:10) {
  impdata_ps <- mice::complete(imp_sens, i)
  if (i == 1) ps_sens[, 1] <- impdata_ps$LopNr
  pslog <- glm(formula(paste0("shf_bblnum ~ ", 
                              paste(modvarsns_sens, 
                                    collapse = " + "))),
               data = impdata_ps,
               family = binomial
  )
  ps_sens[, i + 1] <- pslog$fitted
}

pdata <- left_join(pdata, 
                   ps_sens %>%
                     mutate(ps_sens = rowSums(.[2:11]) / 10) %>%
                     select(...1, ps_sens), 
                   by = c("LopNr" = "...1"))

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

index.control.unik <- as.numeric(names(table(match$index.control)))

(n <- length(index.control.unik))
nm <- dim(pdata)
pdata$par_sens <- rep(NA, nm[1])

pdata$par_sens[c(index.control.unik, match$index.treated)] <- c(1:n, rep(1:n, each = 2))
matchp_sens <- pdata[c(index.control.unik, match$index.treated), ]

