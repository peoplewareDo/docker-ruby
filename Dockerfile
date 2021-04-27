FROM debian:jessie
MAINTAINER Jimmy Cuadra <jimmy@jimmycuadra.com>

RUN echo 'gem: --no-document' > /usr/local/etc/gemrc && \
  echo 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8' | debconf-set-selections && \
  echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections

ENV RUBY_MAJOR_MINOR_VERSION 2.7
ENV RUBY_VERSION 2.7.3
ENV RUBY_TARBALL_SHA512 e9236138be3e61380140f2e0d42f8fb82ad8f5219d454de2f6c2ec546bb208acc8b0f2020f23e6446660d2b3b9ae873cdd8298471f166a5f1efba8e80b05e746
ENV GEM_HOME /usr/local/lib/ruby/gems/${RUBY_MAJOR_MINOR_VERSION}.0
ENV LANG en_US.UTF-8

RUN apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qy --no-install-recommends install \
    build-essential \
    ca-certificates \
    curl \
    libffi-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    locales \
    zlib1g-dev && \
  curl -s -O https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_MINOR_VERSION/ruby-$RUBY_VERSION.tar.bz2 && \
  [ $(sha512sum ruby-$RUBY_VERSION.tar.bz2 | awk '{ print $1 }') = $RUBY_TARBALL_SHA512 ] && \
  tar -jxf ruby-$RUBY_VERSION.tar.bz2 && \
  cd ruby-$RUBY_VERSION && \
  ./configure --disable-install-doc && \
  make -j$(nproc) && \
  make install && \
  gem update --system && \
  cd .. && \
  rm -rf ruby-$RUBY_VERSION ruby-$RUBY_VERSION.tar.bz2 /tmp/* /var/tmp/* && \
  apt-get -qy clean autoclean autoremove && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/
