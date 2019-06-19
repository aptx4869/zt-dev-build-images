FROM ruby:2.6

MAINTAINER aptx4869 'ling548@gmail.com'

ENV VERSION='2.1.0'

# RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ stretch main contrib non-free" > /etc/apt/sources.list

COPY build_deps /tmp/
COPY run_deps /tmp/

RUN set -ex \
      && export RUN_DEPS="$(cat /tmp/run_deps)" \
      && export BUILD_DEPS="$(cat /tmp/build_deps)" \
      && apt-get update \
      && apt-get install -y --no-install-recommends $BUILD_DEPS \
      && apt-get install -y --no-install-recommends $RUN_DEPS \
      && pip3 install you-get --upgrade

# Libvips
ADD https://github.com/libvips/libvips/releases/download/v8.8.0/vips-8.8.0.tar.gz /tmp/
# COPY vips-8.8.0.tar.gz /tmp/
RUN set -ex \
      && cd /tmp \
      && tar xf vips-8.8.0.tar.gz \
      && cd vips-8.8.0 \
      && ./configure --prefix=/usr/ \
      && make \
      && make install \
      && ldconfig \
      && pkg-config --list-all | grep 'vips'

# bundler
RUN gem install bundler --no-document

# MongoDB shell
RUN set -ex \
      && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
      && echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | \
      tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
      && apt-get update \
      && apt-get install -y mongodb-org-shell

# Nodejs
RUN set -ex \
      && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280 \
      && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
      && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
      && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
      && apt-get install -y nodejs \
      && apt-get install -y yarn \
      && yarn global add coffeescript js-yaml

# Googel Chrome
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /tmp/
RUN dpkg -i /tmp/google-chrome*.deb
ENV CHROME_BIN /usr/bin/google-chrome

# clean up
RUN set -ex \
      && export BUILD_DEPS="$(cat /tmp/build_deps)" \
      && apt-get purge -y --auto-remove $BUILD_DEPS \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && yarn cache clean \
      && cd ~ \
      && rm -rf /tmp/*

# RUN gem install ruby-vips && echo "require 'vips'" > hello_world.rb && ruby hello_world.rb
