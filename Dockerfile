FROM ruby:latest
ADD . .
RUN bundle install
