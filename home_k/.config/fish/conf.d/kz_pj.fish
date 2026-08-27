# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Port of oh-my-zsh's `pj` plugin. zoxide covers frecency-based jumping; `pj`
# keeps the deterministic "named project under $PROJECT_PATHS" semantics.

function pj --description "Jump to a project under \$PROJECT_PATHS"
    set -l cmd cd
    set -l rest $argv

    if test (count $rest) -gt 1; and test "$rest[1]" = open
        set -e rest[1]
        set cmd $EDITOR
    end

    set -l project (string join ' ' -- $rest)
    if test -z "$project"
        echo "usage: pj [open] PROJECT" >&2
        return 2
    end

    for basedir in $PROJECT_PATHS
        if test -d "$basedir/$project"
            $cmd "$basedir/$project"
            return
        end
    end

    echo "No such project '$project'." >&2
    return 1
end

alias pjo 'pj open'

function __kz_pj_candidates --description "List project names under \$PROJECT_PATHS"
    # An unmatched `$basedir/*/` glob inside `for` is a silent no-op in fish,
    # so no test -d guard is needed.
    for basedir in $PROJECT_PATHS
        for d in $basedir/*/
            path basename $d
        end
    end
end

complete -c pj -f
complete -c pj -f -n __fish_is_first_token -a open -d "Open the project with \$EDITOR"
complete -c pj -f -a "(__kz_pj_candidates)"
complete -c pjo -f -a "(__kz_pj_candidates)"
