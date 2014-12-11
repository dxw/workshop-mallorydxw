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

RUN apt-get install --no-install-recommends -y build-essential pkg-config automake
RUN apt-get install --no-install-recommends -y locales-all man-db manpages less
RUN apt-get install --no-install-recommends -y openssh-client
RUN apt-get install --no-install-recommends -y tmux zsh
RUN apt-get install --no-install-recommends -y git mercurial bzr tig
RUN apt-get install --no-install-recommends -y ca-certificates
RUN apt-get install --no-install-recommends -y python3 python3-pip python python-pip
RUN apt-get install --no-install-recommends -y vim-nox
RUN apt-get install --no-install-recommends -y ruby ruby-dev
RUN apt-get install --no-install-recommends -y curl wget
RUN apt-get install --no-install-recommends -y bind9-host
RUN apt-get install --no-install-recommends -y libpcre3-dev liblzma-dev
RUN apt-get install --no-install-recommends -y git-flow
RUN apt-get install --no-install-recommends -y golang
RUN apt-get install --no-install-recommends -y netcat
RUN apt-get install --no-install-recommends -y php5-cli php5-mysql
RUN apt-get install --no-install-recommends -y nodejs npm
RUN apt-get install --no-install-recommends -y silversearcher-ag
RUN apt-get install --no-install-recommends -y sloccount
RUN apt-get install --no-install-recommends -y zip unzip
RUN apt-get install --no-install-recommends -y libxml2-dev libxslt1-dev libmysql++-dev
RUN apt-get install --no-install-recommends -y libsqlite3-dev

# dpkg
RUN wget --quiet http://downloads.drone.io/master/drone.deb -O /src/drone.deb
RUN dpkg -i /src/drone.deb

# Ruby
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc
RUN gem install bundler

# Python
RUN pip install --upgrade fig

# Node
RUN ln -s /usr/bin/nodejs /usr/local/bin/node
RUN npm install -g jshint

# PHP
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
RUN chmod 755 /usr/local/bin/wp
RUN wget https://getcomposer.org/composer.phar -O /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

# Go
RUN GOPATH=/src/go go get github.com/holizz/pw
RUN GOPATH=/src/go go get github.com/holizz/diceware
RUN mv /src/go/bin/* /usr/local/bin/

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
RUN ssh-keyscan -t rsa git.dxw.net > /src/known_hosts
RUN /bin/echo -e '#!/bin/sh\nssh -i /home/core/.ssh/id_rsa -o "UserKnownHostsFile /src/known_hosts" $@' > /src/core-ssh.sh
RUN chmod 755 /src/core-ssh.sh

# pluginscan
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:tools/pluginscan2 pluginscan
RUN mkdir -p /usr/local/share/pluginscan
RUN cp -r /src/pluginscan/* /usr/local/share/pluginscan
RUN cd /usr/local/share/pluginscan && bundle install --path=vendor/bundle
RUN echo '#!/bin/sh' > /usr/local/bin/pluginscan
RUN echo 'BUNDLE_GEMFILE=/usr/local/share/pluginscan/Gemfile exec bundle exec /usr/local/share/pluginscan/bin/pluginscan' >> /usr/local/bin/pluginscan
RUN chmod 755 /usr/local/bin/pluginscan

# pupdate
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:plugin-updater
RUN cp -r /src/plugin-updater /usr/local/share/pupdate
RUN /bin/echo -e '#!/bin/sh\nset -e\ncd /usr/local/share/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > /usr/local/bin/pupdate
RUN chmod 755 /usr/local/bin/pupdate

# whippet
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone --recursive git@git.dxw.net:whippet/whippet
RUN cp -r /src/whippet /usr/local/share/whippet
RUN ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet

##############################################################################
## Startup

VOLUME /workbench
WORKDIR /workbench
USER core
CMD tmux -u2
