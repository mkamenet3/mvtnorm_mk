
TVPACK <- function(abseps = 1e-6) structure(list(eps = abseps), class = "TVPACK")

probval.TVPACK <- function (x, n, df, lower, upper, infin, corr, delta, ...)
{
    if (df > 0 && any(delta != 0))
        stop("TVPACK only possible for the central t-distribution.")
    ## can only deal with *integer* df :
    if (abs(df - as.integer(df)) > 1e-7)
	stop("'df' must be integer (valued)")
    nu <- as.integer(df)

    upp <- upper - delta
    low <- lower - delta

### FIXME: stupid;  do dimension reduction for  (low,up) = (-Inf, Inf) pairs!
    if ((any(infin < 0) | any(infin > 1)) | length(unique(infin)) > 1)
        stop("TVPACK either needs all(lower == -Inf) or all(upper == Inf).")

    if (all(infin == 1))
        upp <- -low

    upp <- as.double(upp)
    eps <- as.double(x$eps)

    if (n == 1) {
        val <-
            if(nu == 0) pnorm(upp) - pnorm(low)
            else    pt(upp, df=nu) - pt(low, df=nu)
    }
    if (n == 2) {
        cr <- as.double(corr[2,1])
        val <- .C(mvtnorm_C_bvtlr, nu, upp[1], upp[2], cr, val = double(1))$val
    }
    else if (n == 3) {
        cr <- c(corr[2,1], corr[3,1], corr[3,2])
        cr <- as.double(cr)
        val <- .C(mvtnorm_C_tvtlr, nu, upp, cr, eps, val = double(1))$val # ../src/tvpack.f
    }
    else stop("need n = 2 or 3 for TVPACK() algorithm")
    list(value = val, inform = 0,
         error = if(n == 3) eps else if(n == 1) 0 else NA)
}
