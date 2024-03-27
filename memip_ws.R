## -----------------------------------------------------------------------------------------------------------------
#| message: false
library(tidyverse)
library(brms)
library(lme4)

theme_set(theme_light())

if (interactive()) options("mc.cores" = 4)


## -----------------------------------------------------------------------------------------------------------------
#| code-fold: false

set.seed(123)

n = 100
n_group = 6

alpha = .5
beta = 1

sd_a = 3

group_ints = rnorm(n_group, sd = sd_a)

sim_df1 = tibble(x     = rnorm(n),
                 group = sample(n_group, size = n, replace = TRUE),
                 y     = rnorm(n , mean = (alpha + beta * x + group_ints[group]))) 
  


## -----------------------------------------------------------------------------------------------------------------
#| code-fold: true
sim_df1 |> 
    ggplot(aes(x,y)) + 
    geom_point(aes(color = factor(group))) + 
    facet_wrap("group")


## -----------------------------------------------------------------------------------------------------------------
#| message: false

sim1_lmer = lmer(y ~ x + (1 | group),
                 data = sim_df1)

sim1_lmer


## -----------------------------------------------------------------------------------------------------------------
sim1_brms = brm(y ~ x + (1 | group),
                data    = sim_df1, 
                file    = 'm_files/sim_df1',
                refresh = 100*interactive())

sim1_brms


## -----------------------------------------------------------------------------------------------------------------
#| code-fold: true
tibble(truth = group_ints, 
       est = ranef(sim1_brms)$group[,"Estimate","Intercept"]) |> 
    ggplot(aes(truth, est)) + 
    geom_point() + 
    geom_abline(lty = 2) + 
    labs(x = "True group-wise intercepts", 
         y = "Estimates")



## -----------------------------------------------------------------------------------------------------------------
n = 100
n_group = 6

alpha = .5
beta = 1

sd_a = 3
sd_b = 1

sd_vec = c(sd_a, sd_b)

cor_mat = matrix(c(1, .5, .5, 1), nrow = 2)

cov_mat = diag(sd_vec) %*% cor_mat %*% diag(sd_vec)

ab_mat = MASS::mvrnorm(n_group,
                       mu = c(0,0),
                       Sigma = cov_mat)

group_ints = ab_mat[,1]
group_slopes = ab_mat[,2]

sim_df2 = tibble(x     = rnorm(n),
                 group = sample(n_group, 
                                size = n, 
                                replace = TRUE),
                 y     = rnorm(n , mean = (alpha + beta * x +
                                           group_ints[group] +
                                           group_slopes[group] * x)))



## -----------------------------------------------------------------------------------------------------------------
#| code-fold: true
sim_df2 |> 
    ggplot(aes(x,y)) + 
    geom_point(aes(color = factor(group))) + 
    facet_wrap("group")


## -----------------------------------------------------------------------------------------------------------------
sim2_lmer = lmer(y ~ 1 + x + (1 + x | group),
                 data = sim_df2)

sim2_brms = brm(y ~ 1 + x + (1 + x | group),
                data = sim_df2,
                file = "m_files/sim_df2",
                refresh = 500*interactive())

