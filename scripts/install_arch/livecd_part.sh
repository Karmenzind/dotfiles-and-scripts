#! /usr/bin/env bash
# refer https://wiki.archlinux.org/index.php/Installation_guide
# https://github.com/Karmenzind/

#######################################################################
#                        copied from commonrc                         #
#######################################################################
# commonrc {{{
bold='\033[1m'
origin='\033[0m'
black='\E[30;1m'
red='\E[31;1m'
green='\E[32;1m'
yellow='\E[33;1m'
blue='\E[34;1m'
magenta='\E[35;1m'
cyan='\E[36;1m'
white='\E[37;1m'

cut_off='--------------------------------------------'

# Color-echo
# $1: message
# $2: color
cecho() {
    echo -e "${2:-${bold}}${1}" 
    tput sgr0                        # Reset to normal.
}  

put_error() {
    cecho "$1" $red
}

exit_with_msg() {
    cecho "$1" $red
    exit -1
}

pacman_conf=/etc/pacman.conf

no_root() {
    if [[ $USER = 'root' ]]; then
        echo "Do not use root."
        exit -1
    fi
}

# $1 prompt
put_cutoff() {
    _line="\n${cut_off}\n"
    cecho $_line $cyan
    if [[ -n "$1" ]]; then
        echo -e "$1"
        cecho $_line $cyan
    fi
}

do_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

display_array() {
    local tmp_array=($@)
    local length=${#tmp_array[@]}
    for (( i=0; i<$length; i++ )); do
        echo "$i    ${tmp_array[$i]}"
    done
    echo
}

# enhanced `read` - name a range for checking
# $1 input range, e.g. 123 Yn abcd (case insensitive)
# $2 variable's name
check_input() {
    local _range=$1
    local is_valid=no
    local _default=${_range:0:1}

    while [[ $is_valid = 'no' ]]; do
        read -p "Input: " ans
        [[ -z "$ans" ]] && ans=$_default
        ans=`echo $ans | tr '[A-Z]' '[a-z]'`
        if [[ "$_range" = *$ans* ]]; then
            is_valid=yes
        else
            put_error "Valid answer: $_range (default=$_default):"
        fi
    done

    [[ -n $2 ]] && read $2 <<< $ans
}

put_suspend() {
    cecho "
Type Ctrl+C to exit 
or type any key to continue" $cyan
    read whatever
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

check_multilib_support() {
    echo 'Check multilib support ...'
    if [[ -z "grep '^\[multilib\]' $pacman_conf" ]]; then
        multilib_enabled=0
        echo "Add multilib repo support? (Y/n)"
        check_input yn
        [[ $ans = 'y' ]] && enable_multilib && multilib_enabled=1
        sudo pacman -Sy
    else
        multilib_enabled=1
    fi

    (( multilib_enabled == 0 )) && enable_multilib
    echo "Support multilib: $multilib_enabled"
}

# -----------------------------------------------------------------------------
# basic
# -----------------------------------------------------------------------------

# $1 expr that will be passed to bc
# return 0 if nothing's wrong
valid_by_bc() {
    local res
    res=$(bc <<< "$1")
    (( res == 1 )) || return 255
}
# }}}


#######################################################################
#                                main                                 #
#######################################################################

# --------------------------------------------
# base check

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
        if [[ -z ${use_size//[0-9.]/} ]]                \
            && valid_by_bc "${use_size}<=${disk_size}"  \
            && valid_by_bc "${use_size}>5"; then
            is_valid=yes
            if valid_by_bc "${use_size}==${disk_size}"; then
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

    if valid_by_bc "${use_size}>=60"; then
        mem_size=`lsmem | grep -i "online memory" | sed 's/.* //g'`
        echo "Size of your mem: $mem_size"
        swap_size=`echo $mem_size | sed 's/G//'`
        echo "Your swap part will be allocated $swap_size GiB"

        # root
        $part_pref mkpart primary ext4 $root_start 32.5GiB   
        parts[root]=${target_disk}2
        # swap
        swap_end=`echo 32.5 $mem_size | awk '{print $1+$2}'`GiB
        $part_pref mkpart primary linux-swap 32.5GiB $swap_end
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

