#! /usr/bin/env bash
# refer https://wiki.archlinux.org/index.php/Installation_guide

declare -A parts

# Verify the boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then 
    echo "UEFI mode is enabled on an UEFI motherboard"
else
    echo "Sorry, this script only support UEFI mode for now"
    exit -1
fi

# test network connection
# ping archlinux

# Update the system clock
timedatectl set-ntp true
timedatectl status

# --------------------------------------------
get_target_disk () {
    fdisk -l
    echo $cut_off
    echo "Input the number of the disk (e.g. sda) which you want to install ArchLinux on"
    lsblk -adn -o NAME,SIZE | grep -n ''
    read "Input: " disk_num 
    target_disk=/dev/$(lsblk  -adn -o NAME | grep -n '' | sed -n "/${disk_num}:/s/${disk_num}://")
    disk_size=`lsblk -adno SIZE $target_disk | sed 's/G//'`
}

get_target_disk

# --------------------------------------------
# PARTITION & FORMAT & MOUNT
# --------------------------------------------

auto_partition () {
    echo "How much size (G) do you want to use? (default=$disk_size)"
    is_valid=no
    while [[ $is_valid = 'no' ]]; do
        read -p "Input a number: " use_size
        [[ -z "$use_size" ]] && use_size=$disk_size && end_point='100%'
        if [[ -z `echo $use_size | grep -i '[^0-9]'` ]] \
            && (($use_size<=$disk_size)) \
            && (($use_size>5)); then
            is_valid=yes
            end_point=${use_size}GiB
        else
            echo "Invalid size: ${use_size}G"
        fi
    done

    part_pref="parted $target_disk"

    # boot
    $part_pref mkpart ESP fat32 1MiB 551MiB 
    $part_pref set 1 esp on                 
    parts[boot]=${target_disk}1

    root_start=551MiB

    if (($use_size>=60)); then
        #mkfs.ext4 $target_disk
        mem_size=`lsmem | grep -i "online memory" | sed 's/.* //g'`
        swap_size=`echo $mem_size | sed 's/G//'`

        # root
        $part_pref mkpart primary ext4 $root_start 30.5GiB   
        parts[root]=${target_disk}2
        # swap
        swap_end=`echo 30.5 $mem_size | awk '{print $1+$2}'`GiB
        $part_pref mkpart primary linux-swap 30.5GiB $swap_end
        parts[swap]=${target_disk}3
        # home
        $part_pref mkpart primary ext4 $swap_end $end_point
        parts[home]=${target_disk}4
    else
        # root
        $part_pref mkpart primary ext4 $root_start $end_point
        parts[root]=${target_disk}2
    fi

    for i in (1 2 3 4); do
        $part_pref align-check optimal $i > /dev/null
    done
}

manual_partition () {
    fdisk $target_disk
    for p in (boot swap root home); do
        echo "What't the number of your $p partition?"
        echo "(if /dev/sda2 then input 2)"
        echo "Type ENTER if you didn't create a $p part"
        read -p "Input: " num
        if [[ -n "$part" ]]; then
            parts[$p]="${target_disk}$num"
            echo "${parts[$p]} is your $p partition"
        fi
    done
}

part_exists() {
    echo "Check $1 ..."
    [[ ! -n "echo${parts[$1]}" ]] && return 1
}

format_and_mount () {
    echo "Formatting and mount tables ..."
    part_exists boot && mkfs.fat -F32 ${parts[boot]} && mkdir /mnt/boot && mount ${parts[boot]} /mnt/boot
    part_exists root && mkfs.ext4 ${parts[root]} && mount ${parts[root]} /mnt
    part_exists home && mkfs.ext4 ${parts[home]} && mkdir /mnt/home && mount ${parts[home]} /mnt/home
    part_exists swap && mkswap ${parts[swap]} && swapon ${parts[swap]} 
}

# Partition

fdisk -l
echo "Do you want to use recommended partition table as follows (Y) 
or do the partition by yourself? (N)
recommended table:
1. for a disk larger than 60G:
    550MiB      ESP         for boot
    32GiB       ext4        for ROOT
    8GiB        linux-swap  for SWAP
    remainder   ext4        for HOME
2. for a disk smaller than 60G:
    550MiB      ESP         for BOOT
    remainder   ext4        for ROOT
    (you can create a swapfile by yourself after installation)

(Default: Y)
"

read -p "Input: " ans
case $ans in 
    Y|y)    auto_partition           ;;
    N|n)    manual_partition         ;;
    *)      echo "Invalid Choice"
            exit 1                   ;;
esac

# --------------------------------------------
# TODO
# select mirrors
mirror_file=/etc/pacman.d/mirrorlist

# --------------------------------------------
# Install the base packages
pacstrap /mnt base base_devel

# --------------------------------------------
# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab

cat /mnt/etc/fstab

# echo -e "Check the information above, and edit /mnt/etc/fstab in case of errors."
# echo -e "After you've done it, do:"
# echo -e "\tarch-chroot /mnt"
# echo -e "And then follow my construction in README.md"
echo "Enter /dotfiles-and-scripts after arch-chroot
and type 'bash install.sh' to continue."

cp -r $repo_dir /mnt/$repo_dir
arch-chroot /mnt
