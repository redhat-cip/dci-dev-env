FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL name="DCI TOX" version="0.2.0"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

WORKDIR /opt/dci-tox

RUN microdnf -y upgrade && \
    microdnf -y install python3-pip python3-devel python3-wheel && \
    microdnf -y install git gcc postgresql-devel && \
    pip3 --no-cache-dir install -U pip && \
    pip3 --no-cache-dir install tox && \
    microdnf -y clean all

ENV DISABLE_DB_START 1
