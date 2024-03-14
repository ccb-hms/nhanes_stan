library(nhanesA)
library(phonto)

library(brms) # cmdstanr is also installed
library(modelr)

library(bayesplot)
library(tidybayes)
library(ggplot2)

# Pull data from the NHANES databse:
cols <- list(DEMO_I   = c("RIDAGEYR","RIAGENDR","RIDRETH1","DMDEDUC2"),
             DEMO_J   = c("RIDAGEYR","RIAGENDR","RIDRETH1","DMDEDUC2"),
             BPQ_I    = c('BPQ050A','BPQ020'),
             BPQ_J    = c('BPQ050A','BPQ020'),
             HDL_I    = c("LBDHDD"),
             HDL_J    = c("LBDHDD"), 
             TRIGLY_I = c("LBXTR","LBDLDL"),
             TRIGLY_J = c("LBXTR","LBDLDL"))

data <- jointQuery(cols)

# Take a small random subset so the example runs quickly:
small_subset <- data[sample(nrow(data), 200),]

small_subset[,c("RIDAGEYR", "RIAGENDR", "LBDHDD")] |>
  head(n = 10)

small_subset |>
  ggplot(aes(RIDAGEYR, LBDHDD)) +
  geom_point() + 
  facet_grid(cols = vars(RIAGENDR)) + 
  labs(x = "Age", y = "HDL")

# Run a linear model with HDL as the outcome variable and an interaction between
# age and gender as covariates:
age_gender_hdl_model <- brm(LBDHDD ~ RIDAGEYR*RIAGENDR,
                            data = small_subset)

# Look at the default priors brms chose:
age_gender_hdl_model |> prior_summary()

# Examine the trace plot of the interaction parameter to assess convergence:
age_gender_hdl_model |> mcmc_trace('b_RIDAGEYR:RIAGENDRMale')

# Examine the parameter estimates:
age_gender_hdl_model$fit |> 
  posterior::summarise_draws()

age_gender_hdl_model |> 
  mcmc_intervals('b_RIDAGEYR:RIAGENDRMale') + 
  geom_vline(xintercept = 0, lty = 2) + 
  xlim(NA, 0)

# Overlay the posterior predictive distribution on the data
small_subset |>
  data_grid(RIDAGEYR = seq_range(RIDAGEYR, 100),
            RIAGENDR,
            LBDHDD = 50) |> 
  add_predicted_draws(age_gender_hdl_model) |> 
  ggplot(aes(RIDAGEYR, LBDHDD)) +
  stat_lineribbon(aes(y = .prediction)) + 
  facet_grid(cols = vars(RIAGENDR)) + 
  geom_point(data = small_subset) + 
  scale_fill_brewer() + 
  labs(x = "Age", y = "HDL") + 
  theme_bw()
