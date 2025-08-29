#!/bin/bash

source ~/.venv/bin/activate
# cp ~/Downloads/default.json ~/dev/qmk_firmware/keyboards/ferris/keymaps/yobi/keymap.json

LAYOUT=mini

cp ~/Downloads/mini.json ~/dev/qmk_firmware/keyboards/ferris/keymaps/$LAYOUT/keymap.json
qmk compile -kb ferris/sweep -km $LAYOUT -e CONVERT_TO=promicro_rp2040





