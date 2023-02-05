###
# plot mod1 after running 'fit_model.R'
###
# MCMC draws of all parameters (needed for shaded curves)
mod1.summary <- summary(mod1)
mod1.mat <- as.matrix(mod1)
# show the number of MCMC iterations, 40,000 altogether?
print( dim(mod1.mat) )
enrl_names <- c("(Intercept)","ageC_enrl","I(ageC_enrl^2)","survivor",
  "time_months","ageC_enrl:survivor","I(ageC_enrl^2):survivor",
  "survivor:time_months","time_months:age4C69-71","time_months:age4C72-74",
  "time_months:age4C75-90","survivor:time_months:age4C69-71",
  "survivor:time_months:age4C72-74","survivor:time_months:age4C75-90")
cnames <- colnames(mod1.mat)
# Regexpr "^[bsS][\\[i]" matches 'b' or 's' or 'S' in the first 
# character, followed by a literal '[' (two backslashes to 
# escape '\' in R) or an 'i'. Thus, it matches any 'b[' 
# (subject-specific random effects), 'si', or 'Si'.
# The 'si' and 'Si' terms skip the residual and VarCorr.
# I will get them later. Note that grepl() gives TRUE/FALSE 
# for each, then ! matches every thing except 'b['.
cnames <- cnames[ ! grepl("^[bsS][\\[i]", cnames)]
if (! identical(cnames, enrl_names) )  # check they are typed correctly
   stop("check spelling of fixed effects")

mod1.mat <- mod1.mat[, enrl_names]
# Level 1 fixed effects coefficients, over MCMC draws
r00 <- mod1.mat[, "(Intercept)"]
r01 <- mod1.mat[, "ageC_enrl"]
r02 <- mod1.mat[, "I(ageC_enrl^2)"]
r03 <- mod1.mat[, "survivor"]
r04 <- mod1.mat[, "ageC_enrl:survivor"]
r05 <- mod1.mat[, "I(ageC_enrl^2):survivor"]

# Level 2 fixed effects coefficients, over MCMC
r10 <- mod1.mat[, "time_months"]
r11 <- mod1.mat[, "survivor:time_months"]
r12_2 <- mod1.mat[, "time_months:age4C69-71"]
r12_3 <- mod1.mat[, "time_months:age4C72-74"]
r12_4 <- mod1.mat[, "time_months:age4C75-90"]
r13_2 <- mod1.mat[, "survivor:time_months:age4C69-71"]
r13_3 <- mod1.mat[, "survivor:time_months:age4C72-74"]
r13_4 <- mod1.mat[, "survivor:time_months:age4C75-90"]
###############################
# mean of MCMC draws (needed for plotting random effects)
###
r00m <- mean(mod1.mat[, "(Intercept)"])
r01m <- mean(mod1.mat[, "ageC_enrl"])
r02m <- mean(mod1.mat[, "I(ageC_enrl^2)"])
r03m <- mean(mod1.mat[, "survivor"])
r04m <- mean(mod1.mat[, "ageC_enrl:survivor"])
r05m <- mean(mod1.mat[, "I(ageC_enrl^2):survivor"])

# Level 2 fixed effects coefficients
r10m <- mean(mod1.mat[, "time_months"])
r11m <- mean(mod1.mat[, "survivor:time_months"])
r12_2m <- mean(mod1.mat[, "time_months:age4C69-71"])
r12_3m <- mean(mod1.mat[, "time_months:age4C72-74"])
r12_4m <- mean(mod1.mat[, "time_months:age4C75-90"])
r13_2m <- mean(mod1.mat[, "survivor:time_months:age4C69-71"])
r13_3m <- mean(mod1.mat[, "survivor:time_months:age4C72-74"])
r13_4m <- mean(mod1.mat[, "survivor:time_months:age4C75-90"])

## Add an alpha value to a color
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  # col2rgb() to convert color names to rgb, then set alpha value
  apply(sapply(col, grDevices::col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}
# Plot each person's *observed* scores over 4 assessments
# svg("Fig_mod1.svg", height = 6, width = 11)
###
pdf("Fig_mod1.pdf", height = 6, width = 11)

avg.age.enrl <- 72   # see 'gen_simulated_data.R'
par(mfcol = c(1, 2))
x_age_range <- c(60, 90)   # age range lowest to highest on the x-axis
t.ageC <- seq(x_age_range[1]-avg.age.enrl, x_age_range[2]-avg.age.enrl, by=0.05)
###
# On the left, plot the model-estimated averages and posterior HDI
###
qtiles.conf <- 0.95   # posterior HDI interval
with(dfc, plot(x=ageC_enrl, y=y, type="n", axes=FALSE, 
        xlim = x_age_range-avg.age.enrl, xlab="", ylab=""))
# grey_alpha3 <- add.alpha("grey", alpha=0.3)
grey_alpha3 <- add.alpha("blue", alpha=0.1)

####
# plot HDI as shaded areas, first with Controls (no practice * Months)
####
yy.C.mat <- r01 %o% t.ageC + r02 %o% t.ageC^2  # outer() to get iter by age matrix
# sweep across MAR=1 to add intercepts to age
yy.C <- sweep(yy.C.mat, MARGIN = 1, FUN = "+", STATS = r00)
y.mean.ctrl <- apply(yy.C, MARGIN = 2, mean)
# Add shaded areas first before adding personal lines and averages
y.qtiles.ctrl <- apply(yy.C, MARGIN = 2, HDInterval::hdi, qtiles.conf)
polygon(x=c(t.ageC, rev(t.ageC)), y=c(y.qtiles.ctrl[1, ], rev(y.qtiles.ctrl[2, ])), 
        col = grey_alpha3, border = grey_alpha3)

grey_alpha3 <- add.alpha("red", alpha=0.1)
# Survivors (note outer for r04 "survivor:age, r05 "survivor:age^2)
yy.S.mat <- r01 %o% t.ageC + r02 %o% t.ageC^2 + r04 %o% t.ageC + r05 %o% t.ageC^2
# don't forget to add r03 "survivor" as well as r00 intercept, but by sweep()
yy.S <- sweep(yy.S.mat, MARGIN = 1, FUN = "+", STATS = r00+r03)
y.mean.surv <- apply(yy.S, MARGIN = 2, mean)
y.qtiles.surv <- apply(yy.S, MARGIN = 2, HDInterval::hdi, qtiles.conf)
# shaded curves to show 50% quartiles
polygon(x=c(t.ageC, rev(t.ageC)), y=c(y.qtiles.surv[1, ], rev(y.qtiles.surv[2, ])), 
        col = grey_alpha3, border = grey_alpha3)

# looping over unique ids to add each person's observed changes over months
uniq_ids <- unique(dfc$study_id)
surv_col <- c("blue", "red")
surv_col <- add.alpha(surv_col, alpha = 0.2)

# individual person's observed scores
for (i in 1:length(uniq_ids)) {
  t.df <- dfc[dfc$study_id == uniq_ids[i], ]
  # browser()
  t.col <- surv_col[t.df$survivor+1][1]
  # ageC_enrl is centered age at enrollment. Need bg_Age which changes over time
  lines(t.df$bg_Age - avg.age.enrl, t.df$y, col = t.col)
  # add a circle to show each person's first score
  points(t.df$ageC_enrl[1], t.df$y[1], col = t.col, cex=0.5, pch=19)
  }

surv_col <- c("blue", "red")  # reset full colors, no added alpha
# Model-estimated averages on top of individual trajectories
lines(t.ageC, y.mean.ctrl, lwd = 2, col = surv_col[1])
lines(t.ageC, y.mean.surv, lwd = 2, col = surv_col[2])

# chronological age 60 is 60-72.58 because mean bg_Age=72.58
t.age.x <- seq(x_age_range[1]-avg.age.enrl, x_age_range[2]-avg.age.enrl, by = 5)
t.age.lab <- seq(x_age_range[1], x_age_range[2], by = 5) # 100 looks more even, although oldest was 99
axis(side = 1, at = t.age.x, labels = t.age.lab)
mtext("Chronological Age", side = 1, line = 3)
axis(side = 2)
mtext("Z-Score", side = 2, line = 3)
box()
title("Simulated Cognitive Assessments and 95% HDI")

# predict changes over months for a specific age=62, control
when.months <- c(0, 8, 16, 24)
when.age <- when.months/12      # where to plot on age scale

y_months <- function(enrl.ageC, f, is.survivor=0, 
                 when.months=c(0,8,16,24))   {
  # calculate is.age2, is.age3, is.age4 from age at enrollment 
  t.age <- cut(enrl.ageC + avg.age.enrl, c(60, 68, 72, 76, 89), include.lowest=TRUE,
        labels = c("60-68","69-72","73-76","77-89"))
  i.age <- c(0, 0, 0, 0)   # all age indicators initialized to zero
  t.i <- switch(as.character(t.age), "60-68" = 1, "69-72"=2, "73-76"=3, "77-89"=4)
  i.age[t.i] <- 1   # is.age2?  is.age3?  is.age4?

  y_pred_mat_fix <- f$r00 + f$r01*enrl.ageC + f$r02 * (enrl.ageC^2) + 
      f$r03 * (is.survivor) + f$r04*(is.survivor*enrl.ageC) + 
      f$r05 * (is.survivor*enrl.ageC^2)
  y_pred_mat_ran <- 
   ( f$r10 + f$r11*(is.survivor) + f$r12_2*(i.age[2]) +
     + f$r12_3*(i.age[3]) + f$r12_4*(i.age[4]) +
     + f$r13_2*(is.survivor)*(i.age[2]) +
     + f$r13_3*(is.survivor)*(i.age[3]) +
     + f$r13_4*(is.survivor)*(i.age[4])  ) %o% when.months
  y_pred_mat <- sweep(y_pred_mat_ran, 1, FUN="+", STAT = y_pred_mat_fix)
  y_pred_mean <- apply(y_pred_mat, 2, mean)
  y_pred_50hdi <- apply(y_pred_mat, 2, quantile, c(0.25, 0.75))
  # browser()
  ans <- list(y_pred_mean = y_pred_mean, y_pred_50hdi = y_pred_50hdi)
  return(ans)
}


# full MCMC matrices
f <- list(r00=r00, r01=r01, r02=r02, r03=r03, r04=r04, r05=r05, 
          r10=r10, r11=r11, r12_2=r12_2, r12_3=r12_3, r12_4=r12_4,
          r13_2=r13_2, r13_3=r13_3, r13_4=r13_4) 

# First practice effect example, age 65
y_mon0 <- y_months(enrl.ageC=65-avg.age.enrl, f=f) 
lines(x = (65-avg.age.enrl)+when.age, y = y_mon0$y_pred_mean, col = surv_col[1]) 
points(x = (65-avg.age.enrl)+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[1], cex = 0.7)

# another example, age 70
y_mon0 <- y_months(enrl.ageC=70-avg.age.enrl, f=f)
lines(x = 70-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[1])
points(x = 70-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[1], cex = 0.7)

# another example, age 75
y_mon0 <- y_months(enrl.ageC=75-avg.age.enrl, f=f)
lines(x = 75-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[1])
points(x = 75-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[1], cex = 0.7)

# age 80
y_mon0 <- y_months(enrl.ageC=80-avg.age.enrl, f=f)
lines(x = 80-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[1])
points(x = 80-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[1], cex = 0.7)

## Survivors
# predict changes over months for a specific age=62, control
#
enrl.ageC <- 65 - avg.age.enrl
y_mon0 <- y_months(enrl.ageC=65-avg.age.enrl, f=f, is.survivor=1)
lines(x = 65-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[2])
points(x = 65-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[2], cex = 0.7)

# another example, age 70
y_mon0 <- y_months(enrl.ageC=70-avg.age.enrl, f=f, is.survivor=1)
lines(x = 70-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[2])
points(x = 70-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[2], cex = 0.7)

# another example, age 75
enrl.ageC <- 75 - avg.age.enrl
y_mon0 <- y_months(enrl.ageC=75-avg.age.enrl, f=f, is.survivor=1)
lines(x = 75-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[2])
points(x = 75-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[2], cex = 0.7)

# age 80
y_mon0 <- y_months(enrl.ageC=80-avg.age.enrl, f=f, is.survivor=1)
lines(x = 80-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, col = surv_col[2])
points(x = 80-avg.age.enrl+when.age, y = y_mon0$y_pred_mean, pch =21, bg = surv_col[2], cex = 0.7)

surv_col <- c("blue", "red")
legend(x = "topright",
       legend = c("Controls", "Survivors"),
       lwd = 2, lty = 1, col = surv_col,
       bty = "n")  # suppress box around

# bayesplot::color_scheme_get("blue") shows several shades of blue
# for shaded mcmc_areas().  Use 3rd color for mid-saturated shade.
grey_alpha3 <- add.alpha("#6497b1", alpha=0.3)
###
# On the right, plot gap credible interval at 95%
###
qtiles.conf <- 0.95   # posterior HDI interval
with(dfc, plot(x=ageC_enrl, y=y, type="n", axes=FALSE, 
      xlim = x_age_range-avg.age.enrl, xlab="", ylab=""))
yy.d.mat <- yy.S - yy.C
lines(t.ageC, apply(yy.d.mat, 2, mean), col = "purple", lwd = 2)
y.qtiles.diff <- apply(yy.d.mat, MARGIN = 2, HDInterval::hdi, qtiles.conf)
# shaded curves to show HDI
polygon(x=c(t.ageC, rev(t.ageC)), y=c(y.qtiles.diff[1, ], rev(y.qtiles.diff[2, ])), 
        col = grey_alpha3, border = grey_alpha3)
abline(h = 0)
axis(side = 1, at = t.age.x, labels = t.age.lab)
mtext("Chronological Age", side = 1, line = 3)
axis(side = 2)
mtext("Difference (Survivor - Control)", side = 2, line = 3)
title("Average Gap (95% Credible Interval)")
box()

# darkest shade (6th) from bayesplot::color_scheme_get("blue")
grey_alpha3 <- add.alpha("#011f4b", alpha=0.3)
# find the age where the credible interval crosses the null.
# Easiest to do this manually, see where TRUE turns into FALSE
(y.qtiles.diff["upper", ] <= 0 & y.qtiles.diff['lower', ] <= 0)[245:248]
cat("age where credible interval crosses the null?\n")
print( t.ageC[245:248] + avg.age.enrl ) # between 72.25 and 72.30
# abline(v = t.ageC[237], col = grey_alpha3, lwd = 3)
library('shape')   # nice arrow head
shape::Arrows(x0=t.ageC[247], y0=0.6, x1=t.ageC[250], y1=0.12, lwd=2)
text("age=72.30", x = t.ageC[247], y = 0.8, adj = 0)

cat("turning graphics.off()\n")
graphics.off()

