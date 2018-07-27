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

RUN wget -O /tmp/libjpeg.tar.gz 'http://www.ijg.org/files/jpegsrc.v9c.tar.gz' && \
    mkdir /root/libjpeg && \
    cd /root/libjpeg && \
    tar -zxf /tmp/libjpeg.tar.gz --strip-components=1 && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/libjpeg && \
    scl enable devtoolset-7 -- make && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/libjpeg /tmp/libjpeg.tar.gz

RUN git clone --depth 1 'https://github.com/tjko/jpegoptim.git' && \
    cd jpegoptim && \
    scl enable devtoolset-7 -- env CFLAGS="-O3 -fPIC" LDFLAGS="-static" ./configure --prefix=/opt/jpegoptim --with-libjpeg=/opt/libjpeg && \
    scl enable devtoolset-7 -- make && \
    scl enable devtoolset-7 -- make strip && \
    scl enable devtoolset-7 -- make install && \
    rm -rf /root/jpegoptim
