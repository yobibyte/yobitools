HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

zstyle :compinstall filename '/home/yobibyte/.zshrc'
autoload -Uz compinit
compinit

bindkey -v
bindkey '^[[3~' delete-char
bindkey "\033[1~" beginning-of-line
bindkey "\033[4~" end-of-line

PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '

alias open='xdg-open'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$HOME/.cabal/bin:/home/yobibyte/.cargo/bin:$HOME/src/zig:$HOME/dev/llama.cpp/build/bin:$HOME/scripts:$PATH

kitty + complete setup zsh | source /dev/stdin

source ~/dev/z/z.sh
source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh

export EDITOR="nvim"
export MANPAGER="nvim +Man!"
alias rtd="~/dev/rtd/target/debug/rtd"
alias xxclip="xclip -sel clipboard"
alias vim='nvim'
alias def="source ~/.venv/bin/activate"
alias t='yt-dlp'
alias eb='vim /home/yobibyte/.zshrc'
alias sb='source /home/yobibyte/.zshrc'
alias reader='go run ~/src/reader/reader.go'

# dev
alias gp='git push'
alias check='cargo check'
alias build='cargo build'
alias run='cargo run'
alias clippy='cargo clippy'
alias fmt='cargo fmt'

archive() {
    mv $1 ~/archive/2025
}

export YDB_DIR=~/.ydb
alias m='neomutt'
alias sm='mw -Y'
alias c='calcurse'
alias l='vim ~/sync/links.md'
alias b='w3m $(xclip -o -sel clip)'
alias n='~/scripts/n.sh'
alias wk='wiki-tui'
alias nb='newsboat'
alias d='w3m duckduckgo.com'
alias p='nvim ~/yobivault/papers.md'
alias nvda="curl -s https://terminal-stocks.dev/nvda | grep NVIDIA | cut --delimiter ' ' --fields 5"
alias jb="just build"
bindkey -s '^F' 'rga-fzf\n'

# esc-M in w3m to add a link here

