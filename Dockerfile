FROM ruby:3.2.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

WORKDIR /usr/src/mr_peanutbutter

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bash"]
