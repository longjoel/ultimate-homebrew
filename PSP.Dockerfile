FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    gcc make patch git texinfo flex bison gsl-bin mpc gettext libmpfr-dev\
    texinfo bison flex gettext libgmp3-dev libmpfr-dev libmpc-dev libusb-dev \
    libreadline-dev libcurl4 libcurl4-openssl-dev libssl-dev libarchive-dev \
    libgpgme-dev autoconf automake libtool cmake wget python3.10-venv pkg-config

# install psp toolchain

ENV PSPDEV=/usr/local/pspdev
RUN mkdir -p $PSPDEV
ENV PSPDEV=/usr/local/pspdev
ENV PATH=$PATH:$PSPDEV/bin

RUN alias sudo=''

WORKDIR /dep
RUN git clone https://github.com/pspdev/psptoolchain.git
WORKDIR /dep/psptoolchain
RUN bash ./toolchain.sh

WORKDIR /dep
RUN git clone https://github.com/pspdev/pspsdk.git

WORKDIR /dep/pspsdk
RUN bash ./bootstrap
RUN bash ./configure
RUN make -j2
RUN make install


RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

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
COPY gba-files/launch.json /app/.vscode/launch.json
COPY gba-files/settings.json /app/.vscode/settings.json
COPY gba-files/tasks.json /app/.vscode/tasks.json
COPY gba-files/compile_flags.txt /app/compile_flags.txt

RUN code-server --install-extension cnshenj.vscode-task-manager
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","/app/" ]