#! /usr/bin/env bash
# create sudo user

source ../../utils/commonrc

new_sudo_user () {
    echo "Input your new user name:"
    read username
    echo "user add -m -G wheel $username"
    passwd $username

    do_install sudo
    sed -i '/%wheel ALL=(ALL) ALL/s/# \+//g' /etc/sudoers
}

new_sudo_user

echo "Now you can login with $username"
echo ":)"
