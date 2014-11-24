FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y

##############################################################################
## Startup

VOLUME /workbench
WORKDIR /workbench
USER core
CMD tmux -u2

##############################################################################
## Global configuration

RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

##############################################################################
## Add user

RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

##############################################################################
## Install tools

RUN mkdir /src

RUN apt-get install --no-install-recommends -y locales-all man-db manpages less
RUN apt-get install --no-install-recommends -y openssh-client sudo
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

# fig
RUN pip install --upgrade fig

# ag
RUN git -C /src clone https://github.com/ggreer/the_silver_searcher.git
RUN cd /src/the_silver_searcher && ./build.sh --prefix=/usr/local
RUN make -C /src/the_silver_searcher install

# drone
RUN wget --quiet http://downloads.drone.io/master/drone.deb -O /src/drone.deb
RUN dpkg -i /src/drone.deb

# # pluginscan
# RUN gem install bundler
# RUN git -C /src clone git@git.dxw.net:tools/pluginscan2 pluginscan
# RUN mkdir -p /usr/local/share/pluginscan
# RUN cp -r /src/pluginscan/* /usr/local/share/pluginscan
# RUN cd /usr/local/share/pluginscan && bundle install --path=vendor/bundle
# # Make the executable
# RUN echo '#!/bin/sh' > /usr/local/bin/pluginscan
# RUN echo 'BUNDLE_GEMFILE=/usr/local/share/pluginscan/Gemfile exec bundle exec /usr/local/share/pluginscan/bin/pluginscan' >> /usr/local/bin/pluginscan
# RUN chmod 755 /usr/local/bin/pluginscan

# pupdate
# ADD bin /src/bin
# RUN git -C /src clone git@git.dxw.net:plugin-updater
# RUN cp -r /src/plugin-updater /usr/local/share/pupdate
# RUN sed 's#___#/usr/local/share/pupdate#g' < pupdate > /usr/local/bin/pupdate
# RUN chmod 755 /usr/local/bin/pupdate

##############################################################################
## Add dotfiles

ADD dotfiles/ /home/core/
ADD keys/id_rsa /home/core/.ssh/id_rsa

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
