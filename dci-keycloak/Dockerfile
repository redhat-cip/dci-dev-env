FROM centos:7

LABEL name="DCI KEYCLOAK" version="0.0.1"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

ENV LANG en_US.UTF-8

RUN yum -y install java-1.8.0-openjdk && \
    yum clean all

ENV KEYCLOAK_VERSION 3.2.1.Final
ENV KEYCLOAK_DL_URL https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-${KEYCLOAK_VERSION}.tar.gz

RUN mkdir -p /opt/keycloak
WORKDIR /opt/keycloak

RUN curl -L ${KEYCLOAK_DL_URL} | tar -xz --strip 1

EXPOSE 8180

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-b", "0.0.0.0", "-Djboss.socket.binding.port-offset=100"]
