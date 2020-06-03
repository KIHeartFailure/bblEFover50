my.coxph.mids <- function(formula, data, ...) {
  call <- match.call()
  if (!is.mids(data)) {
    stop("The data must have class mids")
  }
  analyses <- as.list(1:data$m)
  for (i in 1:data$m) {
    data.i <- mice::complete(data, i)
    analyses[[i]] <- do.call("coxph", list(formula = quote(formula), data = quote(data.i), ...))
  }
  object <- list(
    call = call, call1 = data$call, nmis = data$nmis,
    analyses = analyses
  )
  oldClass(object) <- c("mira", "coxph")
  return(object)
}