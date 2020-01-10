FROM ubuntu:19.10

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
    add-apt-repository ppa:git-core/ppa

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        locales tzdata sudo \
        build-essential pkg-config automake software-properties-common \
        locales man-db manpages less manpages-dev \
        openssh-client tmux zsh vim-nox \
        git mercurial bzr tig git-flow \
        python3 python3-pip python3-setuptools ruby ruby-dev bundler ruby-sass perl perl-doc golang \
        php-cli php-gd php-mbstring php-mysql php-xml php-curl php-xdebug php-gmp php-zip \
        wget bind9-host netcat whois dnsutils net-tools dialog \
        silversearcher-ag sloccount zip unzip parallel \
        libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
        optipng libtool nasm libjpeg-turbo-progs mysql-client nmap cloc ed ripmime oathtool cloc \
        libcurl4-openssl-dev libexpat1-dev gettext xsltproc xmlto iproute2 iputils-ping xmlstarlet tree jq libssl-dev \
        dsh libncurses5-dev graphicsmagick awscli \
        rustc cargo \
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

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    echo 'error_reporting=E_ALL' > /etc/php/7.3/cli/conf.d/99-dxw-errors.ini && \
    echo 'phar.readonly=Off' > /etc/php/7.3/cli/conf.d/99-dxw-phar.ini && \
    echo 'xdebug.var_display_max_depth=99999' > /etc/php/7.3/cli/conf.d/99-dxw-fix-xdebug-var-dump.ini && \
    /bin/echo -e '[mail function]\nsendmail_path = /bin/false' > /etc/php/7.3/cli/conf.d/99-dxw-disable-mail.ini

##############################################################################
## Install tools

RUN mkdir /src

# Rust/Cargo
RUN cargo install cargo-edit

# Ruby/Gem
RUN gem update --system

# Install tools with gem
RUN gem install sass

# Install tools with go get
RUN GOPATH=/src/go go get github.com/dxw/git-env && \
    GOPATH=/src/go go get github.com/holizz/pw && \
    GOPATH=/src/go go get github.com/holizz/diceware && \
    GOPATH=/src/go go get github.com/holizz/renamer && \
    GOPATH=/src/go go get github.com/src-d/beanstool && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# Install tools with pip3
RUN pip3 install --upgrade docker-compose

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

# Install vim-go dependencies
# https://github.com/fatih/vim-go/blob/master/plugin/go.vim
RUN PATH=$PATH:/usr/local/go/bin GOPATH=/src/go sh -c '\
    go get github.com/nsf/gocode && \
    go get golang.org/x/tools/cmd/goimports && \
    go get github.com/rogpeppe/godef && \
    go get golang.org/x/tools/cmd/guru && \
    go get golang.org/x/tools/cmd/gorename && \
    go get golang.org/x/lint/golint && \
    go get github.com/kisielk/errcheck && \
    go get github.com/jstemmer/gotags && \
    go get github.com/alecthomas/gometalinter && \
    go get github.com/klauspost/asmfmt/cmd/asmfmt && \
    go get github.com/fatih/motion && \
    go get github.com/josharian/impl && \
    true' && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# composer
RUN wget --quiet `curl -s https://api.github.com/repos/composer/composer/releases/latest | jq -r '.assets[0].browser_download_url'` -O /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer
ENV PATH=$PATH:/usr/local/lib/composer/vendor/bin:~/.composer/vendor/bin

# Install fzf
RUN gem install curses && \
    git clone --quiet --depth 1 https://github.com/junegunn/fzf.git /usr/local/fzf && \
    /usr/local/fzf/install --no-completion --no-key-bindings --no-update-rc && \
    ln -s  ../fzf/bin/fzf /usr/local/bin/fzf

# Other tools
RUN git -C /src clone --quiet --recursive https://github.com/dxw/srdb.git && \
    mv /src/srdb /usr/local/share/ && \
    ln -s /usr/local/share/srdb/srdb /usr/local/bin/srdb
RUN git -C /src clone --quiet --recursive https://github.com/dxw/whippet && \
    mv /src/whippet /usr/local/share/ && \
    ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet

# Chef
# https://downloads.chef.io/chefdk
RUN wget --quiet https://packages.chef.io/files/stable/chefdk/4.6.35/ubuntu/18.04/chefdk_4.6.35-1_amd64.deb -O /src/chefdk.deb && \
    dpkg -i /src/chefdk.deb && \
    rm /src/chefdk.deb

##############################################################################
## User-specific

RUN mkdir /home/core

# Add user
RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core

# Dotfiles
COPY dotfiles/ /home/core/

# bin
COPY bin/ /usr/local/bin/

# ssh keys
RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa
RUN ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub
RUN ln -s /workbench/home/.ssh/id_ed25519 /home/core/.ssh/id_ed25519
RUN ln -s /workbench/home/.ssh/id_ed25519.pub /home/core/.ssh/id_ed25519.pub

# GPG
RUN ln -s /workbench/home/.gnupg /home/core/.gnupg

# Etc
RUN chown -R core:core /home/core

# Set runtime details
WORKDIR /workbench/src
USER core
VOLUME /workbench
CMD ["tmux", "-u2"]
