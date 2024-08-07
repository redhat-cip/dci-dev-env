FROM quay.io/centos/centos:stream9

LABEL name="DCI TOX" version="0.1.0"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

COPY . /opt/dci-tox

WORKDIR /opt/dci-tox

RUN set -x  \
    && dnf -y update \
    && dnf -y install \
        ansible-core \
        gcc \
        git \
        postgresql-devel \
        python3-devel \
        python3-pip \
        python3-setuptools \
    && pip3 --no-cache-dir install tox \
    && dnf clean all

ENV DISABLE_DB_START 1
