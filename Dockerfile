FROM alpine:3.3
MAINTAINER Matthew Hollick <matthew@mayan-it.co.uk>

ENV KIBANA_MAJOR 4.5
ENV KIBANA_VERSION 4.5.0
ENV ELASTIC_REPO download.elastic.co
ENV ALPINE_REPO dl-3.alpinelinux.org
ENV ALPINE_RELEASE v3.3
ENV ELASTICSEARCH_URL 127.0.0.1:9200
ENV KIBANA_PORT 5601

# Add user and group under which to run kibana
RUN addgroup -S kibana && adduser -S -H -G kibana kibana

RUN mkdir -p /opt/build

# Elastic recommend that kibana be run under the kibana user with tini to reap problems
RUN echo "http://${ALPINE_REPO}/alpine/${ALPINE_RELEASE}/main" > /etc/apk/repositories && \
	echo "http://${ALPINE_REPO}/alpine/${ALPINE_RELEASE}/community" >> /etc/apk/repositories && \
	apk update && apk upgrade && \
	apk add --update --repository http://${ALPINE_REPO}/alpine/edge/community tini && \
	apk add su-exec ca-certificates wget nodejs

# Fetch Kibana and it's checksum from upstream
RUN wget -nvc https://${ELASTIC_REPO}/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz -P /opt/build && \
	wget -nvc https://${ELASTIC_REPO}/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz.sha1.txt -P /opt/build

# If the checksum is correct
#   Unpack kibana
#   Make the directoy path for kibana more friendly
#   Dont use kibana's copy of nodejs as it is linked against glibc
#   Change some file ownerships so that kibana user can only write to the optimiser
RUN cd /opt/build && \
	sha1sum -c kibana-${KIBANA_VERSION}-linux-x64.tar.gz.sha1.txt && \
	tar xzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz -C /opt/ && \
	ln -s /opt/kibana-${KIBANA_VERSION}-linux-x64 /opt/kibana && \
	rm -rf /opt/kibana/node && \
	chgrp -RL kibana /opt/kibana/ && \
	chown -RL kibana /opt/kibana/optimize && \
	mkdir -p /opt/kibana/node/bin && \
	ln -s /usr/bin/node /opt/kibana/node/bin/node

ENV PATH /opt/kibana/bin:$PATH

COPY files/entrypoint.sh /

RUN rm -rf /opt/build

WORKDIR /opt/kibana

EXPOSE ${KIBANA_PORT}
ENTRYPOINT /entrypoint.sh
CMD kibana
