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
    fi
}


# --------------------------------------------

put_cutoff 'Preparation'
check_multilib_support

put_cutoff 'Display Driver'
install_driver 

put_cutoff 'Display Server'
install_display_server

put_cutoff 'Desktop Env'
install_desktop_env

# tear part
sudo pacman -Sc --noconfirm

echo 'DONE :)'


# --------------------------------------------
# TODO
# echo "How do you want to start your desktop env:
#     1 graphically using a display manager
#     2 mannually from the console by typing startx"

# echo "Pick a window manager:"
# 
# echo "Pick a display manager:"

