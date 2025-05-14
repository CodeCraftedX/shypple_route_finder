FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.6.8

RUN bundle _2.6.8_ install

COPY . .

CMD ["ruby", "app/main.rb"]
