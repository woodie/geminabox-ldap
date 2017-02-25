FROM ruby:2.3.0

VOLUME data
EXPOSE 9292

RUN mkdir /app
WORKDIR /app
ADD . /app

RUN bundle install

ENTRYPOINT ["rackup", "--host", "0.0.0.0"]
