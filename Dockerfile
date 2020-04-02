FROM ruby:2.7.1-alpine

ENV APP_USER appuser
ENV APP_FOLDER /app
ENV PORT 3000
ENV RAILS_ENV development
ENV POOL_SIZE 25
ENV BUILD_PACKAGES alpine-sdk \
                   git \
                   sqlite \
                   sqlite-dev

EXPOSE $PORT

COPY . $APP_FOLDER

WORKDIR $APP_FOLDER

RUN apk --update add --no-cache $BUILD_PACKAGES && \
    gem install bundler && \
    echo 'gem: --no-rdoc --no-ri' > ~/.gemrc && \
    bundle install --clean --jobs 4 && \
    addgroup -g 1000 -S $APP_USER && \
    adduser -u 1000 -S $APP_USER -G $APP_USER && \
    chown -R $APP_USER:$APP_USER $APP_FOLDER /usr/local/bundle

USER $APP_USER

CMD ["bundle", "exec"]
