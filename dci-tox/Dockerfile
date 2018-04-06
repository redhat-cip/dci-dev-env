FROM centos:7

LABEL name="DCI TOX" version="0.0.1"
MAINTAINER DCI Team <distributed-ci@redhat.com>

ENV LANG en_US.UTF-8

RUN yum install -y epel-release && \
    yum install -y gcc libpqxx-devel libffi-devel openssl-devel \
    python-devel git python34-devel redhat-rpm-config \
    python-lxml libxslt-devel python-pip python34-pip && \
    yum clean all
RUN pip install tox

ENV DISABLE_DB_START 1

ENV TOX_TESTENV_PASSENV "DB_PORT ES_PORT"
ENV DCI_SETTINGS_FILE /tmp/settings/settings_test.py

WORKDIR /opt

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
