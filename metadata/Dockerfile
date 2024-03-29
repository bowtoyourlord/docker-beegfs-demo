# BeeGFS metadata server (node02)
FROM ubuntu:20.04

LABEL beegfs_component="metadata"

ENV BEEGFS_VERSION=7.3.0 \
    METADATA_SERVICE_ID=2

RUN apt update && apt install -y apt-transport-https gnupg wget && \
  wget -q -O - https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/gpg/GPG-KEY-beegfs | apt-key add - && \
  wget https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-focal.list -O /etc/apt/sources.list.d/beegfs.list && apt update && \
  apt install -y beegfs-meta && \
  apt remove -y wget apt-transport-https && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

RUN /opt/beegfs/sbin/beegfs-setup-meta -p /data/beegfs/beegfs_meta \
    -s ${METADATA_SERVICE_ID} -m node01

ADD metadata/beegfs/beegfs-meta.conf /etc/beegfs/
ADD connauthfile /etc/beegfs/
ADD metadata/run.sh /

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

EXPOSE 8005
