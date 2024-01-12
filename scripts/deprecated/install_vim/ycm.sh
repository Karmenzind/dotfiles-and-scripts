#! /usr/bin/env bash
# Github: https://www.github.com/Karmenzind/dotfiles-and-scripts

# install YouCompleteMe on linux
# for further info: https://github.com/Valloric/YouCompleteMe#full-installation-guide

# required: cmake 
#           python3 (and corresponding lib/devel if necessary)
#           libclang>=3.9


# if you use other plugin manager, edit this line 
plug_dir=${HOME}/.vim/plugged/YouCompleteMe

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# IF YOU WANNA COMPILE YCM WITH THIS SCRIPT 

# You need to mannual set the path to libclang.so
if [[ -n "$1" ]]; then
    libclang_so_path=$1
else
    libclang_so_path=/usr/lib/libclang.so
fi

# not important, you can delete this dir after installation
build_dir=${HOME}/ycm_build

# ycm's repo
# if low speed coz Great F**king Wall, change it to https://gitee.com/mirrors/youcompleteme.git
ycm_git_url=https://github.com/Valloric/YouCompleteMe.git 

# requirements (can be literally installed by pacman in Arch)
requirements=('cmake' 'python3')
alternatives=('clang>=3.9')

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# --------------------------------------------

prepare() {
    (which pacman > /dev/null) && is_arch=true || is_arch=false

    if [[ -z "`vim --version | grep '+python'`" ]]; then
        put_error "YCM can only install on Vim with python2 or python3 support." 
        echo "You can try replacing your vim with gvim (which usually support python) or compile vim on your own."
        exit -1
    fi

    if ($is_arch); then
        echo 'Installing requirements ...'
        if do_install ${requirements[@]} ${alternatives[@]}; then 
            cecho 'Requirements installed.' $green
        else
            exit_with_msg "Please manually install: ${requirements[*]} ${alternatives[*]}" 
        fi
    else
        put_cutoff
        cecho "Make sure you have these requirements installed:
        ${requirements[*]}"
        cecho "If you choose 'my way', make sure these requirements are installed:
        ${alternatives[*]}"
        put_suspend
    fi

    cp -nv ${repo_dir}/home_k/.vim/.ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py
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
    echo "Clone ycm's repo to $plug_dir? (Y/n)"
    echo "(cancel if you've done this before)"
    check_input yn
    if [[ $ans = 'y' ]]; then
        [[ -d $plug_dir ]] && rm -rf $plug_dir

        git clone $ycm_git_url $plug_dir --depth 1
    else
        [[ -d $plug_dir ]] || exit_with_msg 'You must clone the repo to continue.'
    fi

    echo "Run 'git submodule udpate --init --recursive'? (Y/n)"
    echo "(cancel if you've done this before)"
    check_input yn
    if [[ $ans = 'y' ]]; then
        cd $plug_dir 
        git submodule update --init --recursive 
        # TODO: else
    fi
}

# --------------------------------------------
# compile ycm_core library
# --------------------------------------------

compile_ycm_core() {
    mkdir -p $build_dir
    cd $build_dir && rm -rf *

    if ($is_arch); then
        cmake_extra='-DUSE_SYSTEM_LIBCLANG=ON'
    else
        cmake_extra="-DEXTERNAL_LIBCLANG_PATH=${libclang_so_path}"
    fi
    command -v 'python3' >/dev/null 2>&1 && cmake_extra="$cmake_extra -DUSE_PYTHON2=OFF"

    # config
    cmake -G "Unix Makefiles"                        \
        -DUSE_CLANG_COMPLETER=ON                     \
        $cmake_extra                                 \
        . ${plug_dir}/third_party/ycmd/cpp 

    # Now that configuration files have been generated
    # compile the libraries 
    cmake --build . --target ycm_core --config Release
}

# --------------------------------------------
# option
# --------------------------------------------

use_official_script() {
    cd $plug_dir
    # C# support         : install Mono and                  add --cs-completer when calling ./install.py.
    # Go support         : install Go                        and add --go-completer when calling ./install.py.
    # TypeScript support : install Node.js                   and npm then install the TypeScript SDK with npm install -g typescript.
    # JavaScript support : install Node.js and npm           and add --js-completer when calling ./install.py.
    # Rust support       : install Rust                      and add --rust-completer when calling ./install.py.
    # Java support       : install JDK8 (version 8 required) and add --java-completer when calling ./install.py.
    params='--clang-completer'
    ($is_arch) && params="--system-libclang $params"
    python3 ./install.py $params
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
check_input 12 _way
put_cutoff
process_repo
case $_way in 
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

