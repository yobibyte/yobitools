#!/bin/bash
printf "\"%s\"" "$(fzf)" | xsel -b -i
