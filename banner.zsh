# PhantOS banner, printed when an interactive session starts. Sourced from ~/.zshrc before
# powerlevel10k's instant prompt, which is the one place a session may print at start-up.

# Scripts (zsh -c) and pipes aren't sessions.
[[ -o interactive && -t 1 && -z $ZSH_EXECUTION_STRING ]] || return 0

() {
  # A small ghost beside the name, the size of a few lines of text: block letters were unreadable
  # on an iPhone. Every line fits 40 columns, the width of an iPhone held upright.
  # The ghost runs from the icon's green to its purple.
  local green=$'\e[38;2;80;250;160m' teal=$'\e[38;2;110;190;235m' purple=$'\e[38;2;190;110;250m'
  local bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'
  print
  print -r -- " ${green}▄███▄${reset}  ${bold}${green}PhantOS${reset}"
  print -r -- " ${teal}█▀█▀█${reset}  ${dim}Linux shell for iPhone and iPad${reset}"
  print -r -- " ${purple}▀ ▀ ▀${reset}  ${dim}apk add <pkg> installs software${reset}"
  print
}
