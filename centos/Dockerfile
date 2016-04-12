FROM centos:6.7
MAINTAINER Matthew Hollick <matthew@mayan-it.co.uk>

ENV KIBANA_MAJOR 4.5
ENV KIBANA_VERSION 4.5.0
ENV ELASTIC_REPO download.elastic.co
#ENV ALPINE_REPO dl-3.alpinelinux.org
#ENV ALPINE_RELEASE v3.3
ENV ELASTICSEARCH_URL 127.0.0.1:9200
ENV KIBANA_PORT 5601
ENV GOSU_VERSION 1.7
ENV TINI_VERSION v0.9.0

# Add user and group under which to run kibana
RUN useradd --system --shell /sbin/nologin --comment "Restricted service account for kibana" kibana

# WTF! centos does not ship with tar by default?
RUN yum clean all && yum upgrade -y && yum install tar -y
RUN mkdir -p /opt/build

# Setup gosu for easier command execution
# Setup tini for better precess wrangling
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys 0527A9B7
ADD "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" "/opt/build/gosu-amd64"
ADD "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" "/opt/build/gosu-amd64.asc"
ADD "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static" "/opt/build/tini-static"
ADD "https://github.com/krallin/tini/releases/download/v0.9.0/tini-static.asc" "/opt/build/tini-static.asc"
RUN gpg --verify /opt/build/gosu-amd64.asc && \
	gpg --verify /opt/build/tini-static.asc && \
	install /opt/build/gosu-amd64 /usr/local/sbin/gosu && \
	install /opt/build/tini-static /usr/local/sbin/tini


# Fetch Kibana and it's checksum from upstream
ADD "https://${ELASTIC_REPO}/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" "/opt/build/kibana-${KIBANA_VERSION}-linux-x64.tar.gz"
ADD "https://${ELASTIC_REPO}/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz.sha1.txt" "/opt/build/kibana-${KIBANA_VERSION}-linux-x64.tar.gz.sha1.txt"
RUN cd /opt/build && \
	sha1sum -c kibana-${KIBANA_VERSION}-linux-x64.tar.gz.sha1.txt && \
	tar xzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz -C /opt/ && \
	ln -s /opt/kibana-${KIBANA_VERSION}-linux-x64 /opt/kibana && \
	chown -RL root:kibana /opt/kibana/ && \
	chown -RL kibana /opt/kibana/optimize

ENV PATH /opt/kibana/bin:$PATH

COPY files/entrypoint.sh /

RUN rm -rf /opt/build /root/.gnupg

WORKDIR /opt/kibana

EXPOSE ${KIBANA_PORT}
ENTRYPOINT /entrypoint.sh
CMD kibana
