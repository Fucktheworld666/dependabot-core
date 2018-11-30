FROM dependabot/engine-base

# Install Ruby 2.5, update RubyGems, and install Bundler
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6 \
    && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu bionic main" > /etc/apt/sources.list.d/brightbox.list \
    && apt-get update \
    && apt-get install -y ruby2.5 ruby2.5-dev \
    && gem update --system 2.7.7 \
    && gem install --no-ri --no-rdoc bundler -v 2.0.0.pre.1

RUN useradd -m dependabot
WORKDIR /home/dependabot

### PYTHON
COPY --from=dependabot/engine-python --chown=dependabot /opt/engines/python /opt/engines/python
RUN echo "source '/opt/engines/python/env'" >> "$HOME/.bashrc"

# ---------------- OLD DOCKERFILE FROM HERE ONWARDS ----------------

### JAVASCRIPT

# Install Node 10.0 and Yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn


### ELM

# Install Elm 0.18 and Elm 0.19
ENV PATH="$PATH:/node_modules/.bin"
RUN npm install elm@0.18.0 \
    && wget "https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz" \
    && tar xzf binaries-for-linux.tar.gz \
    && mv elm /usr/local/bin/elm19 \
    && rm -f binaries-for-linux.tar.gz


### PHP

# Install PHP 7.2 and Composer
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list.d/ondrej-php.list \
    && echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get install -y php7.2 php7.2-xml php7.2-json php7.2-zip php7.2-mbstring php7.2-intl php7.2-common php7.2-gettext php7.2-curl php-xdebug php7.2-bcmath php-gmp php7.2-imagick php7.2-gd php7.2-redis php7.2-soap php7.2-ldap \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer


### GO

# Install Go and dep
RUN curl -O https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz \
    && tar xvf go1.11.2.linux-amd64.tar.gz \
    && wget https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 \
    && mv dep-linux-amd64 go/bin/dep \
    && chmod +x go/bin/dep \
    && mv go /root
ENV PATH=/root/go/bin:$PATH GOPATH=/opt/go


### ELIXIR

# Install Erlang, Elixir and Hex
ENV PATH="$PATH:/usr/local/elixir/bin"
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update \
    && apt-get install -y esl-erlang \
    && wget https://github.com/elixir-lang/elixir/releases/download/v1.7.4/Precompiled.zip \
    && unzip -d /usr/local/elixir -x Precompiled.zip \
    && rm -f Precompiled.zip \
    && mix local.hex --force


### RUST

# Install Rust 1.30.1
ENV RUSTUP_HOME=/opt/rust \
    PATH="${PATH}:/opt/rust/bin"
RUN export CARGO_HOME=/opt/rust ; curl https://sh.rustup.rs -sSf | sh -s -- -y