FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y

##############################################################################
## Install tools

RUN apt-get install --no-install-recommends -y locales-all man-db manpages less
RUN apt-get install --no-install-recommends -y openssh-client sudo
RUN apt-get install --no-install-recommends -y tmux zsh
RUN apt-get install --no-install-recommends -y git mercurial bzr
RUN apt-get install --no-install-recommends -y ca-certificates
RUN apt-get install --no-install-recommends -y python3 python3-pip python python-pip
RUN apt-get install --no-install-recommends -y vim-nox

# Requires python2
RUN pip install fig

##############################################################################
## Add user

RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

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

##############################################################################
## Startup

VOLUME /workbench
WORKDIR /workbench
USER core
CMD tmux -u2
