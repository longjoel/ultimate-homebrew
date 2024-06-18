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
    python-is-python3 python-dev-is-python3 cmake tar ninja-build

WORKDIR /dep/
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.gz
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
RUN wget ftp://sourceware.org/pub/newlib/newlib-4.1.0.tar.gz

RUN tar xvf binutils-2.42.tar.gz
RUN tar xvf gcc-13.2.0.tar.xz
RUN tar xvf newlib-4.1.0.tar.gz

RUN rm -f *.tar.xz
WORKDIR /dep/gcc-13.2.0
RUN sh ./contrib/download_prerequisites

WORKDIR /dep/binutils-build
RUN sh ../binutils-2.42/configure \
  --prefix=/usr/local/mipsel-none-elf --target=mipsel-none-elf \
  --disable-docs --disable-nls --disable-werror --with-float=soft
RUN make -j 4
RUN make install-strip

WORKDIR /dep/gcc-build
RUN sh ../gcc-13.2.0/configure \
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


WORKDIR /dep/newlib-build

RUN ln -s /usr/local/mipsel-none-elf/bin/mipsel-none-elf-gcc /usr/local/mipsel-none-elf/bin/mipsel-none-elf-cc
RUN ../newlib-4.1.0/configure --target=mipsel-none-elf --prefix=/usr/local/mipsel-none-elf
RUN make -j4
RUN make install


RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install --global --unsafe-perm code-server

ENV PSN00BSDK_LIBS=/usr/local/lib/libpsn00b
ENV CMAKE_TOOLCHAIN_FILE=/usr/local/lib/libpsn00b/cmake/sdk.cmake

EXPOSE 8080

RUN mkdir -p /root/.config/code-server
RUN bash -c 'echo bind-addr: 0.0.0.0:8080' > /root/.config/code-server/config.yaml
RUN bash -c 'echo auth: none' >> /root/.config/code-server/config.yaml

WORKDIR /app/

RUN mkdir -p /app/.vscode
COPY ps1-files/launch.json /app/.vscode/launch.json
COPY ps1-files/settings.json /app/.vscode/settings.json
COPY ps1-files/tasks.json /app/.vscode/tasks.json
COPY ps1-files/compile_flags.txt /app/compile_flags.txt


RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
CMD [ "/usr/bin/code-server","/app/" ]
