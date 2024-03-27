library(tidyverse)

library(nhanesA)
library(phonto)

library(lme4)
library(brms) # cmdstanr is also installed

library(bayesplot)
library(tidybayes)
library(modelr)

options("mc.cores" = 4)

# You are an epidemiologist studying the relationship between demographics and
# HDL levels. Let's look up some of the variable names in the NHANES database:

nhanesSearch("HDL") |>
    as_tibble() |> 
    print(n = 30)

# Okay, let's pull out the LBDHDD variable from the 2015-2018 period, along with
# some other demographic info looked up in the same way using the jointQuery()
# function from phonto:

cols <- list(DEMO_I   = c("RIDAGEYR", "RIAGENDR", "RIDRETH1", "DMDEDUC2"),
             DEMO_J   = c("RIDAGEYR", "RIAGENDR", "RIDRETH1", "DMDEDUC2"),
             BPQ_I    = c("BPQ050A", "BPQ020"),
             BPQ_J    = c("BPQ050A", "BPQ020"),
             HDL_I    = c("LBDHDD"),
             HDL_J    = c("LBDHDD"), 
             TRIGLY_I = c("LBXTR", "LBDLDL"),
             TRIGLY_J = c("LBXTR", "LBDLDL"))


data <- jointQuery(cols) |> 
    as_tibble()

set.seed(123)

# Take a small random subset so the example runs quickly:
small_subset <- data |> 
    slice_sample(n = 500)

# Examine it:
small_subset

small_subset |>
    select(RIDAGEYR, RIAGENDR, LBDHDD)

small_subset |> 
    summarise(across(everything(),
                     \(x) sum(is.na(x))))

small_subset |>
    ggplot(aes(RIDAGEYR, LBDHDD)) +
    geom_point() + 
    facet_grid(cols = vars(RIAGENDR)) + 
    labs(x = "Age", y = "HDL")


small_subset |>
    ggplot(aes(RIDAGEYR, LBDHDD)) +
    geom_point() + 
    facet_grid(cols = vars(RIAGENDR),
               rows = vars(RIDRETH1)) + 
    labs(x = "Age", y = "HDL")

# Model #1: Age*Gender interaction ----
# Run a linear model with HDL as the outcome variable and an interaction between
# age and gender as covariates:
ixn_model <- brm(LBDHDD ~ RIDAGEYR*RIAGENDR,
                 data = small_subset)

# Look at the default priors brms chose:
ixn_model |> prior_summary()

# Examine the trace plot of the interaction parameter to assess convergence:
ixn_model |> mcmc_trace("b_RIDAGEYR:RIAGENDRMale")

# Examine the parameter estimates:
ixn_model$fit |> 
    posterior::summarise_draws()

ixn_model |> 
    mcmc_intervals("b_RIDAGEYR:RIAGENDRMale") + 
    geom_vline(xintercept = 0, lty = 2) + 
    xlim(NA, 0)

# Overlay the posterior predictive distribution on the data
small_subset |>
    data_grid(RIDAGEYR = seq_range(RIDAGEYR, 100),
              RIAGENDR,
              LBDHDD = 50) |> 
    add_predicted_draws(ixn_model) |> 
    ggplot(aes(RIDAGEYR, LBDHDD)) +
    stat_lineribbon(aes(y = .prediction)) + 
    facet_grid(cols = vars(RIAGENDR)) + 
    geom_point(data = small_subset) + 
    scale_fill_brewer() + 
    labs(x = "Age", y = "HDL") + 
    theme_bw()

# Model #2: Incorporating race as a random intercept ----

# Maybe different ethnicities have varying baseline levels of HDL. Run a linear
# model with HDL as the outcome variable and an interaction between age and
# gender as covariates with a racial-group-wise random intercept:

small_subset |>
    ggplot(aes(RIDRETH1, LBDHDD, group = RIAGENDR)) +
    geom_point(position = position_jitterdodge(),
               aes(color = RIAGENDR))

small_subset |>
    ggplot(aes(RIDAGEYR, LBDHDD)) +
    geom_point() + 
    facet_grid(cols = vars(RIAGENDR), rows = vars(RIDRETH1)) + 
    labs(x = "Age", y = "HDL")

small_subset$RIDRETH1 |> table() |> sort() 

rand_int_model <- brm(LBDHDD ~ RIDAGEYR*RIAGENDR + (1|RIDRETH1),
                      data = small_subset)

# Model #3: Nesting ---- 

# Maybe there is no "global" effect of age. Maybe aging affects different
# demographics differently? Let's try a "nested" random effects model. This
# means there are random effects by the first grouping factor (gender here) and
# a second level of "nested" random effects layered on top of those. Note the
# notation on the right side of the vertical bar.

nested_model = brm(LBDHDD ~ (1 + RIDAGEYR | RIAGENDR/RIDRETH1),
                   data = small_subset)

# Even though the expression for this model is pretty short, we're starting to
# get a pretty high number of parameters. Do you notice any warnings? What how
# does lmer fare?

# Let's make the sampler take smaller steps and draw some additional iterations:
nested_model2 = update(nested_model,
                       control = list(adapt_delta = .975),
                       iter = 3000, warmup = 1000)

# LOO Comparison ----
# Look at information criteria and compare the models
loo(ixn_model)
loo(rand_int_model)
loo(nested_model2)

loo_compare(loo(ixn_model),
            loo(rand_int_model),
            loo(nested_model2))
