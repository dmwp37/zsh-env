# `.zshrc' is sourced in interactive shells. It should contain commands
# to set up aliases, functions, options, key bindings, etc. 

zshrc_load_status () {
  echo -n "\r.zshrc load: $* ... \e[0K"
}

zshrc_load_status 'checking version'

if [[ $ZSH_VERSION == 3.0.<->* ]]; then ZSH_STABLE_VERSION=yes; fi
if [[ $ZSH_VERSION == 3.1.<->* ]]; then ZSH_DEVEL_VERSION=yes;  fi

ZSH_VERSION_TYPE=old
if [[ $ZSH_VERSION == 3.1.<6->* ||
      $ZSH_VERSION == 3.2.<->*  ||
      $ZSH_VERSION == 4.<->* ]]
then
  ZSH_VERSION_TYPE=new
fi

stty pass8

zshrc_load_status 'setting bindings'

# VI key bindings, first things first :^)
bindkey -v
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
function zle-line-init () {
    echoti smkx
}
function zle-line-finish () {
    echoti rmkx
}
zle -N zle-line-init
zle -N zle-line-finish
# CTRL-T pushes the current line to a temp buffer
bindkey "^T" push-line-or-edit
# CTRL-K kill the current buffer
bindkey "^K" kill-buffer
# CTRL-X loads man-page of current command
bindkey '^X' run-help
# CTRL-/ will undo TAB expansion
bindkey '^_' undo
# CTRL-P will search the history for completions
bindkey '^P' history-search-backward
# CTRL-N will search the history for completions
bindkey '^N' history-search-forward
# CTRL-H will delete backward one word
bindkey '^H' backward-delete-word
# CTRL-L will delete current word
bindkey '^L' delete-word
# CTRL-F will move to the end of the line
bindkey '^F' vi-end-of-line
# CTRL-B will move to the begin of the line
bindkey '^B' vi-beginning-of-line

# Experimental TAB behavior.  Allow completion in the middle
bindkey '	' expand-or-complete-prefix
setopt complete_in_word
# setopt printexitvalue

zshrc_load_status 'setting options'

# Watch for other people logging into your machine
#watch=(notme)
LOGCHECK=60

## If nonnegative, commands whose combined user and system execution times
## (measured in seconds) are greater than this value have timing
## statistics printed for them.
REPORTTIME=1

MAILCHECK=300
mailpath=(
"/var/spool/mail/$LOGNAME?You have new mail in /var/spool/mail/$LOGNAME"
)
export MAILPATH

DIRSTACKSIZE=10
HISTSIZE=200
HISTFILE=~/.shell/zsh_history
SAVEHIST=200
setopt inc_append_history  # shells write to history file incrementally
# setopt share_history       # shells share the same history
setopt extended_history    # save start & elapsed times (history -d -f)
setopt hist_ignore_dups hist_expire_dups_first hist_save_no_dups
setopt hist_reduce_blanks hist_ignore_space hist_find_no_dups
setopt hist_allow_clobber  # replace > with >| in history
setopt hist_no_store       # don't store history commands

# Set/unset zsh options
setopt no_notify globdots no_correct autolist
setopt recexact longlistjobs
setopt autoresume noclobber nobeep
setopt extendedglob rcquotes
setopt pushdtohome autopushd pushdminus pushdsilent pushdignoredups
setopt noflowcontrol # Disable XON-XOFF behavior of ^S and ^Q
setopt mult_ios      # allow this mind bender: echo foo >file1 >file2

unsetopt bgnice auto_param_slash alwaystoend autocd mailwarning
unsetopt interactive_comments

zshrc_load_status 'setting environment'

# Old style file ignore.  There is a zstyle for this now.
# fignore=( .o )

#cdpath=( . ~/p4/athena ~ )
#fpath=( $fpath ~/.zfunc)

SSHDIR="${HOME}/.ssh"
SSH_AUTH_SOCK="${SSHDIR}/.ssh-agent-socket"
export SSHDIR SSH_AUTH_SOCK

PROMPT='%{[22;31m%}<%{[22;32m%}%n@%m%{[01;37m%}:%{[22;33m%}%~%{[22;31m%}>
%{[00m%}$ '
RPROMPT=

## use neat prompt themes included with zsh
#autoload -U promptinit
#promptinit

## Currently available prompt themes:
## adam1 adam2 bart bigfade clint elite2 elite
## fade fire off oliver redhat suse zefram
#prompt elite2 cyan
#prompt suse

# Don't insert a carriage return before printing prompt.  In case the
# previously run program did not finish it's last line of output.
unsetopt prompt_cr

# Use inverse-highlights on command lines.  (Disabled)
# POSTEDIT=`echotc se`
# PROMPT='%S%m[%h]%# '

# do not allow duplicates in the path
case "$ARCH" in
    armv4l|i586|i686)
        # export LANG=en_US.utf-8
        ;;

    sun4*)
        export CC=gcc

        path=( /usr/ucb $path /etc /usr/etc /usr/ccs/bin )

        manpath=( /usr/man /usr/local/man )
        manpath=( $manpath /usr/share/man /usr/openwin/share/man )
        export MANPATH
        ;;
esac


zshrc_load_status 'loading aliases'

[ -f ~/.shell/aliases ] && . ~/.shell/aliases
[ -f ~/.shell/local_aliases ] && . ~/.shell/local_aliases

# zshrc_load_status 'loading functions'

# Executed each time you change directories.  It updates the xterm title
function chpwd
{
    # First ensure we're not on the console
    [[ -t 1 ]] || return
    case $TERM in
      sun-cmd) print -Pn "\e]l%~\e\\"
        ;;
      *xterm*|rxvt|(dt|k|E)term|cygwin) print -Pn "\e]2;%m:%~       ${P4CLIENT}\a"
        ;;
    esac
}

# Allow cd to files
cd () {
  if [[ -f $1 ]]; then
    builtin cd $1:h
    # print -D $PWD
  else
    builtin cd $1
    # print -D $PWD
  fi
}

dir() { /bin/ls -la $* | more }

# Exampe:  /var/spool/mail> namedir spool
#          ~spool> cd .msgs
namedir() { export $1=$PWD && : ~$1 }

# Autoload all shell functions in ~/.zfunc (following symlinks) that
# have the executable bit on (the executable bit is not necessary, but
# gives you an easy way to stop the autoloading of a particular shell
# function).
# for func in ~/.zfunc/*(N-.x:t); autoload $func

#local _myhosts 
#_myhosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})

# Zsh which is fine, kill off any alias from startup files
alias which >&/dev/null && unalias which
# Ditto for zsh's run-help command (^X)
alias run-help >&/dev/null && unalias run-help ; autoload -U run-help
# Let run-help know where my help files are
HELPDIR=~/.shell/helpfiles

# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
# Spécifie les couleurs
LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.bz2=01;31:*.rpm=01;31:*.deb=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.mpg=01;37:*.avi=01;37:*.mov=01;37:*.tbz=01;31:*.zip=01;31:*.mp3=00;34:*.png=01;35:*.89t=00;33';
# Note: LS_COLORS n'est utilis?que par GNU ls...
export LS_COLORS

                    

#; Are we using GNU ls? If so, set the colors.
if (dircolors &>/dev/null); then
 if (ls --color=yes &>/dev/null); then
  if [ "$?" = "0" ]; then
   if [ -f ~/.shell/dircolors ]; then
    eval `dircolors ${HOME}/.shell/dircolors`
   else
    eval `dircolors`
   fi
  fi
 fi
  alias ls='ls -hF --color=auto --show-control-chars'
else
  alias ls='ls -l'
fi

# List only directories and symbolic
# links that point to directories
alias ll='ls -l --group-directories-first'
alias lsd='ls -ld *(-/DN)'

# List only file beginning with "."
alias lsa='ls -ld .*'

#; Is less installed? If so, set it as a $PAGER.
if (type less &>/dev/null); then
 PAGER="less"
 export PAGER
# LESS_VERSION=$(less -V 2>&1|head -1|awk '{print $NF}'|awk -F'+' '{print $1}')
# if [ "${LESS_VERSION}" -gt "340" ]; then
  LESS='-giMR'
  export LESS
# else
#  LESS='-iM'
#  export LESS
# fi
 #; Want to see number lines in `less`?
 alias nless="less -N"
 #; Make it easier to read when going through large files.
 alias wless="less -JW"
fi

#; Configure the editor.
if (type vim &>/dev/null); then
 EDITOR="vim"
 VISUAL="${EDITOR}"
 export EDITOR VISUAL
else
 EDITOR="vi"
 VISUAL="${EDITOR}"
 export EDITOR VISUAL
 alias vim="vi"
fi

zshrc_load_status 'loading completions'
# The following lines were added by compinstall

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*' completer _expand _complete _match _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' '*?.old'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*:history-words' list false
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' menu select=long
zstyle ':completion:*:history-words' menu yes
zstyle ':completion:*' prompt '%e, How about one of these?'
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*' select-prompt '%SScrolling active: current sel at %p%s'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-compctl false
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
zstyle ':completion:*:rm:*' ignore-line yes
#zstyle ':completion:*' hosts $_myhosts 
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.shell/cache

autoload -U compinit
compinit -u -D
# End of lines added by compinstall

# Zftp
autoload -U zfinit
zfinit

zshrc_load_status 'zshrc complete'

echo -n "\r"
chpwd
