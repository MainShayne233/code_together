# credit to whitfieldc
# docker build -t code_exe_api .
# docker run -t code_exe_api .
# docker run -p 8880:8888 --name test code_exe_api
# docker run -d -p 8880:8888 --name test code_exe_api
from elixir

ENV RUBY_VERSION 2.3.0
ENV RUBY_DIR /user/local/ruby
ENV PATH "$PATH:$RUBY_DIR/bin"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && apt-get update -qqy \
 && apt-get install -qqy \
      unzip \
      locales \
      git-core \
      curl \
      zlib1g-dev \
      build-essential \
      libssl-dev \
      libreadline-dev \
      libyaml-dev \
      libsqlite3-dev \
      sqlite3 \
      libxml2-dev \
      libxslt1-dev \
      libcurl4-openssl-dev \
      python-software-properties \
      libffi-dev \
      nodejs \
      wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR $RUBY_DIR

RUN wget http://ftp.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.gz \
&& tar -xzvf ruby-2.3.3.tar.gz \
&& cd ruby-2.3.3/ \
&& ./configure \
&& make \
&& make install

WORKDIR /usr/local/app
COPY . /usr/local/app

RUN mix local.hex --force \
 && mix deps.get

EXPOSE 8080
CMD ["mix", "compile"]
CMD ["mix", "run", "--no-halt"]
