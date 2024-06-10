FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    gcc make patch git texinfo flex bison gsl-bin mpc gettext libmpfr-dev\
    wget libgmp-dev libmpc-dev

# env
ENV PS2SDKSRC=/dep/ps2sdk
ENV PS2DEV=/usr/local/ps2dev
ENV PS2SDK=$PS2DEV/ps2sdk
ENV PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin
RUN mkdir -p $PS2DEV
# install ps2 toolchain
WORKDIR /dep
RUN git clone https://github.com/ps2dev/ps2toolchain.git
WORKDIR /dep/ps2toolchain
RUN bash /dep/ps2toolchain/toolchain.sh

WORKDIR /dep
RUN git clone https://github.com/ps2dev/ps2sdk.git
WORKDIR /dep/ps2sdk
RUN bash /dep/ps2sdk/download_dependencies.sh
RUN  make && make install


RUN curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

EXPOSE 8080

RUN mkdir -p /root/.config/code-server
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml


WORKDIR /app

CMD [ "/usr/bin/code-server","/app/" ]
