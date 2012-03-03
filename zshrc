#
# ~/.zshrc
# P. Gessler
# 2012-03-02
#

# history items
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# environment variables
export EDITOR="vim"
export PAGER="vimpager"

# sourcing required files
source /usr/share/git/completion/git-completion.bash

# tab completion
autoload -Uz compinit promptinit
compinit
promptinit

# colors
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

# custom prompt
setprompt () {
    # load some modules
    autoload -U colors zsh/terminfo
    colors
    setopt prompt_subst

    # make some aliases for the colors
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval PR_$color='%{$fg[${(L)color}]%}'
    done
    PR_NO_COLOR="%{$terminfo[sgr0]%}"

    # check the UID
    if [[ $UID -ge 1000 ]]; then # normal user
        eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
        eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
    elif [[ $UID -eq 0 ]]; then # root
        eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
        eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
    fi

    # check if SSH
    if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
        eval PR_HOST='${PR_YELLOW}%M${PR_NO_COLOR}' # SSH
    else
        eval PR_HOST='${PR_GREEN}%M${PR_NO_COLOR}' # No SSH
    fi

    # set the prompt
    PS1=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}]$(__git_ps1 "(%s)")[${PR_BLUE}%2~${PR_CYAN}]${PR_USER_OP} '
    PS2=$'%_>'
}
setprompt

# complete aliased commands
setopt completealiases

# standard keybindings
bindkey -v
typeset -g -A key
bindkey "\e[7~"  beginning-of-line    # Home
bindkey "\e[8~"  end-of-line          # End
bindkey "\e[5~"  beginning-of-history # PageUp
bindkey "\e[6~"  end-of-history       # PageDn
bindkey "\e[2~"  quoted-insert        # Ins
bindkey "\e[3~"  delete-char          # Del
bindkey "\e[5C"  forward-word          
bindkey "\e[5D"  backward-word       
bindkey "\e\e[C" forward-word         
bindkey "\e\e[D" backward-word        
bindkey "\e[Z~"  reverse-menu-complete
bindkey "^[[A"   history-beginning-search-backward
bindkey "^[[B"   history-beginning-search-forward

# completion settings
zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# window titles
case $TERM in
    *xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
                precmd () { print -Pn "\e]0;[%n@%M][%~]%#\a" }
                preexec () { print -Pn "\e]0;[%n@%M][%~]%# ($1)\a" }
        ;;
    screen)
        precmd () {
                    print -Pn "\e]83;title \"$1\"\a"
                    print -Pn "\e]0;$TERM - (%L) [%n@M]%# [%~] ($1)\a"
                }
                preexec () {
                    print -Pn "\e]83;title \"$1\"\a"
                    print -Pn "\e]0;$TERM - (%L) [%n@M]%# [%~] ($1)\a"
                }
        ;;
esac

# modified commands
alias diff='colordiff'
alias less=$PAGER
alias zless=$PAGER
alias df='df -h'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias ..='cd ..'

# new commands
alias hist='history | grep $1'  # requires an argument
alias psq='ps -Af | grep $1'   # requires an argument
alias vimp='vim PKGBUILD'
alias vimz='vim ~/.zshrc'
alias srcz='source ~/.zshrc'
alias q='exit'
alias :q='exit'

# privileged access
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias scat='sudo cat'
    alias svim='sudo vim'
    alias root='sudo su'
    alias reboot='sudo reboot'
    alias halt='sudo shutdown -h now'
    alias update='sudo pacman -Syu'
fi

# ls
alias ls='ls -hF --color=auto'
alias lr='ls -R'     # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -BX'    # sort by extension
alias lz='ll -rS'    # sort by size
alias lt='ll -rt'    # sort by date
alias lm='la | more'

# safety features
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'  # 'rm -i' prompts for every file
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# pacman aliases
alias pac="sudo pacman -S"    # default action     - install one or more packages
alias pacu="sudo pacman -Syu" # '[u]pdate'         - upgrade all packages to their newest version
alias pacs="pacman -Ss"       # '[s]earch'         - search for a package using one or more keywords
alias paci="pacman -Si"       # '[i]nfo'           - show information about a package
alias pacr="sudo pacman -Rs"  # '[r]emove'         - uninstall one or more packages
alias pacl="pacman -Sl"       # '[l]ist'           - list all packages of a repository
alias pacll="pacman -Qqm"     # '[l]ist [l]ocal'   - list all packages which were locally installed
alias paclo="pacman -Qdt"     # '[l]ist [o]rphans' - list all packages which are orphaned
alias paco="pacman -Qo"       # '[o]wner'          - determine which package owns a given file
alias pacf="pacman -Ql"       # '[f]iles'          - list all files installed by a given package
alias pacc="sudo pacman -Sc"  # '[c]lean cache'    - delete all not currently installed package files
alias pacm="makepkg -si"      # '[m]ake'           - make package from PKGBUILD file in current directory

# office programs
alias excel="WINEPREFIX=~/win32 wine ~/win32/drive_c/Program\ Files/Microsoft\ Office/Office14/EXCEL.EXE &"
alias wword="WINEPREFIX=~/win32 wine ~/win32/drive_c/Program\ Files/Microsoft\ Office/Office14/WINWORD.EXE &"
alias onote="WINEPREFIX=~/win32 wine ~/win32/drive_c/Program\ Files/Microsoft\ Office/Office14/ONENOTE.EXE &"
alias point="WINEPREFIX=~/win32 wine ~/win32/drive_c/Program\ Files/Microsoft\ Office/Office14/POWERPNT.EXE &"
alias email="WINEPREFIX=~/win32 wine ~/win32/drive_c/Program\ Files/Microsoft\ Office/Office14/OUTLOOK.EXE &"
