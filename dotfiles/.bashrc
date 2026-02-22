HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
export PATH=/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/yobibyte/.cargo/bin:$HOME/scripts:$HOME/.local/bin:$PATH
export EDITOR="vim"
export YDB_DIR=~/.ydb
set -o vi

alias def="source ~/.venv/bin/activate"
alias t='yt-dlp -P ~/videos/inbox'
alias m='cd $HOME/Downloads;neomutt;cd -'
alias l='vim ~/sync/links.md'
alias n='~/scripts/n.sh'
alias p='vim ~/notes/papers.md'
alias nvda='curl -s "https://www.google.com/finance/quote/NVDA:NASDAQ" | grep -oP "data-last-price=\"\K[0-9.]+"'
alias wtr="curl -Ss wttr.in/London | head -n -1 | head -7"
alias y="~/dev/y/zig-out/bin/y"

_yg() {
    find "${2:-.}" -type d \( -name ".git" -o -name ".venv" \) -prune -o -type f -print0 | xargs -0 -P 16 grep --color=always -I -Hn "$1"
}
alias yg='_yg'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
yfzf() {
    read -p "Search history: " term
    mapfile -t cmds < <(history | awk '{$1=""; print substr($0,2)}' | grep -i "$term" | tac | awk '!seen[$0]++' | tac | tail -n 20)
    if [ ${#cmds[@]} -gt 0 ]; then
        select cmd in "${cmds[@]}"; do
            [ -n "$cmd" ] && eval "$cmd"
            break
        done
    fi
}
bind '"\C-f":"yfzf\n"'

