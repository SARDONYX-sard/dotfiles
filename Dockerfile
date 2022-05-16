# hadolint ignore=DL3007
FROM archlinux:latest

RUN pacman -Suy --noconfirm
# hadolint ignore=DL3013
RUN pacman -S --noconfirm \
  sudo \
  curl \
  bash \
  git \
  make \
  which \
  python \
  python-pip && \
  pip install --upgrade --no-cache-dir pip setuptools

ENV SHELL /usr/bin/zsh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN git clone https://github.com/SARDONYX-sard/dotfiles.git /root/dotfiles
WORKDIR /root/dotfiles
RUN bash "install-wsl.sh" --light --zsh
CMD [ "/bin/zsh" ]
