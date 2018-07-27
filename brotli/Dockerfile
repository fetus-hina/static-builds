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

RUN wget -O /root/brotli.tar.gz https://github.com/google/brotli/archive/v1.0.5.tar.gz && \
    mkdir -p /root/brotli && \
    cd /root/brotli && \
    tar -zxvf /root/brotli.tar.gz --strip-components=1 && \
    mkdir /root/brotli-build && \
    cd /root/brotli-build && \
    scl enable devtoolset-7 -- \
        cmake \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=/opt/brotli \
            -DCMAKE_C_FLAGS="-fPIC -O3" \
            -DCMAKE_EXE_LINKER_FLAGS="-fPIC --static" \
            /root/brotli && \
    scl enable devtoolset-7 -- \
        cmake \
            --build . \
            --config Release \
            --target install && \
    strip /opt/brotli/bin/brotli && \
    rm -rf /root/brotli*
