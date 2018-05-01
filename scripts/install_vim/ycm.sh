#! /usr/bin/env bash
# install YouCompleteMe
# on ArchLinux

# for further info: 
# https://github.com/Valloric/YouCompleteMe#full-installation-guide

# required: cmake 
#           clang>=3.9 and corresponding lib/devel
#           python and corresponding lib/devel

no_root

# --------------------------------------------
# You need to mannual set the path to libclang.so
libclang_so_path=/usr/lib/libclang.so
# if you use other plugin manager, edit this line 
plug_dir=${HOME}/.vim/plugged/YouCompleteMe

cat << EOF
Before you start this installation,
You need to manually set 
    the path to libclang.so
    the path to your plugin dir 
and edit ycm.sh carefully

current path:
    libclang.so:    $libclang_so_path
    plugin:         $plug_dir 

ctrl+C to exit
or type any key to continue
EOF

read whatever

# --------------------------------------------
ycm_git_url=https://github.com/Valloric/YouCompleteMe.git 
# if low speed coz Great F**king Wall
# ycm_git_url=https://gitee.com/mirrors/youcompleteme.git
 
build_dir=${HOME}/ycm_build

# --------------------------------------------

if [[ -z "`vim --version | grep '+python'`" ]]; then
    echo "YCM can only install on Vim with python2 or python3 support." 
    exit -1
fi

# --------------------------------------------

[[ -d $plug_dir ]] && rm -rf $plug_dir

git clone $ycm_git_url $plug_dir --depth 1

cd $plug_dir 
git submodule update --init --recursive 

# --------------------------------------------
# compile ycm_core library
# --------------------------------------------

mkdir -p $build_dir
cd $build_dir && rm -rf *
cmake -G "Unix Makefiles" -DEXTERNAL_LIBCLANG_PATH=${libclang_so_path} . ${plug_dir}/third_party/ycmd/cpp 

# Now that configuration files have been generated, compile the libraries using this command:
cmake --build . --target ycm_core --config Release

# --------------------------------------------
# set up support for languages
# comment out what you need after installing requirements
# --------------------------------------------

# go_dir=${plug_dir}/third_party/ycmd/third_party/gocode
# cd $go_dir
# go build
# cd -

# for TypeScript
# npm install -g typescript

# for JS
# js_dir=${plug_dir}/third_party/ycmd/third_party/tern_runtime
# cd $js_dir
# npm install --production
# cd -


# --------------------------------------------
# TODO
# --------------------------------------------

# for JAVA
# Java support: install JDK8 (version 8 required). Download a binary release of eclipse.jdt.ls and extract it to YouCompleteMe/third_party/ycmd/third_party/eclipse.jdt.ls/target/repository. Note: this approach is not recommended for most users and is supported only for advanced users and developers of YCM on a best-efforts basis. Please use install.py to enable java support.

