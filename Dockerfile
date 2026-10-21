FROM --platform=linux/386 docker.io/library/alpine:3.19.0 AS ish-alpine

FROM ish-alpine
LABEL ish.export=appstore-apk.tar.gz
RUN mkdir /ish && touch /ish/version
RUN echo 31900 > /ish/apk-version
COPY apk-motd /etc/motd

# zsh with oh-my-zsh and powerlevel10k is root's shell. Revisions are pinned so a root
# rebuilds the same; bump them deliberately. p10k's gcloud segment starts its async worker even
# without gcloud, and the worker reopens pipes through /proc/self/fd, which iSH can't do.
ARG OHMYZSH_REVISION=2100c630ba4bd67bb48802c3e7da893a4fdaa1a0
ARG P10K_REVISION=d05a1b00f9a61f9578bf9dc19b8451942dde8734
RUN apk add --no-cache zsh zsh-vcs git \
 && git clone -q https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
 && git -C /root/.oh-my-zsh checkout -q "$OHMYZSH_REVISION" \
 && rm -rf /root/.oh-my-zsh/.git \
 && git clone -q https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k \
 && git -C /root/.oh-my-zsh/custom/themes/powerlevel10k checkout -q "$P10K_REVISION" \
 && rm -rf /root/.oh-my-zsh/custom/themes/powerlevel10k/.git \
 && cp /root/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-lean.zsh /root/.p10k.zsh \
 && sed -i '/^ *gcloud /d' /root/.p10k.zsh \
 && sed -i 's#^\(root:.*\):/bin/ash$#\1:/bin/zsh#' /etc/passwd
COPY zshrc /root/.zshrc
# The completion dump and powerlevel10k's compiled files are built now instead of at the first
# start, and the scripts sourced at every start are compiled so zsh doesn't parse them each time.
RUN zsh -i -c exit \
 && zsh -c 'for f in ~/.zshrc ~/.p10k.zsh ~/.oh-my-zsh/oh-my-zsh.sh ~/.oh-my-zsh/lib/*.zsh ~/.oh-my-zsh/plugins/git/git.plugin.zsh; do zcompile -R -- $f; done'
