#!/bin/bash

# Move the 
# cp /beautify_rstudio/rstudio-prefs.json /etc/rstudio/

# Create the startup message
echo "cli::cli_alert_success('Welcome to the CCB NHANES+Stan Docker container!')" >> /usr/local/lib/R/etc/Rprofile.site

echo "cli::cli_alert_info('Learn how to use the {.pkg phonto} package here: {.url https://ccb-hms.github.io/phonto/}')" >> /usr/local/lib/R/etc/Rprofile.site
echo "cli::cli_alert_info('Learn about Stan modeling here: {.url https://mc-stan.org/docs/}')" >> /usr/local/lib/R/etc/Rprofile.site

# Set the cmdstan path
echo "suppressMessages(cmdstanr::set_cmdstan_path('/.cmdstan/cmdstan-2.34.1'))" >> /usr/local/lib/R/etc/Rprofile.site

# Open the demo R script. Might want to do this in a way that doesn't open every time the container starts.
echo "setHook('rstudio.sessionInit', function(newSession) {
  if (newSession) {
    rstudioapi::documentOpen('/install_stan/demo.R')
  }
}, action = 'append')" >> /usr/local/lib/R/etc/Rprofile.site


