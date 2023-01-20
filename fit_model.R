###
# run this after gen_simulated_data.R
###
library('rstanarm')
options(mc.cores = parallel::detectCores())

mod1 <- stan_lmer(y ~ ageC_enrl + I(ageC_enrl^2) + survivor + 
	ageC_enrl:survivor + I(ageC_enrl^2):survivor + time_months + 
	survivor:time_months + age4C:time_months + 
	age4C:survivor:time_months + (1 + time_months | id), 
        chains = 4, warmup = 1000, thin = 5, iter=6000, data = dfc)

# print fixed effects estimates
summary(mod1, pars = c("ageC_enrl","I(ageC_enrl^2)","survivor",
	"ageC_enrl:survivor","I(ageC_enrl^2):survivor",
	"time_months","survivor:time_months", "time_months:age4C69-71",
        "time_months:age4C72-74", "time_months:age4C75-90",
        "survivor:time_months:age4C69-71", 
	"survivor:time_months:age4C72-74",
        "survivor:time_months:age4C75-90"), 
	probability = c(0.025, 0.10, 0.5, 0.90, 0.975), digits = 3)

# random effects
summary(mod1, pars = c("Sigma[id:(Intercept),(Intercept)]",
        "Sigma[id:time_months,(Intercept)]",
        "Sigma[id:time_months,time_months]"), 
	probability = c(0.025, 0.10, 0.5, 0.90, 0.975), digits = 5)

