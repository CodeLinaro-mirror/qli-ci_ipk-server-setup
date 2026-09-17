FROM ubuntu:22.04
LABEL maintainer="qswcct.devops@qti.qualcomm.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    libegl1-mesa libsdl1.2-dev xterm python3-subunit mesa-common-dev \
    zstd liblz4-tool file locales curl sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

RUN pip3 install kas

ARG USER=lnxbuild
ARG GROUP=lnxbuild
ARG UID=2366345
ARG GID=2366345
ARG USER_HOME=/home/${USER}
ARG WORKDIR=${USER_HOME}/app

RUN set -x \
    && mkdir -p ${USER_HOME} ${WORKDIR} \
    && groupadd -g ${GID} ${GROUP} \
    && useradd -l -d ${USER_HOME} -u ${UID} -g ${GID} -s /bin/bash ${USER} \
    && chown ${UID}:${GID} ${USER_HOME} ${WORKDIR} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USER
WORKDIR $WORKDIR

RUN git config --global user.email "${USER}@codelinaro.com" \
    && git config --global user.name "${USER}"

# Copy notice generation script
RUN \
    git clone https://git.codelinaro.org/clo/le/qcom-notice.git scripts

RUN ls scripts/

ENTRYPOINT ["/bin/bash", "./scripts/sync_build_kas_robotics_rpm.sh"]
