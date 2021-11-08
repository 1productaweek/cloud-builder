# FROM launcher.gcr.io/google/ubuntu1804
FROM ubuntu:groovy

ARG DEBIAN_FRONTEND=noninteractive

# Node
RUN apt-get -y update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get -y update && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt update && apt install yarn

# Util
RUN apt-get -y update && \
    apt-get -y install wget ca-certificates jq zip \ 
    # add codecs needed for video playback in firefox
    # https://github.com/cypress-io/cypress-docker-images/issues/150
    mplayer

# Chrome
RUN apt-get install -yq gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 \
libnss3 lsb-release xdg-utils


# Cypress
RUN apt-get -y update && apt-get install -yq libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# install Chrome browser
ENV CHROME_VERSION 85.0.4183.121
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# install Firefox browser
ARG FIREFOX_VERSION=81.0
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && ln -fs /opt/firefox/firefox /usr/bin/firefox

# Kubectl
# RUN apt-get install -y apt-transport-https gnupg2 && \
#    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
#    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list I && \
#    apt-get -y update && \
#    apt-get install -y kubectl


# K6
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61 && \
#    echo "deb https://dl.bintray.com/loadimpact/deb stable main" | tee -a /etc/apt/sources.list && \
#    apt-get -y update && \
#    apt-get -y install k6

# Docker
RUN apt-get -y install \
        # For multi-arch
        binfmt-support qemu-user-static \
        # Needed by Docker install
        apt-transport-https \
        ca-certificates \
        # curl \
        make \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       xenial \
       edge" && \
    apt-get -y update && \
    apt-get -y install docker-ce

COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx


# GCLOUD SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y  


# RUN curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && \
#  chmod +x cloud_sql_proxy && \
#  mkdir /cloudsql; chmod 777 /cloudsql

# BW
# COPY bw /usr/bin
# RUN chmod +x /usr/bin/bw

# AWS
#RUN apt-get -y update && apt-get install -y python3 python3-pip && \
#  pip3 install --upgrade ecs-deploy awscli

# Deploy
# RUN npm config set unsafe-perm true
RUN npm --version
RUN npm install -g @sentry/cli lerna netlify-cli firebase-tools