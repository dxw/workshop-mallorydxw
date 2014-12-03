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

RUN apt-get install --no-install-recommends -y locales-all man-db manpages less
RUN apt-get install --no-install-recommends -y openssh-client
RUN apt-get install --no-install-recommends -y tmux zsh
RUN apt-get install --no-install-recommends -y git mercurial bzr tig
RUN apt-get install --no-install-recommends -y ca-certificates
RUN apt-get install --no-install-recommends -y python3 python3-pip python python-pip
RUN apt-get install --no-install-recommends -y vim-nox
RUN apt-get install --no-install-recommends -y ruby
RUN apt-get install --no-install-recommends -y curl wget
RUN apt-get install --no-install-recommends -y bind9-host
RUN apt-get install --no-install-recommends -y build-essential pkg-config automake
RUN apt-get install --no-install-recommends -y libpcre3-dev liblzma-dev
RUN apt-get install --no-install-recommends -y git-flow
RUN apt-get install --no-install-recommends -y golang php5-cli nodejs
RUN apt-get install --no-install-recommends -y netcat

# fig
RUN pip install --upgrade fig

# ag
RUN git -C /src clone https://github.com/ggreer/the_silver_searcher.git
RUN cd /src/the_silver_searcher && ./build.sh --prefix=/usr/local
RUN make -C /src/the_silver_searcher install

# drone
RUN wget --quiet http://downloads.drone.io/master/drone.deb -O /src/drone.deb
RUN dpkg -i /src/drone.deb

# Fix rubygems
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc

# Bundler
RUN gem install bundler

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
RUN /bin/echo -e '#!/bin/sh\nssh -i /home/core/.ssh/id_rsa -o "UserKnownHostsFile /src/known_hosts" $@' > /src/core-ssh.sh && chmod 755 /src/core-ssh.sh

# pluginscan
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:tools/pluginscan2 pluginscan
RUN mkdir -p /usr/local/share/pluginscan
RUN cp -r /src/pluginscan/* /usr/local/share/pluginscan
RUN cd /usr/local/share/pluginscan && bundle install --path=vendor/bundle
# Make the executable
RUN echo '#!/bin/sh' > /usr/local/bin/pluginscan
RUN echo 'BUNDLE_GEMFILE=/usr/local/share/pluginscan/Gemfile exec bundle exec /usr/local/share/pluginscan/bin/pluginscan' >> /usr/local/bin/pluginscan
RUN chmod 755 /usr/local/bin/pluginscan

# pupdate
RUN GIT_SSH=/src/core-ssh.sh git -C /src clone git@git.dxw.net:plugin-updater
RUN cp -r /src/plugin-updater /usr/local/share/pupdate
RUN /bin/echo -e '#!/bin/sh\nset -e\ncd /usr/local/share/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > /usr/local/bin/pupdate
RUN chmod 755 /usr/local/bin/pupdate

##############################################################################
## Startup

VOLUME /workbench
WORKDIR /workbench
USER core
CMD tmux -u2
