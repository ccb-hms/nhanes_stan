## ----------------------------------------------------------------------------------------------------------------
#| message: false
library(tidyverse)
library(brms)

theme_set(theme_light())

if (interactive()) options("mc.cores" = 4)


## ----------------------------------------------------------------------------------------------------------------
#| code-fold: false

set.seed(123)

n = 100
n_group = 6

alpha = .5
beta = 1

sd_a = 3

group_ints = rnorm(n_group, sd = sd_a)

sim_df_ri = tibble(x     = rnorm(n),
                   group = sample(n_group, size = n, replace = TRUE),
                   y     = rnorm(n , mean = (alpha + beta * x + group_ints[group]))) 
  


## ----------------------------------------------------------------------------------------------------------------
sim_df_ri |> 
    ggplot(aes(x,y)) + 
    geom_point(aes(color = factor(group))) + 
    facet_wrap("group")


## ----------------------------------------------------------------------------------------------------------------
#| message: false
sim_me = brm(y ~ x + (1 | group),
             data = sim_df_ri, 
             file = 'm_files/sim_df_ri',
             refresh = 100*interactive())



## ----------------------------------------------------------------------------------------------------------------
tibble(truth = group_ints, 
       est = ranef(sim_me)$group[,"Estimate","Intercept"]) |> 
    ggplot(aes(truth, est)) + 
    geom_point() + 
    geom_abline(lty = 2) + 
    labs(x = "True group-wise intercepts", 
         y = "Estimates")



## ----------------------------------------------------------------------------------------------------------------
#| eval: false
## pingu_me = brm(bill_depth ~ bill_length + (1|species),
##                data       = pingu,
##                cores      = n_core,
##                refresh    = 500*interactive(),
##              file = 'm_files/')


## ----------------------------------------------------------------------------------------------------------------
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

sim_df_ris = tibble(x     = rnorm(n),
                    group = sample(n_group, 
                                   size = n, 
                                   replace = TRUE),
                    y     = rnorm(n , mean = (alpha + beta * x +
                                              group_ints[group] +
                                              group_slopes[group] * x)))
  
sim_df_ris |> 
    ggplot(aes(x,y)) + 
    geom_point(aes(color = factor(group))) + 
    facet_wrap("group")

