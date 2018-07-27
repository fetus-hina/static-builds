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
        perl \
        tar \
        wget \
        xz && \
    yum clean all

RUN wget -O /root/zlib.tar.xz 'http://zlib.net/zlib-1.2.11.tar.xz' && \
    mkdir /root/zlib && \
    cd /root/zlib && \
    tar -J -x -v -f /root/zlib.tar.xz --strip-components=1 && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/zlib --static && \
    scl enable devtoolset-7 -- make -j 4 && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/zlib.tar.xz /root/zlib

RUN wget -O /root/openssl.tar.gz 'https://www.openssl.org/source/openssl-1.1.1-pre8.tar.gz' && \
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
    rm -rf /root/openssl.tar.gz /root/openssl

RUN wget -O /root/nghttp2.tar.xz 'https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.xz' && \
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

RUN wget -O /root/c-ares.tar.gz 'https://c-ares.haxx.se/download/c-ares-1.14.0.tar.gz' && \
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

RUN wget -O /root/libidn2.tar.gz 'https://ftp.gnu.org/gnu/libidn/libidn2-2.0.5.tar.gz' && \
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
 
RUN wget -O /root/curl.tar.xz 'https://curl.haxx.se/download/curl-7.61.0.tar.xz' && \
    mkdir /root/curl && \
    cd /root/curl && \
    tar -J -x -v -f /root/curl.tar.xz --strip-components=1 && \
    scl enable devtoolset-7 -- env LD_FLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure \
        --prefix=/opt/curl \
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
    strip /opt/curl/bin/curl && \
    rm -rf /root/curl.tar.xz /root/curl
