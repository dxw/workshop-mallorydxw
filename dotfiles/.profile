
# Disable XON/XOFF flow control (^s/^q)
stty -ixon
# Disable "You have new mail"
unset MAILCHECK

# Exports
export PAGER=less
export GIT_PAGER='less -E'
export EDITOR=vim
export VISUAL=vim
export NODE_DISABLE_COLORS=1

# L10N and I18N
export LC_ALL=en_US.UTF-8
export LC_COLLATE=C

export LESSCHARSET=utf-8

# PATH
export PATH=/sbin:/bin:\
/workbench/bin:\
/workbench/local/bin:\
/workbench/local/ruby/bin:\
/usr/local/sbin:/usr/local/bin:/usr/local/games:\
/usr/sbin:/usr/bin:/usr/games:\
/usr/local/go/bin:\
/usr/local/lib/composer/vendor/bin:\
~/bin

#dxp
export DXP_CONFIG=/workbench/src/twinkie.dxw.net/tools/dxp/config.json

# Aliases
alias mv="mv -i"
alias ls="ls --color=auto"
alias stash='git stash store `git stash create`'

# Serialization formats
alias j2y="ruby -r json -r yaml -e 'puts YAML.dump(JSON.load(STDIN.read))'"
alias y2j="ruby -r json -r yaml -e 'j YAML.load(STDIN.read)'"
alias p2j="php -r '\$f=fopen(\"php://stdin\",\"r\");\$s=\"\";while(!feof(\$f))\$s.=fread(\$f,1024);echo(json_encode(unserialize(\$s)).\"\\n\");'"
alias j2p="php -r '\$f=fopen(\"php://stdin\",\"r\");\$s=\"\";while(!feof(\$f))\$s.=fread(\$f,1024);echo(serialize(json_decode(\$s)).\"\\n\");'"

# WWW
alias wget='wget --no-glob -erobots=off'
alias curl='curl -gsS'

# Golang
export GOPATH=/workbench

# Ruby
export GEM_PATH=/workbench/local/ruby

# Ag
alias ag='ag -a'
alias agp="ag -G'.php$'"
alias agj="ag -G'.js$'"
alias agp_="agp '\\\$_(GET|POST|REQUEST|SERVER|COOKIE)'"

# pluginscan
alias pscan='pluginscan --no-sloccount --no-cloc --issues-format=error_list > scan-vim && pluginscan > scan'

# Docker
alias dc=docker-compose
alias dcc='dc down --remove-orphans && dc up'
alias update-images='docker image list --format "{{.Repository}}:{{.Tag}}" | grep -v ":<none>$" | xargs --max-args=1 --max-procs=5 docker pull --quiet'

# php
alias peridot='watch run-php --noninteractive 7.4 vendor/bin/peridot spec -r dot -C'
alias phpunit='watch run-php --noninteractive 7.4 vendor/bin/phpunit'
alias php-cs-fixer='watch run-php --noninteractive 7.4 vendor/bin/php-cs-fixer fix --dry-run --diff'
alias psalm='watch run-php --noninteractive 7.3 vendor/bin/psalm'
alias composer='run-php 7.4 composer'

# node
alias node='docker run -ti --rm -v /workbench:/workbench --workdir=`pwd` thedxw/node-testing node'
alias yarn='docker run -ti --rm -v /workbench:/workbench --workdir=`pwd` thedxw/node-testing yarn'
alias grunt='yarn install -s && yarn run grunt'

# other tools
alias wpc='docker run -ti --rm -v `pwd`:/app thedxw/wpc'

# Treatment for neuropathy
alias g=git
alias v=$VISUAL
