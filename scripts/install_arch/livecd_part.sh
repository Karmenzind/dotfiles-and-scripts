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
    put_cutoff
    echo "Your disk information:"
    fdisk -l
    put_cutoff
    echo "Input the number of the disk (e.g. sda) on which you want to install ArchLinux"
    lsblk -dno NAME,SIZE | grep -n ''
    read -p "Input: " disk_num 
    target_disk=/dev/$(lsblk  -dno NAME | grep -n '' | sed -n "/${disk_num}:/s/${disk_num}://p")
    disk_size=`lsblk -adno SIZE $target_disk | sed 's/G//'`
    put_cutoff "ArchLinux will be installed on $target_disk \nAvailable size: $disk_size GiB"
}

get_target_disk

# --------------------------------------------
# PARTITION & FORMAT & MOUNT
# --------------------------------------------

auto_partition () {
    echo "How much size (G) do you want to use
for the whole Arch system? (default=$disk_size)"
    is_valid=no
    while [[ $is_valid = 'no' ]]; do
        read -p "Input a number: " use_size
        [[ -z "$use_size" ]] && use_size=$disk_size 
        if [[ -z `echo $use_size | grep -i '[^0-9]'` ]] \
            && (($use_size<=$disk_size)) \
            && (($use_size>5)); then
            is_valid=yes
            if (($use_size==$disk_size)); then
                end_point='100%'
            else
                end_point=${use_size}GiB
            fi
        else
            echo "Invalid size: ${use_size}G"
        fi
    done

    put_cutoff 'Start partitioning ...'

    part_pref="parted $target_disk"

    $part_pref mklabel gpt
    # boot
    $part_pref mkpart ESP fat32 1MiB 551MiB 
    $part_pref set 1 esp on                 
    parts[boot]=${target_disk}1

    root_start=551MiB

    if (($use_size>=60)); then
        mem_size=`lsmem | grep -i "online memory" | sed 's/.* //g'`
        echo "Size of your mem: $mem_size"
        swap_size=`echo $mem_size | sed 's/G//'`
        echo "Your swap part will be allocated $swap_size GiB"

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

    $part_pref print
}

manual_partition () {
    fdisk $target_disk
    fdisk -l $target_disk
    for p in boot root swap home; do
        put_cutoff
        echo "What't the number of your $p partition?"
        echo "(if /dev/sda2 then input 2)"
        echo "Type ENTER if you didn't create a $p part"
        read -p "Input: " num
        if [[ -n "$p" ]]; then
            parts[$p]="${target_disk}$num"
            echo "${parts[$p]} is your $p partition"
        fi
    done
}

part_exists() {
    echo "Check $1 ..."
    [[ -z "${parts[$1]}" ]] && echo "Part $1 invalid." && return 1
}

format_parts () {
    # root
    # root must be mounted at first
    if [[ -n "${parts[root]}" ]]; then
        mkfs.ext4 ${parts[root]}  -v
        mount ${parts[root]} /mnt --verbose
    fi
    # boot
    if [[ -n "${parts[boot]}" ]]; then
        mkfs.fat -F32 ${parts[boot]} -v
        mkdir -p /mnt/boot --verbose
        mount ${parts[boot]} /mnt/boot --verbose
    fi
    # swap
    if [[ -n "${parts[swap]}" ]]; then
        mkswap ${parts[swap]} 
        swapon ${parts[swap]} --verbose
    fi
    # home
    if [[ -n "${parts[home]}" ]]; then
        mkfs.ext4 ${parts[home]} -v
        mkdir -p /mnt/home --verbose
        mount ${parts[home]} /mnt/home --verbose
    fi

    fdisk -l $target_disk
    lsblk $target_disk
}

# Partition
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
[[ -z "$ans" ]] && ans=Y
case $ans in 
    Y|y)    auto_partition           ;;
    N|n)    manual_partition         ;;
    *)      echo "Invalid Choice"
            exit 1                   ;;
esac

put_cutoff "Formatting and mount tables ..."
format_parts
mount_parts

# --------------------------------------------
put_cutoff 'Config pacman ...'

# make ranked mirrors

ranked_servers=(
    'http://mirrors.163.com/archlinux/$repo/os/$arch'
    'http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch'
    'http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch'
    'http://mirror.lzu.edu.cn/archlinux/$repo/os/$arch'
    'http://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch'
    'http://archlinux.cs.nctu.edu.tw/$repo/os/$arch'
    'http://arch.softver.org.mk/archlinux/$repo/os/$arch'
    'http://mirrors.kernel.org/archlinux/$repo/os/$arch'
    'http://mirror.0x.sg/archlinux/$repo/os/$arch'
    'http://archlinux.mirrors.uk2.net/$repo/os/$arch'
    'http://www.mirrorservice.org/sites/ftp.archlinux.org/$repo/os/$arch'
    'http://mirrors.manchester.m247.com/arch-linux/$repo/os/$arch'
    'http://il.us.mirror.archlinux-br.org/$repo/os/$arch'
    'http://fooo.biz/archlinux/$repo/os/$arch'
    'http://mirror.rackspace.com/archlinux/$repo/os/$arch'
)

rearrange_mirrorlist () {
    echo 'Modifying mirrorlist ...'
    mfile=/etc/pacman.d/mirrorlist
    cp ${mfile} ${mfile}_bak
    # header
    sed '/^$/q' ${mfile} > ${mfile}_new
    sed -i -n '/^$/,$p' ${mfile}
    # core
    for url in ${ranked_servers[*]}; do
        line=`grep -in "$url" $mfile | head -n 1 | awk -F: '{print $1}'`
        if [[ -n $line ]] && (($line>1)); then
            line_before=$(($line-1))
            sed -n "${line_before},${line}p" ${mfile} >> ${mfile}_new
            sed -i "${line_before},${line}d" ${mfile}
        fi
    done
    # tailer
    cat ${mfile} >> ${mfile}_new
    # override
    mv ${mfile}_new ${mfile}
}

rearrange_mirrorlist
check_multilib_support

# --------------------------------------------
# Install the base packages
put_cutoff 'Install the base packages ...'
pacstrap /mnt base base-devel git vim

# --------------------------------------------
# Configure the system
put_cutoff 'Generate fstab ...'
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

for i in `seq ${#parts[*]}`; do
    $part_pref align-check optimal $i
done

# echo -e "Check the information above, and edit /mnt/etc/fstab in case of errors."
# echo -e "After you've done it, do:"
# echo -e "\tarch-chroot /mnt"
# echo -e "And then follow my construction in README.md"
if [[ -n $repo_dir ]]; then
    cp -r $repo_dir /mnt/dotfiles-and-scripts -v
    put_cutoff "After arch-chroot, execute:
    cd /dotfiles-and-scripts
    ./install.sh
to continue installation"
else
    put_cutoff "After arch-chroot, execute:
    git clone https://github.com/Karmenzind/dotfiles-and-scripts /dotfiles-and-scripts --depth 1
    cd /dotfiles-and-scripts
    ./install.sh
to continue installation"
fi

echo "Executing arch-chroot ..."

# cp -r $repo_dir /mnt/$repo_dir
arch-chroot /mnt

