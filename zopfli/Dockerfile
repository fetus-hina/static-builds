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

RUN yum install --disablerepo=* --enablerepo=base,updates -y patch && yum clean all

ADD static.patch /root/
RUN git clone --branch=zopfli-1.0.2 --depth=1 https://github.com/google/zopfli.git /root/zopfli && \
    cd /root/zopfli && \
    patch < /root/static.patch && \
    scl enable devtoolset-7 -- make -j 4 zopfli && \
    scl enable devtoolset-7 -- make -j 4 zopflipng && \
    strip zopfli && \
    strip zopflipng && \
    mkdir -p /opt/zopfli/bin && \
    cp zopfli zopflipng /opt/zopfli/bin/ && \
    rm -rf /root/zopfli
