FROM rocker/shiny-verse:latest


# system libraries of general use
#RUN apt-get update && apt-get install -y \
#    sudo \
#   pandoc \
#    pandoc-citeproc \
#    libcurl4-gnutls-dev \
#    libcairo2-dev \
#    libxt-dev \
#    libssl-dev \
#    libssh2-1-dev
    #mkdir /var/lib/shiny-server/bookmarks/shiny

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  nano \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libssh2-1-dev \
  unixodbc-dev \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    shinydashboard \
    magrittr \
    DT \
    shinyWidgets \
    flexdashboard \
    haven \
    data.table \
    stringr \
    writexl \
    shinyBS \
  && rm -rf /tmp/downloaded_packages


COPY nhanesDS.Rproj /srv/shiny-server/
COPY nhanesSearch /srv/shiny-server/nhanesSearch
COPY dataFiles /srv/shiny-server/dataFiles

# allow permission
RUN chmod -R 777 /srv/shiny-server/

# select port
EXPOSE 3838



# run app
#CMD ["/usr/bin/shiny-server.sh"]
#CMD ["/usr/bin/shiny-server.sh"] 
#CMD ["R", "-e", "shiny::runApp(app, host = '0.0.0.0', port = 3838)"]

CMD ["/usr/bin/shiny-server"]