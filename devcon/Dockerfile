FROM ubuntu:22.04


## R installation, required R-Markdown
# Based on https://linuxize.com/post/how-to-install-r-on-ubuntu-20-04/
# (plus JRE and net-tools which could be useful)
RUN  apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        dirmngr \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        build-essential \
  && \
     apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 \
  && \
     add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/' \
  && \
     apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        r-base \
  && \
     rm -rf /var/lib/apt/lists/*

## R-Markdown installation (and it's deps besides R)
# based on https://bookdown.org/yihui/rmarkdown/installation.html

RUN  apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        pandoc \
        pandoc-citeproc \
        curl \
        openssl \
        librsvg2-bin \
        libcurl4-gnutls-dev \
        libxml2-dev \
        libssl-dev \
  && \
     rm -rf /var/lib/apt/lists/*

RUN  R -e "install.packages('rmarkdown', dep = TRUE)"
RUN  R -e "install.packages('tinytex', dep=TRUE)"
RUN  R -e "tinytex::install_tinytex()"
RUN  R -e "install.packages('languageserver', repos='https://cloud.r-project.org/', dep = TRUE)"
RUN  R -e "install.packages('bookdown', dep = TRUE)"

## Misc python things that are used for books production
RUN  apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        python3-pip \
  && \
     rm -rf /var/lib/apt/lists/* \
  && python3 -m pip install requests

## Locale setup
RUN apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        locales \
  && \
    locale-gen en_US \
  && \
    locale-gen en_US.UTF-8 \
  && \
    locale-gen ru_RU \
  && \
    locale-gen ru_RU.UTF-8 \
  && \
    update-locale \
  && \
     rm -rf /var/lib/apt/lists/*

## All the missing things (it's here since R installation take a lot of ime)
RUN apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        texlive-xetex \
        texlive-latex-extra \
        lmodern \
        texlive-fonts-recommended \
        texlive-lang-* \
  && \
     rm -rf /var/lib/apt/lists/*

## Libre office
RUN apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        git \
        default-jre \
        libreoffice-base \
        libreoffice \
  && \
     rm -rf /var/lib/apt/lists/*

## All the missing things #2
RUN apt-get update \
  && \
     DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        libarchive-tools \
  && \
     rm -rf /var/lib/apt/lists/*

## VSCode Server
# https://github.com/coder/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# TODO: draw.io

# ## Some useful tools that could be required for books production
# RUN  apt-get update \
#   && \
#      DEBIAN_FRONTEND=noninteractive apt-get install \
#      -y --no-install-recommends \
#         default-jre \
#         net-tools \
#   && \
#      rm -rf /var/lib/apt/lists/*

## User related stuff
ARG UID=1000
ARG GID=1000
ARG PWD=2OYyoafdd2RFtSB8L1y
ARG UNAME=code

RUN  groupadd -g ${GID} ${UNAME} \
  && useradd -m -u ${UID} -g ${GID} ${UNAME} \
  && echo "${UNAME}:${PWD}" | chpasswd

WORKDIR /home/${UNAME}

USER ${UNAME}
