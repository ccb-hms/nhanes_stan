#!/bin/bash

set -e

install2.r --error --skipinstalled -r https://mc-stan.org/r-packages/ -r getOption \
    cmdstanr \
    bayesplot \
    posterior \
    brms \
    tidybayes \
    palmerpenguins \
    Matrix

R -q -e "cmdstanr::check_cmdstan_toolchain()"
#R -q -e "dir.create('/home/rstudio/.cmdstan')"
chmod -R 777 /.cmdstan/
R -q -e "cmdstanr::install_cmdstan(dir = '/.cmdstan/', 
                                   release_url = 'https://github.com/stan-dev/cmdstan/releases/download/v2.34.1/cmdstan-2.34.1.tar.gz')"

chmod -R 777 /.cmdstan/
