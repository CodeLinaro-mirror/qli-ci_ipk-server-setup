FROM ubuntu:22.04
LABEL maintainer="qswcct.devops@qti.qualcomm.com"

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        chrpath \
        cpio \
        curl \
        debianutils \
        diffstat \
        file \
        gawk \
        git \
        liblz4-tool \
        locales \
        python3 \
        python3-git \
        python3-jinja2 \
        python3-openpyxl \
        python3-pexpect \
        python3-pip \
        python3-subunit \
        python3-yaml \
        tar \
        texinfo \
        unzip \
        wget \
        xz-utils \
        zip \
        zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && ln -sf /bin/bash /bin/sh

RUN pip3 install --no-cache-dir kas

# JFrog CLI (jf) — used by sync_build_kas.sh for Artifactory uploads
RUN curl -fL https://install-cli.jfrog.io | sh

# Configure non-root user
ARG USER=codelinaro
ARG GROUP=codelinaro
ARG UID=2366345
ARG GID=2366345
ARG USER_HOME=/home/${USER}
ENV USER_HOME=${USER_HOME}

RUN \
    set -x \
    && mkdir -p ${USER_HOME} \
    && chown ${UID}:${GID} ${USER_HOME} \
    && groupadd -g ${GID} ${GROUP} \
    && useradd -l -d ${USER_HOME} -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Switch to non-root user
USER $USER
WORKDIR $USER_HOME
ENV PATH="$USER_HOME/scripts:$PATH"

# Copy notice generation script
RUN git clone https://git.codelinaro.org/clo/le/qcom-notice.git -b modularize-script scripts

ENTRYPOINT ["/bin/bash", "sync_build_kas.sh"]
