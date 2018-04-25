#! /usr/bin/env bash
# create sudo user

new_sudo_user () {
    do_install sudo

    echo "Input your new user name:"
    read username
    useradd -m -G wheel $username
    passwd $username

    sed -i '/%wheel ALL=(ALL) ALL/s/# \+//g' /etc/sudoers
}

new_sudo_user

echo "Now you can login with $username"
echo ":)"
