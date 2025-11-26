HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
autoload -Uz compinit
compinit
bindkey -v
bindkey '^[[3~' delete-char
bindkey "\033[1~" beginning-of-line
bindkey "\033[4~" end-of-line

PS1='%F{#d78700}%~ %#%f '

export PATH=/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/yobibyte/.cargo/bin:$HOME/scripts:$HOME/.local/bin:$PATH

source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh

export EDITOR="vim"
export YDB_DIR=~/.ydb

alias open='xdg-open'
alias rtd="~/dev/rtd/target/debug/rtd"
alias xx="xsel -b -i"
alias def="source ~/.venv/bin/activate"
alias t='yt-dlp -P ~/videos/inbox'
archive() { mv $1 ~/archive/2025 }
alias m='cd $HOME/Downloads;neomutt'
alias l='vim ~/sync/links.md'
alias b='w3m $(xsel -b -o)'
alias n='~/scripts/n.sh'
alias p='vim ~/yobivault/papers.md'
alias nvda="curl -s https://terminal-stocks.dev/nvda | grep NVIDIA | cut --delimiter ' ' --fields 5"
bindkey -s '^E' 'vim $(fzf)\n'
bindkey -s '^F' '~/scripts/fzfclip.sh\n'
# esc-M in w3m to add a link here
alias tr="python -m http.server 8000"
alias wtr="curl -Ss wttr.in/SW130AL | head -n -1"
alias y="~/dev/y/zig-out/bin/y"
alias li='url=$(fzf < ~/sync/links.md) && [ -n "$url" ] && echo $url | content=$(w3m -dump -o display_link_number=1 $url) && echo -e "$url \n\n $content" | vim -'
alias fd="rg --files | grep "
