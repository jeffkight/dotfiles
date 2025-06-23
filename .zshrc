#
# .zshrc
#
# @author Jeff Geerling
# @author Jeff Kight
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Nicer prompt.
# export PS1=$'\n'"%F{green} %*%F %3~ %F{white}"$'\n'"$ "
export PS1=$'\n'"%F{green} %*%F{blue} %3~ %F{white}"$'\n'"$ "

# Enable plugins.
plugins=(git brew history kubectl history-substring-search)

# Custom $PATH with extra locations.
export PATH=/opt/homebrew/bin:$HOME/Library/Python/3.9/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:$PATH

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
fi

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Git aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
# Run on arm64 if getting errors: `export DOCKER_DEFAULT_PLATFORM=linux/amd64`
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

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

# Allow Composer to use almost as much RAM as Chrome.
export COMPOSER_MEMORY_LIMIT=-1

# Ask for confirmation when 'prod' is in a command string.
#prod_command_trap () {
#  if [[ $BASH_COMMAND == *prod* ]]
#  then
#    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
#    if [[ $REPLY =~ ^[Yy]$ ]]
#    then
#      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
#    else
#      echo -e "\nCommand was not run.\n"
#      return 1
#    fi
#  fi
#}
#shopt -s extdebug
#trap prod_command_trap DEBUG

fn_date() {
  date '+%Y%m%d-%H%M'
}

step_create() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hostname>" >&2
  else
    echo "step certificate create $1 $1.crt $1.key --kty RSA --size 2048 --no-password --insecure --not-after 9528h --ca ~/.step/certs/intermediate_ca.crt --ca-key ~/.step/secrets/intermediate_ca_key"
    step certificate create $1 $1.crt $1.key --kty RSA --size 2048 --no-password --insecure --not-after 9528h --ca ~/.step/certs/intermediate_ca.crt --ca-key ~/.step/secrets/intermediate_ca_key
  fi
}

# step certificate sign zap.csr foo.crt foo.key
step_sign() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hostname>" >&2
  else
    echo "step certificate sign $1.csr ~/.step/certs/intermediate_ca.crt ~/.step/secrets/intermediate_ca_key --not-after 9528h"
    step certificate create $1 $1.crt $1.key --kty RSA --size 2048 --no-password --insecure --not-after 9528h --ca ~/.step/certs/intermediate_ca.crt --ca-key ~/.step/secrets/intermediate_ca_key
  fi
}

ssh_vnc() {
  echo "ssh -L 5901:localhost:5901 $*"
  ssh -L 5901:localhost:5901 $@
}

ssh_proxy_inno() {
  echo "ssh -D 8088 -N innojump"
  ssh -D 8088 innojump
}

ssh_proxy_island() {
  echo "ssh -D 8088 -N island"
  ssh -D 8088 island
}

ssh_proxy_deloitte_us_atl() {
  echo "ssh -D 8088 -N atlfrogger"
  ssh -D 8088 atlfrogger
}

ssh_proxy_deloitte_us_ash() {
  echo "ssh -D 8088 -N ashfrogger"
  ssh -D 8088 ashfrogger
}

ssh_proxy_deloitte_us_ashatl() {
  echo "ssh -D 8088 -N ashatlfrogger"
  ssh -D 8088 ashatlfrogger
}

ssh_proxy_deloitte_global() {
  echo "ssh -D 8088 -N gfrogger"
  ssh -D 8088 gfrogger
}

frogger_vnc_tunnel() {
  echo "ssh -L 5902:127.0.0.1:5902 -N -f -l jkight frogger"
  ssh -L 5902:127.0.0.1:5902 -N -f -l jkight frogger
}

dns_reset() {
  echo ">>> killall -HUP mDNSResponder"
  sudo killall -HUP mDNSResponder
  echo ">>> killall mDNSResponderHelper"
  sudo killall mDNSResponderHelper
  echo ">>> dscacheutil -flushcache"
  sudo dscacheutil -flushcache
}

k3s_start_coastal () {
  k3d cluster create coastal --servers 3
}

k3s_start_att () {
  k3d cluster create att --server-arg '--no-deploy traefik' --servers 3 --image docker.io/rancher/k3s:v1.17.0-k3s.1
}

k3s_config_coastal () {
  export KUBECONFIG="$(k3d kubeconfig 'coastal')"
}

k3s_config_att () {
  export KUBECONFIG="$(k3d kubeconfig 'att')"
}

k3s_clean_all () {
  k3d cluster delete --all
}

maas_fix () {
  echo "systemctl stop maas-regiond"
  echo "systemctl restart bind9"
  echo "systemctl start maas-regiond"
}

maas_load_image () {
  echo "maas login admin 'http://maas.ftc5.kightlabs.net:5240/MAAS' '<admin api key>'"
  echo "maas admin boot-resources create name='centos/8.5' title='CentOS 8.5' architecture='amd64/generic' filetype='tgz' content@=centos85.tar.gz"
  echo "maas commands needs to be run as the linux user who owns the tarball"
}

virsh_pool_create () {
  echo 'for fn in B C D E F; do'
  echo 'virsh pool-define-as imagesSD$fn dir - - - - "/var/lib/libvirt/imagesSD$fn"'
  echo 'virsh pool-build imagesSD$fn'
  echo 'virsh pool-start imagesSD$fn'
  echo 'virsh pool-autostart imagesSD$fn'
  echo 'done'
}

random_name () {
  echo -n $(cat /usr/share/dict/words \
    | grep -E '^[a-z]{4,12}$' \
    | sort -R \
    | head -n2) \
    | tr ' ' '-'
}

secret_salt () {
  echo -n $(cat /usr/share/dict/words \
    | grep -E '^[a-z]{8,16}$' \
    | sort -R \
    | head -n2) \
    | tr -d " " \
    | cut -c -16
}


hpe_update () {
  # git repo
  for fn in ~/hpe/*/*
  do
    pushd $fn
    git_track_remote_branches
    popd
  done

  echo "${YELLOW}>>> Done <<< ${RESTORE}"
}

venv_upgrade() {
  VENV_ROOT="$HOME/venv"

  VENV_DEST="hpeda"
  VENV_PYTHON="python3.9"
  venv_replace

  VENV_DEST="ansible"
  VENV_PYTHON="python3.11"
  venv_replace
}

venv_replace() {
  echo "
${YELLOW}>>> venv upgrade... ${RESTORE}"
  echo "
${YELLOW}>>> Deactivate and remove venv... ${RESTORE}"
  deactivate
  source ~/.zshrc
  rm -fr $VENV_ROOT/$VENV_DEST
  echo "
${YELLOW}>>> Create venv and install packages... ${RESTORE}"
  if [ ! -d "$VENV_ROOT" ]; then
    mkdir -p "$VENV_ROOT"
  fi
  $VENV_PYTHON -m venv $VENV_ROOT/$VENV_DEST
  source $VENV_ROOT/$VENV_DEST/bin/activate
  # pip install -U pip
  # pip install -U setuptools
  # pip install -U wheel
  pip install -r ~/.requirements-$VENV_DEST.txt
  echo "
${YELLOW}>>> verify python... ${RESTORE}"
  which python3
  python --version
  echo "${YELLOW}>>> Done <<< ${RESTORE}"
  # pip
  echo "
${YELLOW}>>> pip outdated packages ${RESTORE}"
  pip list --outdated
  echo "${YELLOW}>>> Done <<< ${RESTORE}"
}

env_update () {
  # brew
  echo "
${YELLOW}>>> brew upgrade... ${RESTORE}"
  brew update
  brew upgrade

  # pip
  echo "
${YELLOW}>>> pip outdated packages ${RESTORE}"
  pip list --outdated
  echo "${YELLOW}>>> Done <<< ${RESTORE}"
}

gh_issue_dump () {
  MAX_NUM=`gh issue list --limit 1 --json number | gsed -e 's/\x1b\[[0-9;]*m//g' | jq ".[].number"`
  echo "# $(pwd) last issue: $MAX_NUM" > github-dump.json
  for n in `seq 1 $MAX_NUM`; do
    gh issue view $n --json assignees,author,body,closed,closedAt,comments,createdAt,id,labels,milestone,number,projectCards,reactionGroups,state,title,updatedAt,url >> github-dump.json
    done
}

repo_update () {
  # git repo
  for fn in ~/src/*/*
  do
    pushd $fn > /dev/null
    git_track_remote_branches
    popd > /dev/null
  done

  echo "${YELLOW}>>> Done <<< ${RESTORE}"
}

git_track_remote_branches () {
  echo "
${YELLOW}>>> Working on $(pwd)${RESTORE}"

  for remote in `git branch -r`
  do
    echo "${BLUE}>>> git branch --track ${remote#origin/} $remote ${RESTORE}"
    git branch --track ${remote#origin/} $remote > /dev/null
  done
  echo "
${BLUE}>>> git fetch --all ${RESTORE}"
  git fetch --all
  echo "
${BLUE}>>> git pull --all ${RESTORE}"
  git pull --all
}

check-ssh-add() {
  # Ensure agent is running
  echo "Ensure agent is running..."
  ssh-add -l &>/dev/null
  if [ "$?" = '2' ]
  then
    # Could not open a connection to your authentication agent.
    echo "Could not open a connection to your authentication agent."

    # Load stored agent connection info.
    echo "Load stored agent connection info..."
    test -r ~/.ssh-agent && \
      eval "$(<~/.ssh-agent)" >/dev/null

    ssh-add -l &>/dev/null
    if [ "$?" = '2' ]
    then
      # Start agent and store agent connection info.
      echo "Start agent and store agent connection info..."
      (umask 066; ssh-agent > ~/.ssh-agent)
      eval "$(<~/.ssh-agent)" >/dev/null
    fi
  fi

  # Check if agent has one or more identities.
  echo "Check if agent has one or more identities..."
  ssh-add -l &>/dev/null
  if [ "$?" = '1' ]
  then
    # The agent has no identities.  Load identities.
    echo "The agent has no identities.  Load identities..."
    for kn in ~/.ssh/JeffKight*_ed25519 ~/.ssh/JeffKight*_rsa ~/.ssh/*auto*_rsa
    do
      ssh-add $kn
    done
  fi
  echo "Done."
}

mp4_rename() {
  for fn in *.mp4
  do
    nfn=$(echo $fn | gsed -e 's/-/_/g' -e 's/\(\(_\|^\).\)/\U\1/g' )
    mv $fn $nfn
  done
}

mp4_space_rename() {
  for fn in *.mp4
  do
    nfn=$(echo $fn | gsed -e 's/\%20/ /g' -e 's/\%2520/ /g' )
    mv "$fn" "$nfn"
  done
}

#
# homebrew
#
# eval "$(/opt/homebrew/bin/brew shellenv)"

# zsh-git-prompt
# source ~/.zsh-git-prompt/zshrc.sh
# PROMPT='%B%m:%~%b $(git_super_status)
# $ '
#export PS1=$'\n'"%F{green} %*%F{blue} %3~ %F{white}"$'\n'"$ "

# zsh
# export PATH="/opt/homebrew/opt/python@3.10/bin:$PATH"
# bindkey -e

# zsh-completions
# if type brew &>/dev/null; then
# FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# autoload -Uz compinit
# compinit
# fi

# Rancher Desktop
# export PATH=$PATH:$HOME/.rd/bin

# OpenJDK
# export JAVA_HOME=/Users/jeff/SAPGUIforJava/opt/jdk/sapmachine-jdk-19.0.1.jdk/Contents/Home
# export PATH=/Users/jeff/SAPGUIforJava/opt/jdk/sapmachine-jdk-19.0.1.jdk/Contents/Home/bin:$PATH

# Visual Studio Code (code)
export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# molecule-containers
# export MOLECULE_CONTAINERS_BACKEND=podman,docker

# iTerm shell integration
# source ~/.iterm2_shell_integration.zsh

#
# venv
#
# source ~/venv/ansible/bin/activate
