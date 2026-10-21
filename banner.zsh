# PhantOS banner, printed when an interactive session starts. Sourced from ~/.zshrc before
# powerlevel10k's instant prompt, which is the one place a session may print at start-up.

# Scripts (zsh -c) and pipes aren't sessions.
[[ -o interactive && -t 1 && -z $ZSH_EXECUTION_STRING ]] || return 0

() {
  # One compact size for every screen: when zsh starts, the terminal hasn't reported its width
  # yet, so a banner picked by $COLUMNS came out wide and broke apart on an iPhone.
  # The colours run from the icon's green to its purple.
  print
  print -r -- $'\e[38;2;80;250;160m''█▀█ █ █ ▄▀█ █▄ █ ▀█▀ █▀█ █▀'$'\e[0m'
  print -r -- $'\e[38;2;190;110;250m''█▀▀ █▀█ █▀█ █ ▀█  █  █▄█ ▄█'$'\e[0m'
  print -r -- $'\e[2m'"Linux shell for iPhone and iPad"$'\e[0m'
  print -r -- $'\e[2m'"apk add <package> installs software"$'\e[0m'
  print
}
