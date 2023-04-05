FROM centos:6
ENV HOME /root

COPY files/etc--yum.repos.d--CentOS-Vault.repo /etc/yum.repos.d/CentOS-Vault.repo
RUN yum install -y --disablerepo=* \
        https://vault.centos.org/6.10/os/x86_64/Packages/yum-utils-1.1.30-41.el6.noarch.rpm \
        https://vault.centos.org/6.10/os/x86_64/Packages/libxml2-python-2.7.6-21.el6_8.1.x86_64.rpm \
      && \
    yum-config-manager --enable C6.10-base C6.10-updates C6.10-extras && \
    yum-config-manager --disable base updates extras && \
    yum install -y \
        centos-release-scl-rh \
        scl-utils \
      && \
    yum clean all && \
    rm -rf /var/cache/yum
COPY files/etc--yum.repos.d--CentOS-SCLo-scl-rh.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
RUN yum install -y \
        cmake \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ \
        git \
        glibc-static \
        patch \
        perl \
        tar \
        wget \
        xz \
      && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir -p /opt/bin

COPY files/etc--pki--tls--certs--ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt
RUN cp /etc/pki/tls/certs/ca-bundle.crt /usr/share/pki/ca-trust-source/ca-bundle.trust.crt && \
    update-ca-trust extract

# http://zlib.net/
RUN wget --no-check-certificate -O /root/zlib.tar.xz 'http://zlib.net/zlib-1.2.13.tar.xz' && \
    mkdir /root/zlib && \
    cd /root/zlib && \
    tar -J -x -v -f /root/zlib.tar.xz --strip-components=1 && \
    scl enable devtoolset-8 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/zlib --static && \
    scl enable devtoolset-8 -- make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    rm -rf /root/zlib.tar.xz /root/zlib

# libjpeg
# http://www.ijg.org/
COPY patches/jpegtran-* /tmp/
RUN wget --no-check-certificate -O /tmp/libjpeg.tar.gz 'http://www.ijg.org/files/jpegsrc.v9e.tar.gz' && \
    mkdir /root/libjpeg && \
    cd /root/libjpeg && \
    tar -zxf /tmp/libjpeg.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- ./configure --prefix=/opt/libjpeg --enable-static --with-pic CFLAGS="-O3" LDFLAGS="-static" && \
    patch < /tmp/jpegtran-static.patch && \
    scl enable devtoolset-8 -- make && \
    scl enable devtoolset-8 -- make install && \
    strip /opt/libjpeg/bin/jpegtran && \
    cp /opt/libjpeg/bin/jpegtran /opt/bin/ && \
    rm -rf /root/libjpeg /tmp/libjpeg.tar.gz

# https://github.com/nghttp2/nghttp2
RUN wget --no-check-certificate -O /root/nghttp2.tar.xz 'https://github.com/nghttp2/nghttp2/releases/download/v1.52.0/nghttp2-1.52.0.tar.xz' && \
    mkdir /root/nghttp2 && \
    cd /root/nghttp2 && \
    tar -J -x -v -f /root/nghttp2.tar.xz --strip-components=1 && \
    scl enable devtoolset-8 -- ./configure \
        LDFLAGS="-static" \
        --prefix=/opt/nghttp2 \
        --enable-lib-only \
        --enable-static \
        --disable-shared \
        --with-pic \
        --without-systemd && \
    scl enable devtoolset-8 -- make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    rm -rf /root/nghttp2.tar.xz /root/nghttp2

# https://c-ares.haxx.se/
RUN wget --no-check-certificate -O /root/c-ares.tar.gz 'https://c-ares.haxx.se/download/c-ares-1.19.0.tar.gz' && \
    mkdir /root/c-ares && \
    cd /root/c-ares && \
    tar -z -x -v -f /root/c-ares.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- ./configure \
        --prefix=/opt/c-ares \
        --enable-static \
        --disable-shared \
        --with-pic \
        --enable-optimize && \
    scl enable devtoolset-8 -- make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    rm -rf /root/c-ares.tar.gz /root/c-ares


# https://ftp.gnu.org/gnu/libidn/?C=N;O=D
RUN wget --no-check-certificate -O /root/libidn2.tar.gz 'https://ftp.gnu.org/gnu/libidn/libidn2-latest.tar.gz' && \
    mkdir /root/libidn2 && \
    cd /root/libidn2 && \
    tar -z -x -v -f /root/libidn2.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- ./configure \
        --prefix=/opt/libidn2 \
        --enable-static \
        --disable-shared \
        --with-pic && \
    scl enable devtoolset-8 -- make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    rm -rf /root/libidn2.tar.gz /root/libidn2


# https://www.openssl.org/
RUN wget --no-check-certificate -O /root/openssl.tar.gz 'https://www.openssl.org/source/openssl-1.1.1t.tar.gz' && \
    mkdir /root/openssl && \
    cd /root/openssl && \
    tar -z -x -v -f /root/openssl.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- ./config \
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
    scl enable devtoolset-8 -- make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    strip /opt/openssl/bin/openssl && \
    cp /opt/openssl/bin/openssl /opt/bin/ && \
    rm -rf /root/openssl.tar.gz /root/openssl

 
# https://curl.haxx.se/
RUN wget --no-check-certificate -O /root/curl.tar.xz 'https://curl.haxx.se/download/curl-8.0.1.tar.xz' && \
    mkdir /root/curl && \
    cd /root/curl && \
    tar -J -x -v -f /root/curl.tar.xz --strip-components=1 && \
    scl enable devtoolset-8 -- env LD_FLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure \
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
    scl enable devtoolset-8 -- make curl_LDFLAGS="-all-static" -j 4 && \
    scl enable devtoolset-8 -- make curl_LDFLAGS="-all-static" install && \
    strip /opt/bin/curl && \
    rm -rf /root/curl.tar.xz /root/curl


RUN git clone --depth 1 'https://github.com/tjko/jpegoptim.git' && \
    cd jpegoptim && \
    scl enable devtoolset-8 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure \
        --prefix=/opt/jpegoptim \
        --bindir=/opt/bin \
        --with-libjpeg=/opt/libjpeg && \
    scl enable devtoolset-8 -- make && \
    scl enable devtoolset-8 -- make strip && \
    scl enable devtoolset-8 -- make install && \
    rm -rf /root/jpegoptim


# https://github.com/google/zopfli/releases
COPY patches/zopfli-* /tmp/
RUN wget --no-check-certificate -O /root/zopfli.tar.gz https://github.com/google/zopfli/archive/zopfli-1.0.3.tar.gz && \
    mkdir -p /root/zopfli && \
    cd /root/zopfli && \
    tar -zxvf /root/zopfli.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- env CFLAGS="-static" CXXFLAGS="-static" make -j 4 zopfli zopflipng && \
    strip zopfli && \
    strip zopflipng && \
    mkdir -p /opt/bin && \
    cp zopfli zopflipng /opt/bin/ && \
    rm -rf /root/zopfli


# https://github.com/google/brotli/releases
RUN wget --no-check-certificate -O /root/brotli.tar.gz https://github.com/google/brotli/archive/v1.0.9.tar.gz && \
    mkdir -p /root/brotli && \
    cd /root/brotli && \
    tar -zxvf /root/brotli.tar.gz --strip-components=1 && \
    mkdir /root/brotli-build && \
    cd /root/brotli-build && \
    scl enable devtoolset-8 -- cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opt/brotli \
        -DCMAKE_C_FLAGS="-fPIC -O3" \
        -DCMAKE_EXE_LINKER_FLAGS="-fPIC --static" \
        /root/brotli && \
    scl enable devtoolset-8 -- cmake \
        --build . \
        --config Release \
        --target install && \
    strip /opt/brotli/bin/brotli && \
    cp /opt/brotli/bin/brotli /opt/bin/ && \
    rm -rf /root/brotli*

# http://optipng.sourceforge.net/
# RUN wget --no-check-certificate -O /root/optipng.tar.gz https://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.7/optipng-0.7.7.tar.gz && \
RUN /opt/bin/curl -fsSL -o /root/optipng.tar.gz \
        --resolve downloads.sourceforge.net:443:216.105.38.13 \
        https://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.7/optipng-0.7.7.tar.gz && \
    mkdir -p /root/optipng && \
    cd /root/optipng && \
    tar -zxvf /root/optipng.tar.gz --strip-components=1 && \
    scl enable devtoolset-8 -- env LDFLAGS="-static" ./configure \
        -prefix=/opt/optipng \
        -bindir=/opt/bin && \
    scl enable devtoolset-8 -- env LDFLAGS="-static" make -j 4 && \
    scl enable devtoolset-8 -- make install && \
    strip /opt/bin/optipng && \
    rm -rf /root/optipng*

RUN cd /opt && \
    tar -zcvf bin.tar.gz bin
