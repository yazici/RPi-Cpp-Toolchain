FROM centos:7 as ct-ng

# Install dependencies to build toolchain
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y autoconf gperf bison file flex texinfo help2man gcc-c++ \
    libtool make patch ncurses-devel python36-devel perl-Thread-Queue bzip2 \
    git wget which xz unzip && \
    yum clean all

# Add a user called `develop` and add him to the sudo group
RUN useradd -m develop && echo "develop:develop" | chpasswd && usermod -aG wheel develop

USER develop
WORKDIR /home/develop

ENV CT_NG_VERSION=1.24.0
RUN git clone -b crosstool-ng-${CT_NG_VERSION} --single-branch --depth 1 \
        https://github.com/crosstool-ng/crosstool-ng.git
WORKDIR /home/develop/crosstool-ng
RUN ./bootstrap && \
    ./configure --prefix=/home/develop/.local && \
    make -j$(($(nproc) * 2)) && \
    make install &&  \
    cd && rm -rf crosstool-ng
ENV PATH=/home/develop/.local/bin:$PATH
