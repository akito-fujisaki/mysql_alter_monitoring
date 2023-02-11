FROM ruby:3.2.0-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libmariadb-dev-compat \
      libmariadb-dev \
      mariadb-client && \
    apt-get clean

WORKDIR /src

COPY bin/setup ./bin/
COPY Gemfile Gemfile.lock mysql_alter_monitoring.gemspec ./
COPY lib/mysql_alter_monitoring/version.rb ./lib/mysql_alter_monitoring/

RUN bin/setup
