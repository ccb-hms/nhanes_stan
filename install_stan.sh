#!/bin/bash

set -e

install2.r --error --skipinstalled -r https://mc-stan.org/r-packages/ -r getOption \
    cmdstanr \

install2.r --error Matrix \
    lme4 \
    bayesplot \
    posterior \
    brms \
    tidybayes \
    palmerpenguins \

R -q -e "cmdstanr::check_cmdstan_toolchain()"
#R -q -e "dir.create('/home/rstudio/.cmdstan')"
chmod -R 777 /.cmdstan/
R -q -e "cmdstanr::install_cmdstan(dir = '/.cmdstan/', 
                                   release_url = 'https://github.com/stan-dev/cmdstan/releases/download/v2.34.1/cmdstan-2.34.1.tar.gz')"

chmod -R 777 /.cmdstan/

echo "suppressMessages(cmdstanr::set_cmdstan_path('/.cmdstan/cmdstan-2.34.1'))" >> /usr/local/lib/R/etc/Rprofile.site
