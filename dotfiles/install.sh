mkdir -p ~/dev
cd ~/dev && git clone git@github.com:yobibyte/yobitools.git
ln -s yobitools/scripts ~/scripts

curl https://sh.rustup.rs -sSf | sh
cargo install ripgrep
cargo install just

curl -sSfL <https://astral.sh/install.sh> | sh

#TODO: prob put in local bin instead of install
cd ~/src && git clone https://github.com/vim/vim.git && cd vim/src && make && sudo make install

cd ~/src && git clone https://git.suckless.org/st
cd st && cp config.def.h config.h && patch --merge config.h < ~/dev/yobitools/dotfiles/st.patch && make && cp st ~/.local/bin


