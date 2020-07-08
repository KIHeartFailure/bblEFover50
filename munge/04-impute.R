

# Impute missing values ---------------------------------------------------

noimpvars <- names(pdata)[!names(pdata) %in% modvars]

# Nelson-Aalen estimator
na <- basehaz(coxph(Surv(sos_outtime_hosphf, sos_out_hosphf == "Yes") ~ 1,
  data = pdata, method = "breslow"
))
pdata <- left_join(pdata, na, by = c("sos_outtime_hosphf" = "time"))

ini <- mice(pdata, maxit = 0, print = F)

pred <- ini$pred
pred[, noimpvars] <- 0
pred[noimpvars, ] <- 0 # redundant

# change mthod used in impuation to prop odds model
meth <- ini$method
meth[c("shf_smoking", "shf_nyha", "scb_dispincome_cat", "scb_education")] <- "polr"
meth[noimpvars] <- ""

## check no cores
cores_2_use <- detectCores() - 1
if (cores_2_use >= 10) {
  cores_2_use <- 10
  m_2_use <- 1
} else if (cores_2_use >= 5) {
  cores_2_use <- 5
  m_2_use <- 2
} else {
  stop("Need >= 5 cores for this computation")
}

cl <- makeCluster(cores_2_use)
clusterSetRNGStream(cl, 49956)
registerDoParallel(cl)

imp <-
  foreach(
    no = 1:cores_2_use,
    .combine = ibind,
    .export = c("meth", "pred", "pdata"),
    .packages = "mice"
  ) %dopar% {
    mice(pdata,
      m = m_2_use, maxit = 10, method = meth,
      predictorMatrix = pred,
      printFlag = FALSE
    )
  }
stopImplicitCluster()


# Impute missing values sens analysis excl NT-proBNP ------------------------

noimpvars_sens <- c(names(pdata)[!names(pdata) %in% modvars], "shf_ntpropbnp")

pred <- ini$pred
pred[, noimpvars_sens] <- 0
pred[noimpvars_sens, ] <- 0 # redundant

# change method used in impuation to prop odds model
meth <- ini$method
meth[c("shf_smoking", "shf_nyha", "scb_dispincome_cat", "scb_education")] <- "polr"
meth[noimpvars_sens] <- ""

cl <- makeCluster(cores_2_use)
clusterSetRNGStream(cl, 49956)
registerDoParallel(cl)

imp_sens <-
  foreach(
    no = 1:cores_2_use,
    .combine = ibind,
    .export = c("meth", "pred", "pdata"),
    .packages = "mice"
  ) %dopar% {
    mice(pdata,
      m = m_2_use, maxit = 10, method = meth,
      predictorMatrix = pred,
      printFlag = FALSE
    )
  }
stopImplicitCluster()
