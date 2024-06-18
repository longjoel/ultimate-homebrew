FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    pkg-config autoconf automake bison flex gcc libelf-dev make \
    texinfo libncurses5-dev patch python3 subversion wget zlib1g-dev \
    libtool libtool-bin python3-dev bzip2 libgmp3-dev g++ libssl-dev clang \
    python-is-python3 python-dev-is-python3

# env
ENV PS3DEV=/usr/local/ps3dev
ENV PSL1GHT=$PS3DEV

ENV PATH=$PATH:$PS3DEV/bin
ENV PATH=$PATH:$PS3DEV/ppu/bin
ENV PATH=$PATH:$PS3DEV/spu/bin

# install ps3 toolchain
WORKDIR /dep
RUN git clone https://github.com/ps3dev/ps3toolchain.git
WORKDIR /dep/ps3toolchain
RUN ls
RUN  bash /dep/ps3toolchain/toolchain.sh

# # install ps3 sdk
WORKDIR /dep
RUN git clone https://github.com/ps3dev/PSL1GHT.git
WORKDIR /dep/PSL1GHT

RUN make install-ctrl
RUN make
RUN make install

WORKDIR /dep
RUN git clone https://github.com/ps3dev/ps3libraries.git
WORKDIR /dep/ps3libraries
RUN bash /dep/ps3libraries/libraries.sh

WORKDIR /dep
RUN wget http://developer.download.nvidia.com/cg/Cg_3.1/Cg-3.1_April2012_x86_64.deb
RUN dpkg -i Cg-3.1_April2012_x86_64.deb


RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

RUN mkdir -p /root/.config/code-server
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml


EXPOSE 8080

WORKDIR /app/

RUN mkdir -p /app/.vscode
COPY ps3-files/launch.json /app/.vscode/launch.json
COPY ps3-files/settings.json /app/.vscode/settings.json
COPY ps3-files/tasks.json /app/.vscode/tasks.json
COPY ps3-files/compile_flags.txt /app/compile_flags.txt

RUN code-server --install-extension cnshenj.vscode-task-manager
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","--disable-workspace-trust","/app/" ]