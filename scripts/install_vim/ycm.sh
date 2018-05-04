#! /usr/bin/env bash
# Github: https://www.github.com/Karmenzind/dotfiles-and-scripts

# install YouCompleteMe on linux
# for further info: https://github.com/Valloric/YouCompleteMe#full-installation-guide

# required: cmake 
#           clang>=3.9 (and corresponding lib/devel if necessary)
#           python (and corresponding lib/devel if necessary)


# if you use other plugin manager, edit this line 
plug_dir=${HOME}/.vim/plugged/YouCompleteMe

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# IF YOU WANNA COMPILE YCM WITH THIS SCRIPT 

# You need to mannual set the path to libclang.so
libclang_so_path=/usr/lib/libclang.so

# not important, you can delete this dir after installation
build_dir=${HOME}/ycm_build

# ycm's repo
# if low speed coz Great F**king Wall, change it to https://gitee.com/mirrors/youcompleteme.git
ycm_git_url=https://github.com/Valloric/YouCompleteMe.git 

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# --------------------------------------------

prepare() {
    (uname -a | grep -i ArchLinux > /dev/null) && is_arch=true || is_arch=false

    if [[ -z "`vim --version | grep '+python'`" ]]; then
        put_error "YCM can only install on Vim with python2 or python3 support." 
        echo "You can try replacing your vim with gvim (which usually support python) or compile vim on your own."
        exit -1
    fi

    if ($is_arch); then
        do_install clang cmake python3
    else
        put_cutoff
        cecho -e "Make sure you have these requirements installed:
        python3 
        cmake 
        clang>=3.9"
        put_suspend
    fi
}

prompt_path_check() {
    cat << EOF
Before you start this installation,
You need to manually set 
    the path to libclang.so(.*)
    the path to your ycm plugin dir 
and edit ycm.sh carefully
EOF
    cecho "
current path:
    libclang.so:    $libclang_so_path
    plugin:         $plug_dir 
" $yellow
    cat << EOF
if you have no idea where libclang.so is, try
    find /usr/lib -regex '.*libclang.so.*'
or (need mlocate)
    locate libclang.so
EOF
    put_suspend
    if [[ ! -e $libclang_so_path ]]; then
        exit_with_msg "invalid path: $libclang_so_path"
        exit -1
    fi
    if [[ ! -e $plug_dir ]]; then
        exit_with_msg "invalid path: $plug_dir"
        exit -1
    fi
}

# --------------------------------------------

process_repo() {
    [[ -d $plug_dir ]] && rm -rf $plug_dir

    git clone $ycm_git_url $plug_dir --depth 1

    cd $plug_dir 
    git submodule update --init --recursive 
}

# --------------------------------------------
# compile ycm_core library
# --------------------------------------------

compile_ycm_core() {
    mkdir -p $build_dir
    cd $build_dir && rm -rf *

    #cmake -G "Unix Makefiles" -DEXTERNAL_LIBCLANG_PATH=${libclang_so_path} . ${plug_dir}/third_party/ycmd/cpp 

    if ($is_arch); then
        cmake_extra='-DUSE_SYSTEM_LIBCLANG=ON -DUSE_PYTHON2=OFF'
    else
        cmake_extra="-DEXTERNAL_LIBCLANG_PATH=${libclang_so_path}"
    fi

    # config
    cmake -G "Unix Makefiles" \
        -DUSE_CLANG_COMPLETER=ON \
        -DEXTERNAL_LIBCLANG_PATH=${libclang_so_path} \
        -DUSE_SYSTEM_LIBCLANG=ON \
        $cmake_extra \
        . ${plug_dir}/third_party/ycmd/cpp 

    # Now that configuration files have been generated, compile the libraries using this command:
    cmake --build . --target ycm_core --config Release
}

# --------------------------------------------
# option
# --------------------------------------------

use_official_script() {
    cd $plug_dir
    ($is_arch) && extra='--system-libclang'
    python3 ./install.py --clang-completer --go-completer --js-completer --java-completer $extra
}

use_my_script() {
    ($is_arch) || prompt_path_check
    compile_ycm_core
}

# --------------------------------------------
# main
# --------------------------------------------

prepare
put_cutoff
cat << EOF
You have these options for ycm installation:
    1.  official way
    2.  my way
EOF
check_input 12
put_cutoff
#process_repo
case $ans in 
    1)
        put_cutoff
        use_official_script
        ;;
    2)  
        put_cutoff
        use_my_script
        ;;
esac

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

