FROM ruby:2.4
WORKDIR /usr/src/app
COPY Gemfile* /usr/src/app
RUN bundle install
COPY . /usr/src/app
CMD "/usr/src/app/startracker.rb"