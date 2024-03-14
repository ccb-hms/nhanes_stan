This dockerfile:

- Starts from nhanes-workbench:version-0.4.1
- Installs:
    - R packages: cmdstanr, bayesplot, posterior, brms
    - CmdStan
- Changes the look of RStudio:
    - Re-arranged panes
    - Dark theme
    - Fira Code font (ligatures)
- Adds a helpful startup message in the .Rprofile
- Opens a demo script

TOFIX:
- Choose a more biological / interesting demo model?
- Is there an rstudio initialization hook to minimize the history pane?
