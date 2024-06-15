FROM ubuntu:22.04
VOLUME [ "/app/src" ]
EXPOSE 8080

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    pkg-config autoconf automake bison flex gcc libelf-dev make \
    texinfo libncurses5-dev patch python3 subversion wget zlib1g-dev \
    libtool libtool-bin python3-dev bzip2 libgmp3-dev g++ libssl-dev clang \
    python-is-python3 python-dev-is-python3 cmake tar ninja-build apt-transport-https 

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

RUN mkdir -p /root/.config/code-server
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml


WORKDIR /app/

RUN mkdir -p /app/.vscode
COPY vscode-gba/launch.json /app/.vscode/launch.json
COPY vscode-gba/settings.json /app/.vscode/settings.json
COPY vscode-gba/tasks.json /app/.vscode/tasks.json
COPY vscode-gba/c_cpp_properties.json /app/.vscode/c_cpp_properties.json
COPY compile_flags_gba.txt /app/compile_flags.txt


RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","/app/" ]
