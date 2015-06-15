
# Disable XON/XOFF flow control (^s/^q)
stty -ixon
# Disable "You have new mail"
unset MAILCHECK

# Exports
export PAGER=less
export GIT_PAGER='less -E'
export EDITOR=vi
export VISUAL=vi
[ -x /usr/bin/vim ] && export EDITOR=vim && export VISUAL=vim
export NODE_DISABLE_COLORS=1

# L10N and I18N
export LC_ALL=en_US.UTF-8
export LC_COLLATE=C

export LESSCHARSET=utf-8

# PATH
export PATH=/sbin:/bin:\
/usr/sbin:/usr/bin:/usr/games:\
/usr/local/go/bin:\
/workbench/bin:\
/usr/local/sbin:/usr/local/bin:/usr/local/games:\
~/bin

# Aliases
[ X$TERM = Xscreen ] && alias screen='screen -e ^Oo'
[ X$EMACS != Xt ] &&
  ls -F --color=auto >/dev/null 2>/dev/null && alias ls="ls -F --color=auto"
alias ll="ls -l"
alias llh="ls -lh"
alias mv="mv -i"
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

# Ag
alias ag="ag -a"
alias agp="ag -G'.php$'"
alias agj="ag -G'.js$'"
alias agp_="agp '\\\$_(GET|POST|REQUEST|SERVER|COOKIE)'"

# Treatment for neuropathy
alias g=git
alias v=$VISUAL
