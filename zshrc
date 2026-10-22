# PhantOS: zsh with oh-my-zsh and powerlevel10k, tuned to start fast under iSH's emulator.

# A session's first prompt can come before the app has measured the screen, while the tty still
# says 80 columns. zsh then pads a line left without a newline to 80 columns and marks it ("#" for
# root), and on a 41-column iPhone that mark lands mid-screen. Unset, zsh uses its built-in mark.
PROMPT_EOL_MARK=''

# The PhantOS banner prints first: nothing may print once the instant prompt is up.
[[ -r /etc/phantos/banner.zsh ]] && source /etc/phantos/banner.zsh

# Instant prompt draws the last prompt at once while the rest of this file loads.
# Keep it at the top; anything that prints or asks for input goes above it.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# oh-my-zsh names the completion dump after the host, so the one built with the root would be
# ignored on every device and rebuilt at the first start (about 10 s in the emulator).
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
# Without its directory the dump can't be written, and every start rebuilds it.
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p ${ZSH_COMPDUMP:h}

# Updates come with the app, not from oh-my-zsh checking GitHub at every start.
zstyle ':omz:update' mode disabled
# The completion security audit walks every fpath directory, and here they all belong to root.
ZSH_DISABLE_COMPFIX=true
# Pasting through the magic functions is slow on long pastes.
DISABLE_MAGIC_FUNCTIONS=true
# git status over untracked files is the slowest part of a dirty check.
DISABLE_UNTRACKED_FILES_DIRTY=true

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# After ~/.p10k.zsh, which starts by unsetting every POWERLEVEL9K_ variable.
# gitstatusd reopens pipes through /proc/self/fd, which iSH can't do; p10k falls back to
# vcs_info, which only costs time inside a repository.
typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

# Neovim is the editor, and what vim opens.
export EDITOR=nvim VISUAL=nvim
alias vim=nvim
