mkdir -p ~/dev
cd dev && git clone git@github.com:yobibyte/yobitools.git
ln -s yobitools/scripts ~/scripts

curl https://sh.rustup.rs -sSf | sh
cargo install ripgrep
cargo install fd-find
cargo install just

curl -sSfL <https://astral.sh/install.sh> | sh

cd dev && git clone https://github.com/vim/vim.git && cd vim/scr && make && sudo make install

