# BeeGFS storage server (node03)
FROM ubuntu:20.04

LABEL beegfs_component="storage"

ENV BEEGFS_VERSION=7.3.0 \
    STORAGE_SERVICE_ID="3" \
    STORAGE_TARGET_ID="301" \
    STORAGE_LOCATION="/data"

RUN apt update && apt install -y apt-transport-https gnupg wget && \
  wget -q -O - https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/gpg/GPG-KEY-beegfs | apt-key add - && \
  wget https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-focal.list -O /etc/apt/sources.list.d/beegfs.list && apt update && \
  apt install -y beegfs-storage && \
  apt remove -y wget apt-transport-https && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${STORAGE_LOCATION} && \
    /opt/beegfs/sbin/beegfs-setup-storage -p ${STORAGE_LOCATION} \
        -s ${STORAGE_SERVICE_ID} -i ${STORAGE_TARGET_ID} -m node01

VOLUME ${STORAGE_LOCATION}

ADD beegfs/beegfs-storage.conf /etc/beegfs/

ADD run.sh /

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

EXPOSE 8003
