#!/bin/bash

DOCS_DIR=$HOME/dev/docs
cd $DOCS_DIR

# python
git clone --depth 1 git@github.com:python/cpython.git
mv cpython/Doc tmp
rm -rf cpython
mv tmp cpython

# pytorch
git clone --depth 1 git@github.com:pytorch/pytorch.git
mv pytorch/docs tmp
rm -rf pytorch 
mv tmp pytorch

# zig
w3m https://ziglang.org/documentation/master/ -dump > zig.txt
