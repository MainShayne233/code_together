FROM noonat/rbenv-nodenv
MAINTAINER Nathan Ostgard <noonat@phuce.com>

ENV RUBY_VERSION=2.3.0 NODE_VERSION=0.12.7

RUN rbenv install $RUBY_VERSION && \
    CONFIGURE_OPTS="--disable-install-doc" rbenv global $RUBY_VERSION && \
    gem install bundler

RUN nodenv install $NODE_VERSION && \
    nodenv global $NODE_VERSION && \
    nodenv rehash

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 8080
CMD [ "npm", "start" ]
