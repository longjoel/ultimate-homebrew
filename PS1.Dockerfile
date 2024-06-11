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
    python-is-python3 python-dev-is-python3 cmake tar




# ENV PS2SDKSRC=/dep/ps2sdk
# ENV PS2DEV=/usr/local/ps2dev
# ENV PS2SDK=$PS2DEV/ps2sdk
# ENV PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin
# RUN mkdir -p $PS2DEV
# install ps2 toolchain
WORKDIR /dep/
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.gz
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
RUN tar xvf binutils-2.42.tar.gz
RUN tar xvf gcc-13.2.0.tar.xz
RUN rm -f *.tar.xz
RUN cd gcc-13.2.0
RUN ./contrib/download_prerequisites
WORKDIR /dep/binutils-build
RUN ../binutils-2.42/configure \
  --prefix=/usr/local/mipsel-none-elf --target=mipsel-none-elf \
  --disable-docs --disable-nls --disable-werror --with-float=soft
RUN make -j 4
RUN make install-strip
WORKDIR /dep/gcc-build
RUN ../gcc-13.2.0/configure \
  --prefix=/usr/local/mipsel-none-elf --target=mipsel-none-elf \
  --disable-docs --disable-nls --disable-werror --disable-libada \
  --disable-libssp --disable-libquadmath --disable-threads \
  --disable-libgomp --disable-libstdcxx-pch --disable-hosted-libstdcxx \
  --enable-languages=c,c++ --without-isl --without-headers \
  --with-float=soft --with-gnu-as --with-gnu-ld

RUN make -j4
RUN make install-strip

ENV PATH=$PATH:/usr/local/mipsel-none-elf/bin

WORKDIR /dep/
RUN git clone https://github.com/Lameguy64/PSn00bSDK.git
WORKDIR /dep/PSn00bSDK
RUN git submodule update --init --recursive
RUN cmake --preset default .
RUN cmake --build ./build
RUN cmake --install ./build

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
