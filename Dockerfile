FROM ubuntu:20.04

##############################################################################
## APT

ENV DEBIAN_FRONTEND noninteractive

# Unminimize Ubuntu
# This means man pages will be available
RUN yes | unminimize && \
    rm -r /var/lib/apt/lists/*

# Upgrade
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    rm -r /var/lib/apt/lists/*

# Install requirements for third-party sources
RUN apt-get update && \
    apt-get install --no-install-recommends -y apt-transport-https curl ca-certificates lsb-release gnupg software-properties-common && \
    rm -r /var/lib/apt/lists/*

# Install third-party sources
RUN curl -sS https://toolbelt.heroku.com/apt/release.key | apt-key add - && \
    echo "deb http://toolbelt.heroku.com/ubuntu ./" > /etc/apt/sources.list.d/heroku.list && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:rmescandon/yq

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        locales tzdata sudo \
        build-essential pkg-config automake software-properties-common \
        locales man-db manpages less manpages-dev \
        openssh-client tmux zsh vim-nox \
        git mercurial tig git-flow \
        python3 python3-pip python3-setuptools python3-wheel ruby ruby-dev bundler perl perl-doc golang \
        php-cli php-gd php-mbstring php-mysql php-xml php-curl php-xdebug php-gmp php-zip \
        wget bind9-host netcat whois dnsutils net-tools dialog \
        silversearcher-ag sloccount zip unzip parallel \
        libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
        optipng libtool nasm libjpeg-turbo-progs mysql-client nmap cloc ed ripmime oathtool cloc \
        libcurl4-openssl-dev libexpat1-dev gettext xsltproc xmlto iproute2 iputils-ping xmlstarlet tree jq libssl-dev \
        dsh libncurses5-dev graphicsmagick awscli yq \
        asciidoc docbook2x \
        shellcheck \
        heroku-toolbelt && \
    rm -r /var/lib/apt/lists/*

# So we don't need to run `apt update` every time we want to install something temporarily
RUN apt-get update

##############################################################################
## Global configuration

# Fix terminfo to prevent blinking
RUN infocmp linux | perl -pe 's/cnorm=\\E\[\?25h\\E\[\?0c/cnorm=\\E\[\?25h/' | tic -

# Fix "perl: warning: Setting locale failed."
RUN locale-gen en_US.UTF-8 en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8

# Set timezone
RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
# workaround: https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# Setup sudoers
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
# Workaround: https://bugs.launchpad.net/ubuntu/+source/sudo/+bug/1857036/comments/4
RUN echo 'Set disable_coredump false' >> /etc/sudo.conf

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    echo 'error_reporting=E_ALL' > /etc/php/7.4/cli/conf.d/99-dxw-errors.ini && \
    echo 'phar.readonly=Off' > /etc/php/7.4/cli/conf.d/99-dxw-phar.ini && \
    echo 'xdebug.var_display_max_depth=99999' > /etc/php/7.4/cli/conf.d/99-dxw-fix-xdebug-var-dump.ini && \
    /bin/echo -e '[mail function]\nsendmail_path = /bin/false' > /etc/php/7.4/cli/conf.d/99-dxw-disable-mail.ini

##############################################################################
## Install tools

RUN mkdir /src

# git next
RUN git clone https://github.com/git/git.git /src/git && \
    git -C /src/git switch next && \
    make -C /src/git prefix=/usr/local all doc info && \
    make -C /src/git prefix=/usr/local install install-doc install-html install-info && \
    rm -rf /src/git

# Ruby/Gem
RUN gem update --system
RUN gem install sass

# Install tools with go get
RUN GOPATH=/src/go go get github.com/holizz/renamer && \
    GOPATH=/src/go go get github.com/src-d/beanstool && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

RUN mkdir /src/go && \
    git clone https://github.com/grdl/git-get.git /src/go/git-get && \
    cd /src/go/git-get && \
    GOPATH=/src/go go build -o /usr/local/bin/git-get ./cmd/get && \
    GOPATH=/src/go go build -o /usr/local/bin/git-list ./cmd/list && \
    cd - && \
    rm -rf /src/go

# node
RUN mkdir /src/node && \
    wget --quiet https://nodejs.org/dist/v12.12.0/node-v12.12.0-linux-x64.tar.xz -O /src/node/node.tar.xz && \
    tar -C /src/node -xJf /src/node/node.tar.xz && \
    cp -a /src/node/*/* /usr/local/ && \
    rm -rf /src/node
# npx downloads packages from npm and runs them
# With typosquatting, that's a lot of risk
RUN rm /usr/local/bin/npx
# yarn
RUN npm install --global yarn

# Install tools with pip3
RUN pip3 install --upgrade docker-compose pipenv

# Install vim plugins
RUN mkdir -p /usr/share/vim/vimfiles/pack/bundle/start && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/tpope/vim-commentary.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/tpope/vim-repeat.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/msanders/snipmate.vim.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/tpope/vim-surround.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/scrooloose/syntastic.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/fatih/vim-go.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/dxw/vim-php-indent.git && \
    git -C /usr/share/vim/vimfiles/pack/bundle/start clone --quiet https://github.com/kassio/neoterm.git

# composer
RUN wget --quiet https://getcomposer.org/installer -O /src/composer-setup.php && \
    php /src/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm /src/composer-setup.php
ENV PATH=$PATH:/usr/local/lib/composer/vendor/bin:~/.composer/vendor/bin

# Install fzf
RUN gem install curses && \
    git clone --quiet --depth 1 https://github.com/junegunn/fzf.git /usr/local/fzf && \
    /usr/local/fzf/install --no-completion --no-key-bindings --no-update-rc && \
    ln -s ../fzf/bin/fzf /usr/local/bin/fzf

# Chef
# https://downloads.chef.io/chefdk
RUN wget --quiet https://packages.chef.io/files/stable/chefdk/4.6.35/ubuntu/18.04/chefdk_4.6.35-1_amd64.deb -O /src/chefdk.deb && \
    dpkg -i /src/chefdk.deb && \
    rm /src/chefdk.deb

# adr-tools
RUN git clone --quiet --depth 1 https://github.com/npryce/adr-tools.git /src/adr-tools && \
    mv /src/adr-tools/src/* /usr/local/bin/ && \
    rm -rf /src/adr-tools

# AWS
RUN curl https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb -o /src/session-manager-plugin.deb && \
    dpkg -i /src/session-manager-plugin.deb && \
    rm /src/session-manager-plugin.deb

# rbenv & ruby-build
# - for dalmatian
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    sh -c 'cd /usr/local/rbenv && src/configure && make -C src' && \
    ln -s ../rbenv/libexec/rbenv /usr/local/bin/ && \
    mkdir -p "$(rbenv root)"/plugins && \
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
    rbenv install 2.7.1

##############################################################################
## User-specific

RUN mkdir /home/core

# Add user
RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core
RUN chown -R core:core /home/core

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /src/rustup && \
    chmod 755 /src/rustup && \
    sudo -u core /src/rustup --no-modify-path -y && \
    rm /src/rustup
# Install extra tools with cargo
RUN sudo -u core ~core/.cargo/bin/cargo install cargo-edit
RUN sudo -u core ~core/.cargo/bin/cargo install git-absorb

# Dotfiles
COPY --chown=core:core dotfiles/ /home/core/

# bin
COPY --chown=core:core bin/ /usr/local/bin/

# ssh keys
RUN ln -s /workbench/home/.ssh/id_ed25519 /home/core/.ssh/id_ed25519
RUN ln -s /workbench/home/.ssh/id_ed25519.pub /home/core/.ssh/id_ed25519.pub

# AWS
RUN ln -s /workbench/home/.aws /home/core/.aws

# GPG
RUN ln -s /workbench/home/.gnupg /home/core/.gnupg

# Etc
RUN chown -R core:core /home/core

# Set runtime details
WORKDIR /workbench/src
USER core
VOLUME /workbench
CMD ["session-start"]
