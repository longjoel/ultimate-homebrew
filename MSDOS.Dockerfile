FROM ubuntu:22.04


VOLUME [ "/app/src" ]
EXPOSE 8080


RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    curl \
    bison flex curl gcc g++ make texinfo zlib1g-dev tar bzip2 gzip xz-utils \
    unzip m4 dos2unix nasm clangd

WORKDIR /tmp/

RUN git clone https://github.com/jwt27/build-gcc.git

WORKDIR /tmp/build-gcc/

RUN ./build-djgpp.sh --prefix=/usr/local all

RUN i386-pc-msdosdjgpp-setenv

RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

RUN mkdir -p /root/.config/code-server/
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml

WORKDIR /template
COPY msdos-files/template.mak /template/template.mak
COPY msdos-files/cwsdpmi.zip /template/cwsdpmi.zip
RUN unzip cwsdpmi.zip

COPY msdos-files/tasks.json /app/.vscode/tasks.json
COPY msdos-files/compile_flags.txt /app/compile_flags.txt

RUN mkdir -p /app/.vscode

COPY msdos-files/compile_flags.txt /app/compile_flags.txt

RUN code-server --install-extension cnshenj.vscode-task-manager
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","--disable-workspace-trust","/app/" ]