mkdir -p ~/dev
cd dev && git clone git@github.com:yobibyte/yobitools.git
ln -s yobitools/scripts ~/scripts

curl https://sh.rustup.rs -sSf | sh
cargo install ripgrep
cargo install fd-find
cargo install just

curl -sSfL <https://astral.sh/install.sh> | sh


