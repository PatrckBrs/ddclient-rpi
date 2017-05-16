FROM armhf/alpine:3.5

LABEL maintainer Patrick Brunias <patrick@brunias.org>

ENV DDCLIENT_VERSION=3.8.3

RUN apk update && \
    apk add --no-cache \
            wget \
            perl \
            curl \
            make \
            perl-io-socket-ssl

# install Perl cpan modules not in alpine : Thanks to https://github.com/linuxserver
RUN curl -L http://cpanmin.us | perl - App::cpanminus && cpanm JSON::Any

RUN wget -P /tmp/ https://freefr.dl.sourceforge.net/project/ddclient/ddclient/ddclient-${DDCLIENT_VERSION}.tar.bz2 --no-check-certificate

RUN cd /tmp && tar xjvf ddclient-${DDCLIENT_VERSION}.tar.bz2

RUN cp /tmp/ddclient-${DDCLIENT_VERSION}/ddclient /usr/sbin/ddclient && chmod +x /usr/sbin/ddclient

RUN apk del --purge make wget curl && \
    rm -rf /root/.cpanm \
           /tmp/*

RUN mkdir -m0755 /etc/ddclient && \
    mkdir -p -m0755 /var/cache/ddclient && \
    mkdir -p -m0755 /var/run/ddclient

COPY ./ddclient.conf /etc/ddclient/ddclient.conf

RUN chmod 0600 /etc/ddclient/ddclient.conf && \
    touch /var/cache/ddclient/ddclient.cache

VOLUME /etc/ddclient

STOPSIGNAL SIGQUIT

ENTRYPOINT "/usr/sbin/ddclient" "," "tail -f /var/cache/ddclient/ddclient.cache"
