# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH=$HOME/.oh-my-zsh
elif [[ -d "/usr/share/oh-my-zsh" ]]; then
    export ZSH=/usr/share/oh-my-zsh
fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME="bureau"
if [[ "root" == "$USER" ]]; then
    ZSH_THEME="half-life"
else
    ZSH_THEME="random"
fi

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=(
#     "af-magic"
#     "jreese"
#     "agnoster"
# )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  #'colorize'
  #'django'
  #'extract'
  #'github'
  #'gitignore'
  #'node'
  #'npm'
  #'emoji-clock'
  #'rand-quote'
  #'command-not-found'
  'golang'
  'fzf'
  # 'systemd'
  # 'svn'
  'svn-fast-info'
  'virtualenv'
  'virtualenvwrapper'
  'archlinux'
  # 'autojump'
  # 'chucknorris'
  'colored-man-pages'
  'common-aliases'
  'compleat'
  'copydir'
  'copyfile'
  # 'cp'
  # 'dirhistory'
  'docker'
  'encode64'
  'git-extras'
  'gitfast'
  # 'gitignore'
  'httpie'
  'pip'
  'pj'
  'python'
  # 'redis-cli'
  'rsync'
  'safe-paste'
  # 'ssh-agent'
  'taskwarrior'
  'urltools'
  'web-search'
  # 'zsh-syntax-highlighting'
  'tmux'
  'tmuxinator'
  # 'pyenv'
  # 'pipenv'
  'zsh-autosuggestions'
  'vi-mode'
)

source $ZSH/oh-my-zsh.sh

# Custom here
[[ -e ~/.config/shrc.ext ]] && source ~/.config/shrc.ext

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/mc mc
