# -----------------------------------------------------------------------------
#                 FILE: spike.zsh-theme
#          DESCRIPTION: oh-my-zsh theme file based on robbl.zsh-theme 
#                       by Robert Robbl Schulze (robertschulze@gmx.net)
#               AUTHOR: Steve Pike
#              VERSION: 0.1
# -----------------------------------------------------------------------------

PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)$(git_time_since_commit)$(svn_prompt_info)$(svn_time_since_commit)%{$fg_bold[blue]%} % %{$reset_color%}'

# output: [git or svn status] (| rvm info)
RPROMPT='${return_status}$(git_prompt_status)$(ruby_prompt_info)%{$reset_color%}'

ZSH_THEME_REPO_NAME_COLOR="%{$fg[red]%}"

# svn prompt styling
ZSH_THEME_SVN_PROMPT_PREFIX="svn:(%{$fg[red]%}"
ZSH_THEME_SVN_PROMPT_SUFFIX="%{$fg[blue]%})"
ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[yellow]%}⚡%{$reset_color%}"
ZSH_THEME_SVN_PROMPT_CLEAN=""

# svn status styling
ZSH_THEME_SVN_PROMPT_ADDED="%{$fg[green]%} A"
ZSH_THEME_SVN_PROMPT_MODIFIED="%{$fg[blue]%} M"
ZSH_THEME_SVN_PROMPT_DELETED="%{$fg[red]%} D"
ZSH_THEME_SVN_PROMPT_RENAMED="%{$fg[magenta]%} R"
ZSH_THEME_SVN_PROMPT_UNTRACKED="%{$fg[cyan]%} N"

# git promt styling
ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# git status styling
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} A"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} M"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} D"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} R"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} N"


# custom svn regex for our layout...
function svn_get_repo_name {
    if [ $(in_svn) ]; then
        svn info | sed -n 's/Repository\ Root:\ .*\///p' | read SVN_ROOT
    
        svn info | sed -n "s/URL:\ .*$SVN_ROOT\/ivor\/branches\///p" | sed "s/\/.*$//"
    fi
}

# returns the prompt char depending on the used version control system
function prompt_char() {
  git branch >/dev/null 2>/dev/null && echo "%{$fg[green]%}G%{$reset_color%}" && return
  hg root >/dev/null 2>/dev/null && echo "%{$fg_bold[green]%}M%{$reset_color%}" && return
  svn info >/dev/null 2>/dev/null && echo "%{$fg_bold[green]%}S%{$reset_color%}" && return
  echo "%{$fg_bold[green]%}-%{$reset_color%}"
}

# returns the ruby prompt info depending on the used ruby version in rvm
function ruby_prompt_info() {
  if [ -e ~/.rvm/bin/rvm-prompt ]; then
    echo " %{$fg_bold[white]%}|%{$reset_color%} %{$fg[yellow]%}$(~/.rvm/bin/rvm-prompt)%{$reset_color%}"
  else 
    echo ""
  fi
}

# returns the time since last svn commit
function svn_time_since_commit() {
  # only proceed if there is actually a svn repository
  if [ $(in_svn) ]; then
    # get the last commit
    last_commit_datetime=`svn info | grep "Last Changed Date" | cut -c 20-44`
    last_commit=`ruby -e "require 'date'; dt = DateTime.parse('$last_commit_datetime'); puts Time.local(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec).to_i"`
    now=`date +%s`
    seconds_since_last_commit=$((now-last_commit))

    time_since_commit seconds_since_last_commit
  fi
}

# returns the time since last git commit
function git_time_since_commit() {
  # only proceed if there is actually a git repository
  if git rev-parse --git-dir > /dev/null 2>&1; then
    # only proceed if there is actually a commit
    if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
      # get the last commit
      last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
      now=`date +%s`
      seconds_since_last_commit=$((now-last_commit))

      time_since_commit seconds_since_last_commit
    else
      COLOR="$ZSH_THEME_REP_TIME_SINCE_COMMIT_NEUTRAL"
      echo " $COLOR~|"
    fi
  fi
}

# git and svn 
ZSH_THEME_REP_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

# returns the time by given seconds
function time_since_commit() {
  seconds_since_last_commit=$(($1 + 0))

  # totals
  MINUTES=$((seconds_since_last_commit / 60))
  HOURS=$((seconds_since_last_commit/3600))

  # sub-hours and sub-minutes
  DAYS=$((seconds_since_last_commit / 86400))
  SUB_HOURS=$((HOURS % 24))
  SUB_MINUTES=$((MINUTES % 60))

  COLOR="$ZSH_THEME_REP_TIME_SINCE_COMMIT_NEUTRAL"
  if [ "$MINUTES" -gt 240 ]; then
    COLOR="$ZSH_THEME_REP_TIME_SINCE_COMMIT_LONG"
  elif [ "$MINUTES" -gt 60 ]; then
    COLOR="$ZSH_THEME_REP_TIME_SINCE_COMMIT_MEDIUM"
  else
    COLOR="$ZSH_THEME_REP_TIME_SINCE_COMMIT_SHORT"
  fi

  if [ "$HOURS" -gt 24 ]; then
      echo " %{$fg_bold[white]%}[-%{$reset_color%}$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"
  elif [ "$MINUTES" -gt 60 ]; then
      echo " %{$fg_bold[white]%}[-%{$reset_color%}$COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"
  else
      echo " %{$fg_bold[white]%}[-%{$reset_color%}$COLOR${MINUTES}m%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"
  fi
}
