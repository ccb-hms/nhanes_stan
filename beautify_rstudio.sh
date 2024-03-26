#!/bin/bash

# Set the cmdstan path

# Open the demo R script. Might want to do this in a way that doesn't open every time the container starts.
echo "setHook('rstudio.sessionInit', function(newSession) {
    if (newSession) {
        # Create the startup message
        cli::cli_alert_success('Welcome to the CCB NHANES+Stan Docker container!')
        cli::cli_alert_info('Learn how to use the {.pkg phonto} package here: {.url https://ccb-hms.github.io/phonto/}')
        cli::cli_alert_info('Learn about Stan modeling here: {.url https://mc-stan.org/docs/}')
        
        rstudioapi::documentOpen('/install_stan/memip_ws.R')
        rstudioapi::documentOpen('/install_stan/demo.R')
    }
}, action = 'append')" >> /usr/local/lib/R/etc/Rprofile.site


