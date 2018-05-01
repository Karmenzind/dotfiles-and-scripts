#! /usr/bin/env bash

do_install dialog wpa_supplicant ntfs-3g dhcpcd 
put_cutoff

# --------------------------------------------
# time and locale
time_and_locale () {
    echo -e "Set your time zone to ShangHai?(Y/n)\nOr you can set it manually later."
    check_input yn
    [[ "y" = "$ans" ]] && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc

    sed -i '/^#\(en_US.UTF-8\|zh_CN.UTF-8\|zh_HK.UTF-8\|zh_TW.UTF-8\)/s/#//' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

time_and_locale
put_cutoff 

# --------------------------------------------
# Hostname
set_hostname () {
    echo "Set your hostname (e.g. 'MyArch'), or just type ENTER to ignore this step"
    read -p "Input: " hostname

    if [[ -n "$hostname" ]]; then
        echo -e "\n127.0.0.1   localhost\n::1     localhost\n127.0.1.1   ${hostname}.localdomain  ${hostname}\n" >> /etc/hosts
    fi
}

set_hostname
put_cutoff

# --------------------------------------------
# network 
do_install iw wpa_supplicant
put_cutoff

# --------------------------------------------
# Initramfs
# mkinitcpio -p linux

# --------------------------------------------
# root pw
echo "Set the root password"
passwd

# --------------------------------------------

set_boot_loader () {
    [[ -n `lscpu | grep -i 'model.*intel'` ]] && do_install intel-ucode
    do_install os-prober grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub

    # debug
    ls /boot/initramfs-linux-fallback.img /boot/initramfs-linux.img /boot/intel-ucode.img /boot/vmlinuz-linux || pacman -S linux --noconfirm

    grub-mkconfig -o /boot/grub/grub.cfg
}

put_cutoff "Boot Loader"
set_boot_loader

sync

put_cutoff "Now you can exit the chroot environment by typing 'exit'
and restart your machine by typing 'reboot'.
Remember to remove the installation media
and then login into the new system with the root account."

