FROM centos/postgresql-94-centos7

LABEL name="DCI PostgreSQL" version="0.0.2"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

ENV POSTGRESQL_USER=dci
ENV POSTGRESQL_PASSWORD=dci
ENV POSTGRESQL_DATABASE=dci
ENV POSTGRESQL_ADMIN_PASSWORD=dci
ENV POSTGRESQL_SHARED_BUFFERS=512MB

RUN mkdir /opt/app-root/src/postgresql-cfg
RUN echo "fsync = off" >> /opt/app-root/src/postgresql-cfg/dev.conf
RUN echo "full_page_writes = off" >> /opt/app-root/src/postgresql-cfg/dev.conf
RUN echo "work_mem = 50MB" >> /opt/app-root/src/postgresql-cfg/dev.conf

