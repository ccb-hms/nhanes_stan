FROM hmsccb/nhanes-workbench:version-0.4.1

RUN mkdir /install_stan /beautify_rstudio /.cmdstan
COPY ./rstudio-prefs.json /etc/rstudio
COPY ./beautify_rstudio.sh ./.Rprofile /beautify_rstudio/
COPY ./install_stan.sh ./memip_ws.R ./demo.R /install_stan/
RUN apt-get update && apt-get install -y --no-install-recommends libglpk-dev 
RUN chmod 700 /beautify_rstudio/beautify_rstudio.sh /install_stan/install_stan.sh
RUN chmod 777 /install_stan/demo.R
RUN /install_stan/install_stan.sh && /beautify_rstudio/beautify_rstudio.sh
#ENTRYPOINT "/beautify_rstudio/beautify_rstudio.sh"
