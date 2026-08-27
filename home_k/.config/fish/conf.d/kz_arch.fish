# Github: https://github.com/Karmenzind/dotfiles-and-scripts
test -e /etc/arch-release; or exit

alias pacman 'pacman --disable-download-timeout'

set -gx aurpref 'https://aur.archlinux.org'

function aurdl --description "Clone an AUR package into ~/Downloads/aurdl"
    if test (count $argv) -eq 0
        echo "usage: aurdl PACKAGE" >&2
        return 2
    end
    set -l url "$aurpref/$argv[1].git"
    echo "url: $url"
    git clone "$url" "$HOME/Downloads/aurdl/$argv[1]"
end

function pkg_by_missing --description "Install the package that owns a missing file"
    if test (count $argv) -eq 0
        echo "usage: pkg_by_missing FILE" >&2
        return 2
    end

    set -l q (pacman -F $argv[1])
    printf 'Found:\n%s\n\n' (string join \n $q)

    if test -n "$q"
        set -l chosen (string match -r '^\w\S*' -- $q[1])
        echo "Installing the first one: $chosen"
        sudo pacman -S $chosen --noconfirm
    else
        echo "No result."
    end
end
