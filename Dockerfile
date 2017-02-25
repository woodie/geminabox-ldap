FROM ruby:2.3.0-onbuild

VOLUME data
EXPOSE 9292

ENTRYPOINT ["rackup", "--host", "0.0.0.0"]
