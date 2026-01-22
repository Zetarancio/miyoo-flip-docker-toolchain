FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git bash build-essential \
    pkg-config python3 python3-pip \
    autoconf automake libtool gettext \
    cmake ninja-build meson \
    file rsync unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*

## user "dev" con UID/GID passati da compose (evita file root nella workspace)
#ARG UID=1000
#ARG GID=1000
#RUN groupadd -g ${GID} dev && useradd -m -u ${UID} -g ${GID} dev

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#USER dev
WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
