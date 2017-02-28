FROM ruby:2.3.0

VOLUME data
EXPOSE 9292

RUN mkdir -p /app/views
ADD Gemfile /app
ADD config.ru /app
ADD views /app/views
WORKDIR /app

RUN bundle install

ENTRYPOINT ["rackup", "--host", "0.0.0.0"]
