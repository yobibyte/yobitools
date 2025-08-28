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

PS1='%F{#d78700}%~ %#%f '

alias open='xdg-open'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$HOME/.cabal/bin:/home/yobibyte/.cargo/bin:$HOME/dev/llama.cpp/build/bin:$HOME/scripts:$PATH

kitty + complete setup zsh | source /dev/stdin

source ~/dev/z/z.sh
source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh

export EDITOR="nvim"
export MANPAGER="nvim +Man!"
alias vim="nvim"
alias rtd="~/dev/rtd/target/debug/rtd"
alias xx="xsel -b -i"
alias def="source ~/.venv/bin/activate"
alias t='yt-dlp -P ~/videos/inbox'
alias eb='vim /home/yobibyte/.zshrc'
alias sb='source /home/yobibyte/.zshrc'

archive() { mv $1 ~/archive/2025 }

export YDB_DIR=~/.ydb
alias m='cd $HOME/Downloads;neomutt'
alias c='calcurse'
alias l='vim ~/sync/links.md'
alias b='w3m $(xclip -o -sel clip)'
alias n='~/scripts/n.sh'
alias v='cd ~/yobivault && vim'
alias pics='~/scripts/pics'
alias wk='function _wiki(){ w3m -dump "https://en.wikipedia.org/wiki/${*// /_}" | nvim; }; _wiki'
alias nb='newsboat'
alias d='w3m duckduckgo.com'
alias p='nvim ~/yobivault/papers.md'
alias nvda="curl -s https://terminal-stocks.dev/nvda | grep NVIDIA | cut --delimiter ' ' --fields 5"
bindkey -s '^E' 'vim $(fzf)\n'
bindkey -s '^F' '~/scripts/fzfclip.sh\n'
alias save="monolith"

# esc-M in w3m to add a link here
alias agi='bash ~/src/google_gemma-3-4b-it-Q6_K.llamafile'
alias pydocs='vim /home/yobibyte/dev/docs/cpython'
alias tr="python -m http.server 8000"

alias wtr="curl -Ss wttr.in/SW130AL | head -n -1"
alias y="~/dev/y/zig-out/bin/y"
alias zig="~/src/zig-x86_64-linux-0.16.0-dev.27+83f773fc6/zig"
alias li='url=$(fzf < ~/sync/links.md) && [ -n "$url" ] && nvim <(w3m -dump -o display_url_number=1 "$url")'
