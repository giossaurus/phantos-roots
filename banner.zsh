# PhantOS banner, printed when an interactive session starts. Sourced from ~/.zshrc before
# powerlevel10k's instant prompt, which is the one place a session may print at start-up.

# Scripts (zsh -c) and pipes aren't sessions.
[[ -o interactive && -t 1 && -z $ZSH_EXECUTION_STRING ]] || return 0

() {
  # A small ghost beside a fastfetch-style summary: block letters were unreadable on an iPhone.
  # Every line fits 40 columns, the width of an iPhone held upright. Everything is read from
  # files with zsh builtins, since starting a process costs time under iSH's emulator.
  local green=$'\e[38;2;80;250;160m' teal=$'\e[38;2;110;190;235m' purple=$'\e[38;2;190;110;250m'
  local bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'

  local who="${(%):-%n}@${HOST%%.*}"
  (( $#who > 22 )) && who="${who[1,21]}…"

  local system=Linux
  [[ -r /etc/alpine-release ]] && system="Alpine ${$(</etc/alpine-release)%.*}"

  local up=
  if [[ -r /proc/uptime ]]; then
    local -i seconds=${${(s: :)$(</proc/uptime)}[1]%.*}
    if (( seconds >= 86400 )); then up="up $(( seconds / 86400 )) d"
    elif (( seconds >= 3600 )); then up="up $(( seconds / 3600 )) h"
    else up="up $(( seconds / 60 )) min"
    fi
  fi

  local packages=
  if [[ -r /lib/apk/db/installed ]]; then
    local -a installed=(${(M)${(f)"$(</lib/apk/db/installed)"}:#P:*})
    packages="$#installed packages"
  fi

  print
  print -r -- " ${green}▄███▄${reset}  ${bold}${green}PhantOS${reset}  ${dim}${who}${reset}"
  print -r -- " ${teal}█▀█▀█${reset}  ${system} · zsh ${ZSH_VERSION}"
  local -a facts=()
  [[ -n $up ]] && facts+=($up)
  [[ -n $packages ]] && facts+=($packages)
  print -r -- " ${purple}▀ ▀ ▀${reset}  ${(j: · :)facts}"
  print -r -- "        ${dim}apk add <pkg> installs software${reset}"
  print
}
