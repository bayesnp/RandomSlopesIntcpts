###
# Generates simulated data for random slopes and intercepts model. 
###
N <- 500   # a simulated sample of N study participants
# About twice as many survivors as controls
survivor <- rep(c(1, 0), times = round( c(N/3*2, N/3) ))
id <- paste0("id", formatC(1:N, width = 3, format = "d", flag = "0"))
# set random seed for reproducibility
set.seed(2317)
# age at study enrollment, centered by average age in the sample
age_enrl <- round( rnorm(N, mean = 72, sd = 5) )
ageC_enrl <- age_enrl - 72        # center by population age mean of 72
age_enrl[age_enrl <= 60] <- 60    # youngest age == 60
age_enrl[age_enrl > 90] <- 90     # oldest age cutoff at 90
# age at enrollment into 4 age bands
age4C <- cut(age_enrl, breaks = c(60, 69, 72, 75, 90), include.lowest=TRUE,
	     labels = c("60-68","69-71","72-74","75-90"))
time_month <- c(0,8,16,24) # measured repeatedly at enrollment and every 8
                           # months thereafter
df1 <- data.frame(id=id, ageC_enrl=ageC_enrl, age4C=age4C, 
		  survivor=survivor)
## TO REMOVE?
#df2 <- expand.grid(id = id, time_month = time_month) # repeat 4 times
#df3 <- merge(df1, df2)                       # merge id, age, time_month
#df3 <- df3[order(df3$id, df3$time_month), ]  # sort by id and time_month

###
# Next, simulate y based on this 2-level model
### 
# level 1: y ~ N(a_i + b_i * time_months, epsilon)
# level 2: [a_i, b_i] ~ N(mu, Sigma), where
#          mu[, "(Intercept)"] = gam00 + gam01*age + gam02*age^2 +
#                                gam03*survivor + gam04*age*survivor +
#                                gam05*age^2*survivor
#          mu[, "time_month"] = gam10 + gam11*survivor + gam12*age4C +
#                               gam13*survivor*age4C
#
# mu[, ] is an N by 2 matrix
mu <- matrix(NA, nrow = N, ncol = 2)
colnames(mu) <- c('(Intercept)', 'time_month')
# It is easier to make mu[, "(Intercept)"] using model.matrix()
Xfix <- model.matrix(~ 1 + ageC_enrl*survivor + I(ageC_enrl^2)*survivor, 
	data = df1)
print(colnames(Xfix))
# gam0 vector: gam0[1] is gam00 above, gam0[2] is gam01, etc.
# But make sure they match the order in colnames(Xfix).
# Note to self: gam0 numbers copied from 'salth_Tbls_ape.html'
gam0 <- c(0.0115, -0.0468, -0.1337, -0.0001, 0.0159, -0.0008)
mu[, '(Intercept)'] <- Xfix %*% gam0
# Next, calculate mu[, "time_month"] intercepts, again using model.matrix()
Xran <- model.matrix(~ 1 + age4C*survivor, data = df1)
gam1 <- c(0.0038,0.0006,-0.0025,-0.0082,0.0002,-0.0010,0.0005,0.0051)
names(gam1) <- colnames(Xran)
mu[, 'time_month'] <- Xran %*% gam1
### 
# Each study participant has a random intercept and slope drawn from 
# a bivariate normal distribution with mean mu[] and covariance Sigma
###
sig_a <- 0.35   # standard deviation for Intercepts
sig_b <- 0.005  # standard deviation for time_month slopes
rho   <- 0.05   # correlation between Intercepts and slopes
# covariance matrix from which the random effects will be simulated
Sigma <- matrix(c(sig_a^2, rho*sig_a*sig_b, rho*sig_a*sig_b, sig_b^2), 2, 2)
###
# Next, alpha_beta is an N by 2 matrix of intercept & slope pair per person
###
alpha_beta <- matrix(NA, nrow = nrow(mu), ncol = ncol(mu))
colnames(alpha_beta) <- colnames(mu)
for (i in 1:nrow(mu)) {  # each person's intcpt & slope drawn from binorm
  alpha_beta[i, ] <- MASS::mvrnorm(n=1, mu = mu[i, ], Sigma = Sigma)
  }
# apply each person's slope value to 4 time points in months such that
# column 1 is 0 (enrollment time), column 2 is slope times 8 months, etc.
time_month_wide <- sapply(alpha_beta[, 'time_month'], 
	function(x) { x * c(0, 8, 16, 24) })
time_month_wide <- t(time_month_wide)
# add (Intercept) across 4 time points
time_month_wide <- sweep(time_month_wide, MAR=1, FUN="+", 
	STAT=alpha_beta[, "(Intercept)"])
colnames(time_month_wide) <- paste0('mon', c(0, 8, 16, 24))
dfc <- cbind(df1, time_month_wide)  # 
# > print(head(dfc), digits = 2)
#           id ageC_enrl age4C survivor time   y_mu time_months      y
#id001.1 id001         3 72-74        1    1 -0.228           0 -0.366
#id002.1 id002         2 72-74        1    1 -0.333           0 -0.622
#id003.1 id003         2 72-74        1    1 -0.361           0 -0.551
#id004.1 id004         6 75-90        1    1  0.026           0  0.034
#id005.1 id005        -3 60-68        1    1 -0.451           0 -0.304
#id006.1 id006        -9 60-68        1    1 -0.082           0 -0.163
##
# convert data from wide-format to long-format
dfc <- reshape(dfc, idvar = "id", 
	       varying = list(c("mon0","mon8","mon16","mon24")), 
	       v.names = "y_mu", direction = "long")
dfc$time_months <- 8 * (dfc$time - 1)
###
# For each person, generate y in wide format
###
epsilon <- 0.1936  # residual stdev, see 'show(salth.f4C_enrl)'
dfc$y <- rnorm(n = nrow(dfc), mean = dfc$y_mu, sd = epsilon)

###
# Below is optional, to test fit a model with the newly simulated dfc.
###
# library('rstanarm')
# options(mc.cores = parallel::detectCores())
# mod1 <- stan_lmer(y ~ ageC_enrl + I(ageC_enrl^2) + survivor + 
	#ageC_enrl:survivor + I(ageC_enrl^2):survivor + time_months + 
	#survivor:time_months + age4C:time_months + 
	#age4C:survivor:time_months + (1 + time_months | id), 
        #chains = 4, warmup = 1000, thin = 5, iter=6000, data = dfc)

#
# NOTE to self: summary() of a rstanarm() model gives COVARIANCE estimates 
# for the random effects, e.g., "Sigma[study_id:(Intercept),(Intercept)]"; 
# however, show(model) gives you random effects standard deviations.  Also,
# an explicit summary() request yields covariances for ranef Sigma, but 
# standard deviation for the residual stdev sigma.
#    > summary(salth.f4C_enrl, par = c("sigma", 
#         "Sigma[study_id:(Intercept),(Intercept)]", 
#         "Sigma[study_id:time_months,(Intercept)]", 
#         "Sigma[study_id:time_months,time_months]"), digits = 4)
#

# these are no longer needed, remove before closing R
rm(alpha_beta,df1,N,id,age_enrl,mu,age4C,ageC_enrl,i,gam0,gam1,
   sig_a,sig_b,survivor,rho,Sigma,time_month,time_month_wide,
   Xfix,Xran,epsilon)  
