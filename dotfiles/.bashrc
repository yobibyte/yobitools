HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
set -o vi

export PATH=/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/yobibyte/.cargo/bin:$HOME/scripts:$HOME/.local/bin:$PATH

source /usr/share/fzf/completion.bash && source /usr/share/fzf/key-bindings.bash

export EDITOR="vim"
export YDB_DIR=~/.ydb

alias def="source ~/.venv/bin/activate"
alias t='yt-dlp -P ~/videos/inbox'
alias m='cd $HOME/Downloads;neomutt'
alias l='vim ~/sync/links.md'
alias n='~/scripts/n.sh'
alias p='vim ~/notes/papers.md'
alias nvda='curl -s "https://www.google.com/finance/quote/NVDA:NASDAQ" | grep -oP "data-last-price=\"\K[0-9.]+"'
bind -x '"\C-e":vim "$(fzf)"'
bind -x '"\C-f":~/scripts/fzfclip.sh'
alias wtr="curl -Ss wttr.in/London | head -n -1 | head -7"
alias y="~/dev/y/zig-out/bin/y"
alias fd="rg --files | grep -i "
