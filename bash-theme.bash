# abhiyan.bash - a two-line Bash prompt theme

# Colors and prompt data are refreshed before each command prompt.
_ab_colors() {
  C1=$'\[\e[38;2;29;161;242m\]'
  C2=$'\[\e[38;2;0;255;255m\]'
  C3=$'\[\e[38;2;34;221;136m\]'
  C4=$'\[\e[38;2;255;0;0m\]'
  C5=$'\[\e[38;2;239;185;116m\]'
  STAGED_COLOR=$'\[\e[38;2;0;136;0m\]'
  YELLOW=$'\[\e[38;2;255;255;0m\]'
  C6=$'\[\e[97m\]'
  RESET=$'\[\e[0m\]'
  BLACK=$'\[\e[30m\]'
  NORMAL=$'\[\e[22m\]'
  BG1=$'\[\e[48;2;29;161;242m\]'
  BG2=$'\[\e[48;2;0;255;255m\]'
  BG5=$'\[\e[48;2;239;185;116m\]'
  BG6=$'\[\e[47m\]'
  BOLD=$'\[\e[1m\]'
}

# Use Readline vi mode and draw its state at the prompt's final character.
if [[ $- == *i* ]]; then
  set -o vi
  bind 'set show-mode-in-prompt on'
  bind 'set keyseq-timeout 100'
  bind 'set vi-ins-mode-string "\1\e[3C\2\1\e[38;2;0;255;255m\2○\1\e[0m\e[4D\2"'
  bind 'set vi-cmd-mode-string "\1\e[3C\2\1\e[38;2;239;185;116m\2●\1\e[0m\e[4D\2"'
fi

_ab_refresh_prompt() {
  local status_output repo_flags in_tree is_bare git_dir line kind xy branch='' staged=0 unstaged=0 untracked=0
  local git_text='' bare_text='' venv_text='' venv_plain='' prompt_suffix=''
  local cwd host rel base_len right_text right_len right_col fill clock gap
  local last_status=${1:-0}
  local -a path_parts repo_info worktrees

  _ab_colors
  VIRTUAL_ENV_DISABLE_PROMPT=1
  export VIRTUAL_ENV_DISABLE_PROMPT

  repo_flags=$(git rev-parse --is-inside-work-tree --is-bare-repository --absolute-git-dir 2>/dev/null || :)
  mapfile -t repo_info <<< "$repo_flags"
  in_tree=${repo_info[0]:-}
  is_bare=${repo_info[1]:-}
  git_dir=${repo_info[2]:-}

  if [[ $in_tree == true ]]; then
    prompt_suffix=' ⚡'
    status_output=$(git status --porcelain=v2 --branch --untracked-files=all 2>/dev/null)
    while IFS= read -r line; do
      case $line in
        '# branch.head '*) branch=${line#\# branch.head }; [[ $branch == '(detached)' ]] && branch='' ;;
        '? '*) untracked=$((untracked + 1)) ;;
        1\ *|2\ *|u\ *)
          read -r kind xy _ <<< "$line"
          [[ ${xy:0:1} != . ]] && staged=$((staged + 1))
          [[ ${xy:1:1} != . ]] && unstaged=$((unstaged + 1))
          ;;
      esac
    done <<< "$status_output"
    git_text="${BOLD}${C5}${BG5}${BLACK} ${branch} "
    local git_plain=" ${branch} "
    if ((staged)); then git_text+="${STAGED_COLOR}${staged} "; git_plain+="${staged}+ "; fi
    if ((unstaged)); then git_text+="${BLACK}${unstaged} "; git_plain+="${unstaged}* "; fi
    if ((untracked)); then git_text+="${BLACK}${untracked}! "; git_plain+="${untracked}! "; fi
  else
    git_text=''
    local git_plain=''
  fi

  if [[ $is_bare == true ]]; then
    prompt_suffix=' ⚡'
    branch=$(git branch --show-current 2>/dev/null)
    worktrees=("$git_dir"/worktrees/*)
    local worktree_count=0
    if [[ -e ${worktrees[0]:-} ]]; then worktree_count=${#worktrees[@]}; fi
    bare_text="${BOLD}${C5}${BG5}${BLACK} "
    local bare_plain="  "
    if ((worktree_count == 0)); then
      bare_text+="${branch} "; bare_plain+="${branch} "
    else
      bare_text+="(${worktree_count}) ${branch} "; bare_plain+="(${worktree_count}) ${branch} "
    fi
  else
    local bare_plain=''
  fi

  local venv_name=''
  if [[ -n ${VIRTUAL_ENV:-} ]]; then
    venv_name=${VIRTUAL_ENV##*/}
    if [[ -n $git_text || -n $bare_text ]]; then
      venv_text="${C5}${BG6}${BG6}${BLACK}${BOLD}${venv_name} "
      venv_plain="${venv_name} "
    else
      venv_text="${BLACK}${BG6}${BG6}${BLACK}${BOLD}${venv_name} "
      venv_plain="${venv_name} "
    fi
  fi

  if [[ $PWD == "$HOME" ]]; then
    cwd='~'
  elif [[ $PWD == "$HOME/"* ]]; then
    rel=${PWD#"$HOME"/}
    IFS=/ read -r -a path_parts <<< "$rel"
    if ((${#path_parts[@]} > 2)); then
      cwd="~/${path_parts[${#path_parts[@]}-2]}/${path_parts[${#path_parts[@]}-1]}"
    else
      cwd="~/${rel}"
    fi
  else
    IFS=/ read -r -a path_parts <<< "$PWD"
    if ((${#path_parts[@]} > 2)); then
      cwd="${path_parts[${#path_parts[@]}-2]}/${path_parts[${#path_parts[@]}-1]}"
    else
      cwd=$PWD
    fi
  fi
  host=${HOSTNAME%%.*}
  base_len=$(( 10 + ${#USER} + ${#host} + ${#cwd} ))
  right_text=''
  ((last_status != 0)) && right_text="󰌑${last_status} "
  clock=$(date +%H:%M:%S)
  right_text+="$clock"
  right_len=${#right_text}
  right_col=$(( ${COLUMNS:-80} - right_len + 1 ))
  ((right_col < 1)) && right_col=1
  fill=$(( ${COLUMNS:-80} - base_len - ${#git_plain} - ${#bare_plain} - ${#venv_plain} ))
  ((fill < 1)) && fill=1
  printf -v gap '%*s' "$fill" ''

  PS1="╭──${BOLD}${BLACK}${BG1} ${USER}${BG2}${C1}${BLACK}${host}${RESET}${BOLD}${C2} ${BOLD}${YELLOW}${C3}${NORMAL} ${cwd}${gap}${git_text}${bare_text}${venv_text}${RESET}\n${RESET}╰──\[\e[1C\]${prompt_suffix}${RESET} "
  PS1+="\[\e[s\e[${right_col}G\]"
  if ((last_status != 0)); then PS1+="${C4}󰌑${last_status} ${RESET}"; fi
  PS1+="${clock}\[\e[u\]"
  return 0
}

_ab_prompt_command() {
  local status=$?
  _ab_refresh_prompt "$status"
}

# Preserve existing PROMPT_COMMAND handlers when the theme is sourced.
if [[ ";${PROMPT_COMMAND-};" != *";_ab_prompt_command;"* ]]; then
  if [[ -n ${PROMPT_COMMAND-} ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND%;}; _ab_prompt_command"
  else
    PROMPT_COMMAND='_ab_prompt_command'
  fi
fi
