#! /usr/bin/env bash
# Script: install graphical env for ArchLinux
# Github: Karmenzind/dotfiles-and-scripts
#
# TODO: 1 wayland server
#       2 choose whether startx or dm
#       3 lxde and other envs
#       4 custom display manager and window manager

intentions=(
    GNOME
    KDE 
    Xfce
    i3wm
)

cutoff='\n--------------------------------------------'

# --------------------------------------------
# utils
# --------------------------------------------

do_install () {
    sudo pacman -S --needed --noconfirm $*
}

display_array () {
    tmp_array=($@)
    length=${#tmp_array[@]}
    for (( i=0; i<$length; i++ )); do
        echo "$i    ${tmp_array[$i]}"
    done
    echo
}

check_input () {
    _range=$1
    is_valid=no
    _default=${_range:0:1}
    while [[ $is_valid = 'no' ]]; do
        echo "Input:"
        read ans
        [[ -z "$ans" ]] && ans=$_default
        if [[ "$_range" = *$ans* ]]; then
            is_valid=yes
        else
            echo "Valid answer: $_range (default=$_default):"
        fi
    done
}

# -----------------------------------------------------------------------------
# basic
# -----------------------------------------------------------------------------

enable_multilib() {
    sudo cat >>/etc/pacman.conf << EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
}

prepare () {
    sudo pacman -Sy 
    pacman_conf=/etc/pacman.conf
    if [[ -z "grep '^\[multilib\]' $pacman_conf" ]]; then
        multilib_enabled=0
        echo "Do you want to let pacman use the multilib repo?(Y/n)"
        check_input Yyn
        [[ 'Yy' = *$ans* ]] && enable_multilib && multilib_enabled=1
    else
        multilib_enabled=1
    fi

    (( $multilib_enabled == 0 )) && enable_multilib
    echo "Support multilib: $multilib_enabled"
}

# -----------------------------------------------------------------------------
# display server
# -----------------------------------------------------------------------------

install_display_server () {
    echo 'Installing xorg server and recommended apps...'
    do_install xorg
}

# -----------------------------------------------------------------------------
# display driver
# -----------------------------------------------------------------------------

brands=(
    intel
    AMD/ATI
    NVIDIA
)

install_driver () {
    echo 'Identify your graphics card:'
    lspci | grep -e VGA -e 3D
    echo 'Install recommended drivers? (Y/n)'
    check_input YyNn
    echo $ans
    if [[ "Yy" = *$ans* ]]; then
        echo "Choose the brand of your GPU:"
        display_array ${brands[*]}
        check_input '012'

        driver_brand=${brands[${ans}]}
        echo "GPU brand: $driver_brand"
        postfixes=(intel ati nouveau)
        echo xf86-video-${postfixes[${ans}]}

        do_install mesa xf86-video-${postfixes[${ans}]}
        (( $multilib_enabled == 1 )) && do_install lib32-mesa 
    else
        echo -e 'See https://wiki.archlinux.org/index.php/General_recommendations#Graphical_user_interface\n and help yourself.'
    fi
}

# install_driver_intel () {
#     do_install xf86-video-intel
# }
# 
# install_driver_ati () {
#     do_install xf86-video-ati
# }
# 
# 
# install_driver_nvidia () {
#     do_install xf86-video-nouveau
# }

# --------------------------------------------
# graphical env
# --------------------------------------------

install_gnome () {
    dm_name=gdm
    do_install gnome gnome-extra
}

install_kde () {
    dm_name=sddm
    do_install plasma kde-applications
}

install_xfce () {
    dm_name=sddm
    do_install xfce4 xfce4-goodies 
}

install_i3wm () {
    dm_name=sddm
    do_install i3 
}

install_desktop_env () {
    echo "Choose your intention: (default=0)"
    display_array ${intentions[@]}
    check_input 0123

    case "`echo $ans |  tr '[A-Z]' '[a-z]'`" in 
        0)  install_gnome   ;;
        1)  install_kde     ;;
        2)  install_xfce    ;;
        3)  install_i3wm    ;;
        *)                  ;;
    esac
    do_install $dm_name
    sudo systemctl enable $dm_name
    if (($?!=0)); then
        echo "Failed to enable $dm_name.
There might be enabled display manager in your system.
Disable it and then enable $dm_name by yourself.
"
}


# --------------------------------------------

prepare
echo -e $cutoff
install_driver 
echo -e $cutoff
install_display_server
echo -e $cutoff
install_desktop_env

echo 'DONE :)'

# tear part
sudo pacman -Sc --noconfirm

# --------------------------------------------
# TODO
# echo "How do you want to start your desktop env:
#     1 graphically using a display manager
#     2 mannually from the console by typing startx"

# echo "Pick a window manager:"
# 
# echo "Pick a display manager:"

