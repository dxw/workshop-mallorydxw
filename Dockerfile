FROM thedxw/workshop-base

# Set timezone
RUN echo America/New_York > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Add vim's undodir so it doesn't leave undo files all over the place
RUN mkdir -p /home/core/.vim/bak

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
    git -C /home/core/.vim/bundle clone --quiet https://github.com/dxw/vim-php-indent.git

RUN chown -R core:core /home/core

# Install vim-go dependencies
RUN mkdir -p /src/go && \
    chown core:core /src/go && \
    sudo -u core sh -c 'PATH=$PATH:/usr/local/go/bin GOPATH=/src/go vim +GoInstallBinaries +q' && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

WORKDIR /workbench/src
USER core
