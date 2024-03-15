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

You can build the image with the following command from the top directory:

docker build -t nhanes-stan . --no-cache

And run it like so, after which it will be available in your browser at localhost:8787/

docker \
    run \
        --rm \
        --platform=linux/amd64 \
        --name nhanes-workbench \
        -d \
        -v LOCAL_DIRECTORY:/HostData \
        -p 8787:8787 \
        -p 2200:22 \
        -p 1433:1433 \
        -e 'CONTAINER_USER_USERNAME=USER' \
        -e 'CONTAINER_USER_PASSWORD=PASSWORD' \
        -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=yourStrong(!)Password' \
        nhanes-stan

