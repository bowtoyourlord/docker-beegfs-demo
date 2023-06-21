# BeeGFS management server (node01)
FROM ubuntu:20.04

LABEL beegfs_component="management"

ENV BEEGFS_VERSION 7.3.0

RUN apt update && apt install -y apt-transport-https gnupg wget && \
  wget -q -O - https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/gpg/GPG-KEY-beegfs | apt-key add - && \
  wget https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-focal.list -O /etc/apt/sources.list.d/beegfs.list && apt update && \
  apt install -y beegfs-mgmtd beegfs-utils && \
  apt remove -y wget apt-transport-https && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

RUN /opt/beegfs/sbin/beegfs-setup-mgmtd -p /data/beegfs/beegfs_mgmtd

ADD beegfs/beegfs-mgmtd.conf /etc/beegfs/
ADD run.sh /

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

EXPOSE 8008
