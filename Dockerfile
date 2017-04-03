FROM thedxw/workshop

# Switch WORKDIR/USER temporarily
WORKDIR /
USER root

# Set timezone
RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
# workaround: https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# Install more packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y dsh libncurses5-dev && \
    rm -r /var/lib/apt/lists/*

# Install latest version of tig
RUN git clone https://github.com/jonas/tig.git /src/tig && \
    git -C /src/tig checkout tig-2.2.1 && \
    make -C /src/tig prefix=/usr/local install install-doc

# So we don't need to run `apt update` every time we want to install something temporarily
RUN apt-get update

# Install vim-go dependencies
# https://github.com/fatih/vim-go/blob/master/plugin/go.vim
RUN PATH=$PATH:/usr/local/go/bin GOPATH=/src/go sh -c '\
    go get github.com/nsf/gocode && \
    go get golang.org/x/tools/cmd/goimports && \
    go get github.com/rogpeppe/godef && \
    go get golang.org/x/tools/cmd/guru && \
    go get golang.org/x/tools/cmd/gorename && \
    go get github.com/golang/lint/golint && \
    go get github.com/kisielk/errcheck && \
    go get github.com/jstemmer/gotags && \
    go get github.com/alecthomas/gometalinter && \
    go get github.com/klauspost/asmfmt/cmd/asmfmt && \
    go get github.com/fatih/motion && \
    go get github.com/josharian/impl && \
    true' && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# Dotfiles
COPY dotfiles/ /home/core/

# bin
COPY bin/ /usr/local/bin/

# Install vim plugins
RUN mkdir -p /home/core/.vim/bundle && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/kien/rainbow_parentheses.vim.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/sunaku/vim-unbundle.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/tpope/vim-commentary.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/tpope/vim-repeat.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/msanders/snipmate.vim.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/tpope/vim-surround.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/scrooloose/syntastic.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/fatih/vim-go.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/dxw/vim-php-indent.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/kassio/neoterm.git

# Install spell files
RUN mkdir -p /home/core/.local/share/nvim/site/spell && \
    wget --quiet http://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.spl -O /home/core/.local/share/nvim/site/spell/en.utf-8.spl && \
    wget --quiet http://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.sug -O /home/core/.local/share/nvim/site/spell/en.utf-8.sug

# Install fzf
RUN sudo gem install curses && \
    git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/fzf && \
    /usr/local/fzf/install --no-completion --no-key-bindings --no-update-rc && \
    ln -s  ../fzf/fzf /usr/local/bin/fzf

# ssh keys
RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa
RUN ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub

# GPG
RUN ln -s /workbench/home/.gnupg /home/core/.gnupg

# Etc
RUN chown -R core:core /home/core

# Fix terminfo to stop blinking
RUN infocmp linux | perl -pi -e 's/cnorm=\\E\[\?25h\\E\[\?0c/cnorm=\\E\[\?25h/' | tic -

# Switch WORKDIR/USER back
WORKDIR /workbench/src
USER core
