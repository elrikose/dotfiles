#zmodload zsh/zprof
export PATH=/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:~/bin:/opt/homebrew/bin:/usr/local/bin:$PATH

# Colorize the terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Prompt
current_git_branch() {
  git branch 2> /dev/null | grep \* | cut -d' ' -f2
}

show_git_branch() {
   pushd $1
   echo -n `basename $1`
   git branch 2> /dev/null | grep \* | cut -d' ' -f2
   popd
}

parse_git_branch() {
  GIT_BRANCH=$(current_git_branch)
  if [ ! -z "${GIT_BRANCH}" ]; then
     echo " ($GIT_BRANCH)"
  fi
}

autoload -U colors && colors
setopt PROMPT_SUBST
PROMPT='%{$fg[green]%}%(5~|%-1~/.../%3~|%4~)%{$fg[yellow]%}$(parse_git_branch)%{$reset_color%} $ '

# Turn off unterminated commands that don't end in a newline like `curl`
unsetopt prompt_cr prompt_sp

# Completions
autoload -Uz compinit && compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi;

# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Environment Variables
export EDITOR=vi
export CC=clang
export CXX=clang++
export GREP_OPTIONS="-I --exclude=\*~ --exclude=\*.svn\* --exclude=\*.gitignore"
#export JAVA_HOME=$(/usr/libexec/java_home)

setopt AUTO_CD
# Allow for loops to split words by spaces
setopt shwordsplit
#add timestamp for each entry
setopt EXTENDED_HISTORY
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST 
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

# History Stats
HISTFILESIZE=1000000000
SAVEHIST=10000
HISTSIZE=1000000
# History file
export HISTFILE=~/.zhistory

# Set the key combinations for emacs for CTRL-A/CTRL-E
bindkey -e

hist_stats() {
  history | awk '{print $2}' | awk 'BEGIN {FS="|"} {print $1}'| sort | uniq -c | sort -r
}
alias hs=hist_stats

#
# Shell
#
alias ls="ls -FG"
alias ll="ls -lFG"
alias la="ls -alFG"
alias dir=ls
alias grep='grep --color=auto'
# In Zsh, history is really fc
alias h='fc -li 1'
alias hl='fc -lfi 1'
alias eject='drutil tray eject'
alias redo='sudo $(history -p \!\!)'
alias down='cd ~/Downloads'
alias desk='cd ~/Desktop'
alias stage='cd ~/Desktop/Staging'
alias bashlint=shellcheck

# Alias for ".." goes to parent directory
alias ..='cd ..'
alias tree='tree -C'

# cd to the directory in the front open Finder window
alias fw='cd "$(osascript -e "tell application \"Finder\" to POSIX path of (folder of window 1 as string)")"'

# copy path to clipboard
alias path='echo | pwd | pbcopy'

# Volume
alias stfu="osascript -e 'set volume output muted true'"

# Screenshot
alias scw='screencapture -iW ~/Desktop/Window.jpg'
alias scf='screencapture ~/Desktop/FullScreen.jpg'
alias sc=scw

# Quarantine
alias unquarantine='xattr -w com.apple.quarantine ""'
alias quarantine='xattr -d com.apple.quarantine'

# Common Typos
alias bi='vi'

# list names of shared libraries used by a library
alias ldd='otool -L'
# list exported symbols
alias nm='nm -g'

# dump preprocessors
alias gccppdump='gcc -E -dM -x c /dev/null'
alias clangppdump='clang -E -dM -x c /dev/null'

# Files accessed on system
alias snoop='sudo opensnoop'
alias snoopid='sudo opensnoop -p $1'
alias snoopf='sudo opensnoop -f $1'
alias snoopapp='sudo opensnoop -avgn $1'

alias topmem='top -o vsize'

# Network stuff
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias ping="ping -c 5" # ping 5 times ‘by default’
alias netscan0='sudo ngrep -d en0'
alias netscan1='sudo ngrep -d en1'
alias qlf='qlmanage -p "$@" >& /dev/null'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# Fuzzy Find (fzf)
alias vsf="fzf -m | xargs code"
alias pf="fzf -m --preview 'bat --color=always {}'"

# Misc
alias d2u=dos2unix
alias d2ui='dos2unix -ih'
alias softwareupdate='sudo softwareupdate -i -a'

function mac2unix
{
   cat "$1" | tr '\r' '\n' > "$1.new"
   cp "$1" "$1.orig"
   mv "$1.new" "$1"
}
alias m2u=mac2unix

function unix2mac
{
   cat "$1" | tr '\n' '\r' > $1.new
   cp "$1" "$1.orig"
   mv "$1.new" "$1"
}

#
# Journal
#
export JOURNAL_DIR="/Volumes/Journal"
alias jrnl='journal.py'
alias j='journal.py'
alias cdj='cd "$JOURNAL_DIR"'

setopt PUSHDSILENT

function sj()
{
  pushd
  cd "$JOURNAL_DIR"
  grep -Ri --color "$1" * | sort | grep -i --color "$1"
  popd
}

function je()
{
  pushd
  cd "$JOURNAL_DIR"
  /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code "$1" 
  popd
}

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
fi

#
# Development
#
export TEMP=/tmp
export TMP=/tmp

# Root folder for all source code
export SOURCE_DIR=~/Source
alias src='cd $SOURCE_DIR'

# Groovy
export GROOVY_HOME=/usr/local/opt/groovy/libexec

# Go development
#export GOPATH="${HOME}/.go"
#export GOROOT="$(brew --prefix golang)/libexec"
#export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Include alias file (if present) containing aliases for ssh, etc.
ALIASES=~/.aliases
if [ -f $ALIASES ]
then
  source $ALIASES
fi

# ZSH Plugins from https://github.com/zsh-users
export ZSH_PLUGINS=~/.zsh

# Allow history search via up/down keys.
HISTORY_SEARCH_PLUGIN=$ZSH_PLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh
[ -f $HISTORY_SEARCH_PLUGIN ] && source $HISTORY_SEARCH_PLUGIN && bindkey "^[[A" history-substring-search-up && bindkey "^[[B" history-substring-search-down

# Include zsh autosuggestions plugin
AUTOSUGGESTIONS_PLUGIN=$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $AUTOSUGGESTIONS_PLUGIN ] && source $AUTOSUGGESTIONS_PLUGIN

# Include Fuzzy Search plugin
[ -f ~/.zsh/.fzf.zsh ] && source ~/.zsh/.fzf.zsh

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}


function clean_maven()
{
    MAVEN_CACHE='$HOME/.m2/repository'

    echo "Cleaning Maven cache... $MAVEN_CACHE"
    rm -rf ${MAVEN_CACHE}
    echo "Done"
}

function clean_ivy()
{
    IVY_CACHE='$HOME/.ivy2/'

    echo "Cleaning Ivy cache... $IVY_CACHE"
    rm -rf ${IVY_CACHE}
    echo "Done"
}

function clean_cache()
{
    clean_maven
    clean_ivy
}


#
# Docker
#
alias d=docker
alias drm="docker container rm -f"
alias dps="docker ps -a"
alias dpsc="docker ps -a --format '{{.ID}} - {{.Names}} - {{.Status}} - {{.Image}}'"
alias drun="docker container run"
alias dexec="docker container exec"
alias dstop="docker container stop"
alias dstart="docker container start"
alias dl="docker container logs"
alias dtop="docker container top"
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm centurylink/dockerfile-from-image"
alias nuke-docker='docker system prune --volumes -a'

# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

#
# Git
#
alias g=git
alias gd='git diff'
alias rems='git remote -v'
alias br='git branch -vv'
alias log='git log --stat'
alias logo='git log --oneline'
alias llog='git log --stat -1'
alias llogc='llog | pbcopy'

alias parent='git log --graph --decorate --oneline'
alias all-branches='git show-branch --all'
alias git-branch-creators='git for-each-ref --format="%(color:cyan)%(authordate:format:%m/%d/%Y %I:%M %p)    %(align:25,left)%(color:yellow)%(authorname)%(end) %(color:reset)%(refname)" --sort=authordate refs/remotes'

alias hb='hub browse'
alias hbc='hub browse -- commits'
alias hbw='hub browse -- wiki'

function st()
{
    git status 
}

function mod()
{
   st | grep -v "^X"
}

#
#  up_remote - Easily keep all branches up to date from a remote.
#
#  Derived from gittyup:  https://gist.github.com/1506822
#
function up_remote()
{
   # Error out early if not in a git repo
   local currentBranch=$(current_git_branch)
   if [[ -z "${currentBranch}" ]]; then
      echo "ERROR: Current working directory is not recognized as a Git repository"
      return 1
   fi

   # $1 = remote name (eg upstream, origin)
   if [[ -z "$1" ]]; then
      echo "ERROR: No remote specified (eg upstream)"
      return 1
   fi

   # Stash local changes if there are some
   local stashed=$(git stash | grep -v 'No local changes' | wc -l)
   if [[ ! "$stashed" -eq "0" ]]; then
      echo "Your working copy has uncommitted changes... Stashed."
   fi

   # Fetch all remotes, checkout, and fast-forward merge
   git fetch --all
   local gitBranches=$(git branch --list | cut -c3-)
   for branch in ${gitBranches}
   do
      echo "Updating ${branch}..."
      git checkout -q ${branch}
      git merge --ff-only $1/${branch}
   done

   # Reset back to saved branch and working state
   if [[ "${currentBranch}" != "$(current_git_branch)" ]]; then
      git checkout -q ${currentBranch};
   fi
   if [[ ! "${stashed}" -eq "0" ]]; then git stash pop --index; fi
}
alias up_origin='up_remote origin'
alias up_upstream='up_remote upstream'
alias up_emartin='up_remote emartin'
alias up_devops='up_remote devops'

#
# Kubernetes
#
alias k=kubectl
alias kl="kubectl logs"
alias kt="kubectl top"
function klabels()
{
  for item in $( kubectl get pod --output=name); do printf "Labels for %s\n" "$item" | grep --color -E '[^/]+$' && kubectl get "$item" --output=json | jq -r -S '.metadata.labels | to_entries | .[] | " \(.key)=\(.value)"' 2>/dev/null; printf "\n"; done
}

# Merge kube config
function kmerge() {
  KUBECONFIG=~/.kube/config:$1 kubectl config view --flatten > ~/.kube/mergedkub && mv ~/.kube/mergedkub ~/.kube/config
}

# Export a kube config to stdout
function kubexport()
{
  kubectl config view --minify --flatten --context=$1
}

alias pcat='pygmentize -f terminal256 -O style=native -g'

#
# Python
#
#alias python=python3
alias pip=pip3

function pye
{
   pylint "$1" | grep "E:"
}

function pyw
{
   pylint "$1" | grep "W:"
}


function gui_open()
{
   FILE_TO_OPEN="$1"
   APP_TO_LAUNCH="$2"
   OPEN_APP=open
   if [ -n "$APP_TO_LAUNCH" ]; then
      OPEN_APP="open -a $APP_TO_LAUNCH"
   fi

   if [ -e "$FILE_TO_OPEN" ]; then
      $OPEN_APP "$FILE_TO_OPEN"
   elif [ -n "$1" ]; then
      echo "[$2]: File does not exist: $1"
   fi
}

function xcode()
{
    gui_open "$1" Xcode.app
    gui_open "$2" Xcode.app
    gui_open "$3" Xcode.app
}

function hex()
{
    gui_open "$1" HexFiend.app
    gui_open "$2" HexFiend.app
    gui_open "$3" HexFiend.app
}

function edit()
{
    gui_open "$1" TextEdit.app
    gui_open "$2" TextEdit.app
    gui_open "$3" TextEdit.app
}

function csv()
{
    gui_open "$1" Numbers.app
    gui_open "$2" Numbers.app
    gui_open "$3" Numbers.app
}

function op()
{
    open "$1" "$2" "$3"
}

alias xc=xcode
alias te=edit
alias vs='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
alias code=vs

function dict() { open dict:///"$@" ; }

#
# Scripts
#
alias traffic='python3 ~/bin/traffic.py'

export BACKUP_LOG="${HOME}/Backups/backup.log"
function full_backup() {
    pushd
    cd "${HOME}/bin"
    python3 backups.py full 2>&1  >> "${BACKUP_LOG}"
    tail -100 "${BACKUP_LOG}"
    popd
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [[ -f "$HOME/.okta/bash_functions" ]]; then
    . "$HOME/.okta/bash_functions"
fi
if [[ -d "$HOME/.okta/bin" && ":$PATH:" != *":$HOME/.okta/bin:"* ]]; then
    PATH="$HOME/.okta/bin:$PATH"
fi

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
bindkey -s "\C-r" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)

#
# Searching:
#
# ff:  to find a file under the current directory
ff () { /usr/bin/find . -name "$@" ; }
# ffs: to find a file whose name starts with a given string
ffs () { /usr/bin/find . -name "$@"'*' ; }
# ffe: to find a file whose name ends with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }

# grepfind: to grep through files found by find, e.g. grepf pattern '*.c'
# note that 'grep -r pattern dir_name' is an alternative if want all files
rf() { find . -type f -name "$2" -print0 | grep -v \.git | xargs -0 grep "$1" ; }

function rgrep
{
   grep --color=auto -r --include="$2" --exclude-dir=.svn --exclude-dir=.git "$1" ${*:3} .  2>/dev/null;
}

# Edit in-place file(s), dump old changes to backup
function sedf
{
    sed -i .back 's/'$1'/'$2'/g' $3
}

# Recursively look for a test string
function rf()
{
    grep -r "$1" * | grep -v svn | grep -v CVS ;
}

function pman () {
    man -t "${1}" | open -f -a /Applications/Preview.app
}

# Quit an OS X application from the command line
function quit () {
    for app in $*; do
        osascript -e 'quit app "'$app'"'
    done
}

# Simplify calling sudo. If no parameters do a redo
function s() {
    if [ $# -gt 0 ]
    then
        sudo $@
    else
        sudo $(fc -ln | tail -n1)
    fi
}

function my_ps()
{
    ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ;
}

function pp()
{
    my_ps | awk '!/awk/ && $0~var' var=${1:-".*"} ;
}
#zprof

# Include zsh syntax highlighting plugin
SYNTAX_HIGHLIGHTING_PLUGIN=$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $SYNTAX_HIGHLIGHTING_PLUGIN ] && source $SYNTAX_HIGHLIGHTING_PLUGIN
