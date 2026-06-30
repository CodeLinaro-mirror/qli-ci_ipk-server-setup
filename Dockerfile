FROM ubuntu:22.04
LABEL maintainer="qswcct.devops@qti.qualcomm.com"

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install system package dependencies
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        chrpath \
        cpio \
        curl \
        file \
        debianutils \
        diffstat \
        gawk \
        tar \
        tree \
        gcc \
        git \
        iputils-ping \
        libegl1-mesa \
        liblz4-tool \
        libsdl1.2-dev \
        locales \
        mesa-common-dev \
        openssh-client \
        python3 \
        python3-git \
        python3-jinja2 \
        python3-pexpect \
        python3-pip \
        python3-subunit \
        python3-requests \
        socat \
        sudo \
        texinfo \
        unzip \
        vim \
        wget \
        xterm \
        python3-yaml \
        xz-utils \
        libgtest-dev \
        zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Set python to python3.8.1
    #&& update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 \
    # Generate locales
    && locale-gen en_US.UTF-8 \
    # Update default sh
    && ln -sf /bin/bash /bin/sh

# Install repo tool
RUN \
    wget -qP /usr/local/bin https://storage.googleapis.com/git-repo-downloads/repo \
    && chmod a+x /usr/local/bin/repo

RUN pip3 install --no-cache-dir kas

# Configure non-root user omniscan
ARG USER=codelinaro
ARG GROUP=codelinaro
ARG UID=2366345
ARG GID=2366345
ARG USER_HOME=/home/${USER}
ARG WORKDIR=${USER_HOME}/app

RUN \
    set -x \
    && mkdir -p ${USER_HOME} ${WORKDIR} \
    && chown ${UID}:${GID} ${USER_HOME} \
    && chown ${UID}:${GID} ${WORKDIR} \
    && groupadd -g ${GID} ${GROUP} \
    && useradd -l -d ${USER_HOME} -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Switch to non-root user
USER $USER
WORKDIR $WORKDIR


# Configure .gitconfig
RUN \
    git config --global user.email $USER@codelinaro.com \
    && git config --global user.name $USER

# Copy notice generation script
RUN \
    git clone https://git.codelinaro.org/clo/le/qcom-notice.git scripts

ENTRYPOINT ["/bin/bash", "./scripts/sync_build_kas_robotics.sh"]
