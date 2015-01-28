FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y

##############################################################################
## Global configuration

RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install --no-install-recommends -y sudo
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

##############################################################################
## Install tools

RUN mkdir /src

RUN apt-get install --no-install-recommends -y build-essential pkg-config automake \
                                               locales-all man-db manpages less manpages-dev \
                                               openssh-client tmux zsh vim-nox \
                                               git mercurial bzr tig git-flow \
                                               python3 python3-pip python python-pip ruby ruby-dev golang php5-cli php5-mysql nodejs npm \
                                               curl wget bind9-host netcat whois ca-certificates \
                                               silversearcher-ag sloccount zip unzip \
                                               libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
                                               optipng libtool nasm libjpeg-turbo-progs mysql-client nmap

# dpkg
RUN wget --quiet http://downloads.drone.io/master/drone.deb -O /src/drone.deb
RUN dpkg -i /src/drone.deb

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    ln -s /usr/bin/nodejs /usr/local/bin/node &&\
    echo 'error_reporting=E_ALL' > /etc/php5/cli/conf.d/99-dxw-errors.ini &&\
    echo 'phar.readonly = Off' > /etc/php5/cli/conf.d/99-dxw-phar.ini

# Install things with package managers
RUN gem install bundler && \
    pip install --upgrade fig && \
    npm install -g jshint grunt-cli bower

# wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod 755 /usr/local/bin/wp

# composer
RUN wget https://getcomposer.org/composer.phar -O /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer

# git tools
RUN git -C /src clone https://github.com/alberthier/git-webui.git

# Go tools
RUN GOPATH=/src/go go get github.com/holizz/pw && \
    GOPATH=/src/go go get github.com/holizz/diceware && \
    mv /src/go/bin/* /usr/local/bin/

##############################################################################
## Add user and dotfiles

RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core

ADD dotfiles/ /home/core/

# Copy in id_rsa
ADD keys/id_rsa /home/core/.ssh/id_rsa
# Symlink known_hosts
RUN ln -s /workbench/home/.ssh/known_hosts /home/core/.ssh/known_hosts

# Install vim plugins
RUN git -C /home/core/.vim/bundle clone https://github.com/kien/rainbow_parentheses.vim.git && \
    git -C /home/core/.vim/bundle clone https://github.com/sunaku/vim-unbundle.git && \
    git -C /home/core/.vim/bundle clone https://github.com/tpope/vim-commentary.git && \
    git -C /home/core/.vim/bundle clone https://github.com/tpope/vim-repeat.git && \
    git -C /home/core/.vim/bundle clone https://github.com/msanders/snipmate.vim.git && \
    git -C /home/core/.vim/bundle clone https://github.com/tpope/vim-surround.git && \
    git -C /home/core/.vim/bundle clone https://github.com/scrooloose/syntastic.git && \
    git -C /home/core/.vim/bundle clone https://github.com/fatih/vim-go.git && \
    git -C /home/core/.vim/bundle clone https://github.com/dxw/vim-php-indent.git

RUN chown -R core:core /home/core

##############################################################################
## Install tools from private repos

# Allow cloning private repos
RUN ssh-keyscan -t rsa git.dxw.net > /src/known_hosts && \
    /bin/echo -e '#!/bin/sh\nssh -i /home/core/.ssh/id_rsa -o "UserKnownHostsFile /src/known_hosts" $@' > /src/core-ssh.sh && \
    chmod 755 /src/core-ssh.sh

# pluginscan
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:tools/pluginscan2 pluginscan && \
    mkdir -p /usr/local/share/pluginscan && \
    cp -r /src/pluginscan/* /usr/local/share/pluginscan && \
    cd /usr/local/share/pluginscan && bundle install --path=vendor/bundle && \
    echo '#!/bin/sh' > /usr/local/bin/pluginscan && \
    echo 'BUNDLE_GEMFILE=/usr/local/share/pluginscan/Gemfile exec bundle exec /usr/local/share/pluginscan/bin/pluginscan' >> /usr/local/bin/pluginscan && \
    chmod 755 /usr/local/bin/pluginscan

# pupdate
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:plugin-updater && \
    cp -r /src/plugin-updater /usr/local/share/pupdate && \
    /bin/echo -e '#!/bin/sh\nset -e\ncd /usr/local/share/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > /usr/local/bin/pupdate && \
    chmod 755 /usr/local/bin/pupdate

# whippet
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone --recursive git@git.dxw.net:whippet/whippet && \
    cp -r /src/whippet /usr/local/share/whippet && \
    ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet

# phar-install
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:install-phar phar-install && \
    install /src/phar-install/bin/phar-install /usr/local/bin/phar-install

##############################################################################
## Startup

VOLUME /workbench
WORKDIR /workbench
USER core
CMD tmux -u2
