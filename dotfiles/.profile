
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
export PATH=\
/usr/local/sbin:/usr/local/bin:/usr/local/games:\
/usr/sbin:/usr/bin:/usr/games:\
/sbin:/bin:\
/workbench/bin:\
/workbench/local/bin:\
/workbench/local/ruby/bin:\
/usr/local/go/bin:\
/usr/local/lib/composer/vendor/bin:\
~/.cargo/bin:\
~/bin

#dxp
export DXP_CONFIG=/workbench/src/twinkie.dxw.net/tools/dxp/config.json

# Rude software
# https://github.com/typicode/husky#disable-auto-install
export HUSKY_SKIP_INSTALL=1

# Aliases
alias mv="mv -i"
alias ls="ls --color=auto"
alias stash='git stash store `git stash create`'
alias watch='watch --color'

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

# Ruby/rbenv
eval "$(rbenv init -)"

# Ag
alias ag='ag -a'
alias agp="ag -G'.php$'"
alias agj="ag -G'.js$'"
alias agp_="agp '\\\$_(GET|POST|REQUEST|SERVER|COOKIE)'"

# pluginscan
alias pscan='pluginscan --no-sloccount --no-cloc --issues-format=error_list > scan-vim && pluginscan > scan'

# Docker
alias dc=docker-compose
alias update-images='docker image list --format "{{.Repository}}:{{.Tag}}" | grep -v ":<none>$" | xargs --max-args=1 --max-procs=5 docker pull --quiet'

# php
alias peridot='watch vendor/bin/peridot spec -r dot'
alias phpunit='watch vendor/bin/phpunit'
alias php-cs-fixer='watch vendor/bin/php-cs-fixer fix --dry-run --diff'
alias psalm='watch vendor/bin/psalm'
alias kahlan='watch vendor/bin/kahlan'

# https://github.com/github/scripts-to-rule-them-all
alias bootstrap=script/bootstrap
alias console=script/console
alias server=script/server
alias setup=script/setup
alias update=script/update

# other tools
alias wpc='docker run -ti --rm -v `pwd`:/app thedxw/wpc'
alias whippet='vendor/bin/whippet'
gg() {
  ${@} && git commit -a -m "${*}"
}

# Treatment for neuropathy
alias g=git
alias v=$VISUAL

# Let's have colours in vim!
export TERM=xterm
