FROM hmsccb/nhanes-workbench:version-0.4.1

RUN mkdir /install_stan /beautify_rstudio /.cmdstan
COPY ./beautify_rstudio.sh /beautify_rstudio/
#COPY ./rstudio-prefs.json /beautify_rstudio/
COPY ./rstudio-prefs.json /etc/rstudio
COPY ./.Rprofile /beautify_rstudio/
COPY ./demo.R /install_stan/
#COPY ./config.json /home/rstudio/.config/rstudio/
COPY ./install_stan.sh /install_stan/
#CMD ["mkdir", "/home/rstudio/.cmdstan/"]

RUN apt-get update && apt-get install -y --no-install-recommends libglpk-dev 

RUN chmod 700 /beautify_rstudio/beautify_rstudio.sh /install_stan/install_stan.sh
RUN /install_stan/install_stan.sh && /beautify_rstudio/beautify_rstudio.sh
#ENTRYPOINT "/beautify_rstudio/beautify_rstudio.sh"
