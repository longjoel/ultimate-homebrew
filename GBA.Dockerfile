FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    pkg-config autoconf automake bison flex gcc libelf-dev make \
    texinfo libncurses5-dev patch python3 subversion wget zlib1g-dev \
    libtool libtool-bin python3-dev bzip2 libgmp3-dev g++ libssl-dev clang \
    python-is-python3 python-dev-is-python3 cmake tar \
    ninja-build apt-transport-https clangd

RUN ln -s /proc/self/mounts /etc/mtab
RUN mkdir -p /usr/local/share/keyring/
RUN wget -O /usr/local/share/keyring/devkitpro-pub.gpg https://apt.devkitpro.org/devkitpro-pub.gpg
RUN echo "deb [signed-by=/usr/local/share/keyring/devkitpro-pub.gpg] https://apt.devkitpro.org stable main" > /etc/apt/sources.list.d/devkitpro.list

RUN apt-get update -y
RUN apt-get install -y devkitpro-pacman

RUN dkp-pacman -Sy
RUN dkp-pacman -S gba-dev --noconfirm
#RUN source /etc/profile.d/devkit-env.sh

RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

RUN mkdir -p /root/.config/code-server/
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml


WORKDIR /app/

RUN mkdir -p /app/.vscode
COPY gba-files/launch.json /app/.vscode/launch.json

COPY gba-files/settings.json /app/.vscode/settings.json
COPY gba-files/tasks.json /app/.vscode/tasks.json
COPY gba-files/compile_flags.txt /app/compile_flags.txt
COPY common/ultimate-homebrew-extensions-0.0.5.vsix /root/.config/code-server/ultimate-homebrew-extensions-0.0.5.vsix
RUN cd /root/.config/code-server/ && code-server --install-extension ultimate-homebrew-extensions-0.0.5.vsix --force

WORKDIR /app/

RUN code-server --install-extension cnshenj.vscode-task-manager
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","--disable-workspace-trust","/app/" ]