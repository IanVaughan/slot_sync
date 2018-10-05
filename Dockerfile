FROM elixir:1.6.0 as builder
MAINTAINER dev@quiqup.com

ENV INSTALL_DEPS="git build-essential libssl1.0.0 libssl-dev inotify-tools imagemagick openssh-client"

RUN \
    apt-get -qq update && \
    apt-get -qq install ${INSTALL_DEPS}

RUN \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

# Copy repository into docker container under /app
WORKDIR /app
COPY . .

ENV MIX_ENV prod
RUN mix do deps.get
RUN mix do deps.compile
RUN mix compile
RUN mix release

FROM debian:stable-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y locales curl redis-tools jq

# Set LOCALE to UTF8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
# Add jessie-backports for oldstable libssl1.0.0
RUN echo 'deb http://ftp.uk.debian.org/debian jessie-backports main' >> /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -qq install libssl1.0.0 libssl-dev
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/slot_sync ./

CMD ["./bin/slot_sync","foreground"]
