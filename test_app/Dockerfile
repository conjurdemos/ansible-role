FROM ubuntu:16.04

MAINTAINER Kumbirai Tanekha <kumbirai.tanekha@cyberark.com>

RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:brightbox/ruby-ng && \
    apt-get update -y

RUN apt-get install -y ruby2.4 ruby2.4-dev python && apt-get update && apt-get install -y gcc build-essential

RUN apt-get update && apt-get install -y curl sudo

RUN gem install bundler --no-rdoc --no-ri

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY Gemfile /opt/app/
RUN bundle install

COPY . /opt/app

ENV APP_NAME=test_app
RUN mv /opt/app/service/initd.sh /etc/init.d/$APP_NAME
RUN update-rc.d $APP_NAME defaults
