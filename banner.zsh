# PhantOS banner, printed when an interactive session starts. Sourced from ~/.zshrc before
# powerlevel10k's instant prompt, which is the one place a session may print at start-up.

# Scripts (zsh -c) and pipes aren't sessions.
[[ -o interactive && -t 1 && -z $ZSH_EXECUTION_STRING ]] || return 0

() {
  # The icon's green, through teal, to its purple.
  local -a colors=('38;2;80;250;160' '38;2;80;225;200' '38;2;100;200;230' '38;2;130;170;245' '38;2;160;130;250' '38;2;190;110;250')
  local -a lines
  if (( COLUMNS >= 61 )); then
    lines=(
      '██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███████╗'
      '██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗██╔════╝'
      '██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║███████╗'
      '██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║╚════██║'
      '██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝███████║'
      '╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚══════╝'
    )
  else
    # An iPhone held upright fits about 41 columns.
    lines=(
      '█▀█ █ █ ▄▀█ █▄ █ ▀█▀ █▀█ █▀'
      '█▀▀ █▀█ █▀█ █ ▀█  █  █▄█ ▄█'
    )
    colors=($colors[1] $colors[-1])
  fi
  local i
  print
  for i in {1..$#lines}; do
    print -r -- $'\e['$colors[i]'m'$lines[i]$'\e[0m'
  done
  # Short lines, so they fit next to the compact banner too.
  print -r -- $'\e[2m'"Linux shell for iPhone and iPad"$'\e[0m'
  print -r -- $'\e[2m'"apk add <package> installs software"$'\e[0m'
  print
}
