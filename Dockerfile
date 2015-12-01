FROM thedxw/workshop-base

# Switch WORKDIR/USER temporarily
WORKDIR /
USER root

# Set timezone
RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Dotfiles
COPY dotfiles/ /home/core/

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
    git -C /home/core/.vim/bundle clone --quiet https://github.com/vim-scripts/CursorLineCurrentWindow.git && \
    git -C /home/core/.vim/bundle clone --quiet https://github.com/dxw/vim-php-indent.git

# Install vim-go dependencies
# https://github.com/fatih/vim-go/blob/master/plugin/go.vim
RUN PATH=$PATH:/usr/local/go/bin GOPATH=/src/go sh -c '\
    go get github.com/nsf/gocode && \
    go get golang.org/x/tools/cmd/goimports && \
    go get github.com/rogpeppe/godef && \
    go get golang.org/x/tools/cmd/oracle && \
    go get golang.org/x/tools/cmd/gorename && \
    go get github.com/golang/lint/golint && \
    go get github.com/kisielk/errcheck && \
    go get github.com/jstemmer/gotags && \
    true' && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# ssh keys
RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa
RUN ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub

# use a stateful known_hosts file
RUN ln -s /workbench/home/.ssh/known_hosts /home/core/.ssh/known_hosts

# GPG
RUN ln -s /workbench/home/.gnupg /home/core/.gnupg

RUN chown -R core:core /home/core

# Switch WORKDIR/USER back
WORKDIR /workbench/src
USER core
