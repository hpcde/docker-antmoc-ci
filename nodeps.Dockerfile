ARG   BASE_IMAGE="leavesask/gcc:latest"
FROM  $BASE_IMAGE
LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

# install basic tools
WORKDIR /tmp
RUN set -ex; \
      \
      apt-get update; \
      apt-get install -y \
              git \
              make \
              sudo

# set spack root
ENV SPACK_ROOT=/opt/spack

# set user name
ARG USER_NAME=one
ENV USER_HOME="/home/${USER_NAME}"

# create the first user
RUN set -eu; \
      \
      if ! id -u ${USER_NAME} > /dev/null 2>&1; then \
          useradd -m ${USER_NAME}; \
          echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
          cp -r ~/.spack $USER_HOME; \
          chown -R ${USER_NAME}: $USER_HOME/.spack; \
      fi

# set compiler
ARG COMPILER_SPEC="gcc@9.2.0"
ENV COMPILER_SPEC=$COMPILER_SPEC
ARG EXTRA_SPECS=""
ENV EXTRA_SPECS=$EXTRA_SPECS

# install cmake
RUN set -e; \
    spack install cmake@3.16.2 %$COMPILER_SPEC $EXTRA_SPECS; \
    spack clean -a

# install lcov
ARG LCOV_VERSION="1.14"
ENV LCOV_VERSION=${LCOV_VERSION}
RUN set -e; \
    spack install lcov@${LCOV_VERSION} %$COMPILER_SPEC $EXTRA_SPECS; \
    spack clean -a

# transfer control to the default user
USER $USER_NAME
WORKDIR $USER_HOME

# setup development environment
ENV ENV_FILE="$USER_HOME/setup-env.sh"
RUN set -e; \
      \
      echo "#!/bin/env bash" > $ENV_FILE; \
      echo "source $SPACK_ROOT/share/spack/setup-env.sh" >> $ENV_FILE; \
      echo "spack load cmake@3.16.2" >> $ENV_FILE; \
      echo "spack load lcov@${LCOV_VERSION}" >> $ENV_FILE

# reset the entrypoint
ENTRYPOINT []
CMD ["bin/bash"]


#-----------------------------------------------------------------------
# Build-time metadata as defined at http://label-schema.org
#-----------------------------------------------------------------------
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="Docker image for ANT-MOC CI" \
      org.label-schema.description="Provides tools for testing and code coverage (no pre-installed dependencies)" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.schema-version="1.0"
