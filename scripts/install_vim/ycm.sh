#! /usr/bin/env bash
# install YouCompleteMe
# on ArchLinux

# for further info: 
# https://github.com/Valloric/YouCompleteMe#full-installation-guide

# go npm cmake 

plug_dir=${HOME}/.vim/bundle/YouCompleteMe
build_dir=${HOME}/ycm_build

mkdir -p $build_dir $plug_dir

git clone https://github.com/Valloric/YouCompleteMe.git $plug_dir

cd $plug_dir && git submodule update --init --recursive 

# --------------------------------------------
# compile ycm_core library
# --------------------------------------------

cd $build_dir && rm -v -rf *
cmake -G "Unix Makefiles" -DEXTERNAL_LIBCLANT_PATH=/usr/lib/libclang.so . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp 

# Now that configuration files have been generated, compile the libraries using this command:
cmake --build . --target ycm_core --config Release

# --------------------------------------------
# set up support for languages
# --------------------------------------------

# for go
# echo -n 'Need GoLang?(y/n)'
# read ans
go_dir=${plug_dir}/third_party/ycmd/third_party/gocode
cd $go_dir
go build
cd -

# for TypeScript
# npm install -g typescript

# for JS
js_dir=${plug_dir}/third_party/ycmd/third_party/tern_runtime
cd $js_dir
npm install --production
cd -

# for JAVA
# Java support: install JDK8 (version 8 required). Download a binary release of eclipse.jdt.ls and extract it to YouCompleteMe/third_party/ycmd/third_party/eclipse.jdt.ls/target/repository. Note: this approach is not recommended for most users and is supported only for advanced users and developers of YCM on a best-efforts basis. Please use install.py to enable java support.

