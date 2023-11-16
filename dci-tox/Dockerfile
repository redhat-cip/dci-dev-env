FROM quay.io/centos/centos:stream8

LABEL name="DCI TOX" version="0.1.0"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

COPY . /opt/dci-tox

WORKDIR /opt/dci-tox

RUN dnf -y update \
    && dnf -y install centos-release-ansible-29 \
    && dnf -y install \
        ansible \
        gcc \
        git \
        postgresql-devel \
        python2-devel \
        python2-pip \
        python2-setuptools \
        python2-wheel \
        python3-devel \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && pip3 --no-cache-dir install tox \
    && dnf clean all

ENV DISABLE_DB_START 1
