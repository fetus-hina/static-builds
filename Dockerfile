FROM centos:6
ENV HOME /root
RUN yum update -y && \
    yum install -y \
        centos-release-scl-rh \
        scl-utils && \
    yum install -y \
        cmake \
        devtoolset-7-gcc \
        devtoolset-7-gcc-c++ \
        git \
        glibc-static \
        patch \
        perl \
        tar \
        wget \
        xz && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir -p /opt/bin

# http://zlib.net/
RUN wget -O /root/zlib.tar.xz 'http://zlib.net/zlib-1.2.11.tar.xz' && \
    mkdir /root/zlib && \
    cd /root/zlib && \
    tar -J -x -v -f /root/zlib.tar.xz --strip-components=1 && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/zlib --static && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/zlib.tar.xz /root/zlib


# libjpeg
# http://www.ijg.org/
RUN wget -O /tmp/libjpeg.tar.gz 'http://www.ijg.org/files/jpegsrc.v9c.tar.gz' && \
    mkdir /root/libjpeg && \
    cd /root/libjpeg && \
    tar -zxf /tmp/libjpeg.tar.gz --strip-components=1 && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/libjpeg && \
    scl enable devtoolset-7 -- make && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/libjpeg /tmp/libjpeg.tar.gz


# https://github.com/nghttp2/nghttp2
RUN wget -O /root/nghttp2.tar.xz 'https://github.com/nghttp2/nghttp2/releases/download/v1.38.0/nghttp2-1.38.0.tar.xz' && \
    mkdir /root/nghttp2 && \
    cd /root/nghttp2 && \
    tar -J -x -v -f /root/nghttp2.tar.xz --strip-components=1 && \
    scl enable devtoolset-7 -- ./configure \
        LDFLAGS="-static" \
        --prefix=/opt/nghttp2 \
        --enable-lib-only \
        --enable-static \
        --disable-shared \
        --with-pic \
        --without-systemd && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/nghttp2.tar.xz /root/nghttp2

# https://c-ares.haxx.se/
RUN wget -O /root/c-ares.tar.gz 'https://c-ares.haxx.se/download/c-ares-1.15.0.tar.gz' && \
    mkdir /root/c-ares && \
    cd /root/c-ares && \
    tar -z -x -v -f /root/c-ares.tar.gz --strip-components=1 && \
    scl enable devtoolset-7 -- ./configure \
        --prefix=/opt/c-ares \
        --enable-static \
        --disable-shared \
        --with-pic \
        --enable-optimize && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/c-ares.tar.gz /root/c-ares


# https://ftp.gnu.org/gnu/libidn/?C=N;O=D
RUN wget -O /root/libidn2.tar.gz 'https://ftp.gnu.org/gnu/libidn/libidn2-latest.tar.gz' && \
    mkdir /root/libidn2 && \
    cd /root/libidn2 && \
    tar -z -x -v -f /root/libidn2.tar.gz --strip-components=1 && \
    scl enable devtoolset-7 -- ./configure \
        --prefix=/opt/libidn2 \
        --enable-static \
        --disable-shared \
        --with-pic && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/libidn2.tar.gz /root/libidn2


# https://www.openssl.org/
RUN wget -O /root/openssl.tar.gz 'https://www.openssl.org/source/openssl-1.1.1c.tar.gz' && \
    mkdir /root/openssl && \
    cd /root/openssl && \
    tar -z -x -v -f /root/openssl.tar.gz --strip-components=1 && \
    scl enable devtoolset-7 -- ./config \
        --release \
        --prefix=/opt/openssl \
        --with-zlib-include=/opt/zlib/include \
        --with-zlib-lib=/opt/zlib/lib \
        no-asm \
        no-comp \
        no-deprecated \
        no-shared \
        threads \
        zlib \
        -static && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    strip /opt/openssl/bin/openssl && \
    cp /opt/openssl/bin/openssl /opt/bin/ && \
    rm -rf /root/openssl.tar.gz /root/openssl

 
# https://curl.haxx.se/
RUN wget -O /root/curl.tar.xz 'https://curl.haxx.se/download/curl-7.65.1.tar.xz' && \
    mkdir /root/curl && \
    cd /root/curl && \
    tar -J -x -v -f /root/curl.tar.xz --strip-components=1 && \
    scl enable devtoolset-7 -- env LD_FLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure \
        --prefix=/opt/curl \
        --bindir=/opt/bin \
        --disable-debug \
        --enable-optimize \
        --enable-warnings \
        --disable-werror \
        --disable-curldebug \
        --enable-symbol-hiding \
        --enable-ares=/opt/c-ares \
        --disable-shared \
        --enable-static \
        --enable-http \
        --enable-ftp \
        --enable-file \
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --enable-proxy \
        --disable-dict \
        --enable-telnet \
        --enable-tftp \
        --enable-pop3 \
        --enable-imap \
        --disable-smb \
        --enable-smtp \
        --disable-gopher \
        --disable-manual \
        --disable-libcurl-option \
        --enable-ipv6 \
        --disable-threaded-resolver \
        --disable-pthreads \
        --enable-verbose \
        --disable-sspi \
        --enable-crypto-auth \
        --disable-ntlm \
        --disable-ntlm-wb \
        --disable-tls-srp \
        --enable-unix-sockets \
        --enable-cookies \
        --with-pic \
        --with-zlib=/opt/zlib \
        --without-brotli \
        --with-ssl=/opt/openssl \
        --with-random=/dev/urandom \
        --with-ca-bundle=/etc/pki/tls/certs/ca-bundle.crt \
        --with-ca-path=/etc/pki/tls/certs \
        --without-librtmp \
        --with-nghttp2=/opt/nghttp2 \
        --with-libidn2=/opt/libidn2 \
        --without-zsh-functions-dir && \
    scl enable devtoolset-7 -- make curl_LDFLAGS="-all-static" -j 4 && \
    scl enable devtoolset-7 -- make curl_LDFLAGS="-all-static" install && \
    strip /opt/bin/curl && \
    rm -rf /root/curl.tar.xz /root/curl


RUN git clone --depth 1 'https://github.com/tjko/jpegoptim.git' && \
    cd jpegoptim && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure \
        --prefix=/opt/jpegoptim \
        --bindir=/opt/bin \
        --with-libjpeg=/opt/libjpeg && \
    scl enable devtoolset-7 -- make && \
    scl enable devtoolset-7 -- make strip && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/jpegoptim


# https://github.com/google/zopfli/releases
COPY patches/zopfli-* /tmp/
RUN wget -O /root/zopfli.tar.gz https://github.com/google/zopfli/archive/zopfli-1.0.2.tar.gz && \
    mkdir -p /root/zopfli && \
    cd /root/zopfli && \
    tar -zxvf /root/zopfli.tar.gz --strip-components=1 && \
    patch < /tmp/zopfli-static.patch && \
    scl enable devtoolset-7 -- make -j 4 zopfli zopflipng && \
    strip zopfli && \
    strip zopflipng && \
    mkdir -p /opt/bin && \
    cp zopfli zopflipng /opt/bin/ && \
    rm -rf /root/zopfli


# https://github.com/google/brotli/releases
RUN wget -O /root/brotli.tar.gz https://github.com/google/brotli/archive/v1.0.7.tar.gz && \
    mkdir -p /root/brotli && \
    cd /root/brotli && \
    tar -zxvf /root/brotli.tar.gz --strip-components=1 && \
    mkdir /root/brotli-build && \
    cd /root/brotli-build && \
    scl enable devtoolset-7 -- cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opt/brotli \
        -DCMAKE_C_FLAGS="-fPIC -O3" \
        -DCMAKE_EXE_LINKER_FLAGS="-fPIC --static" \
        /root/brotli && \
    scl enable devtoolset-7 -- cmake \
        --build . \
        --config Release \
        --target install && \
    strip /opt/brotli/bin/brotli && \
    cp /opt/brotli/bin/brotli /opt/bin/ && \
    rm -rf /root/brotli*

RUN cd /opt && \
    tar -zcvf bin.tar.gz bin
