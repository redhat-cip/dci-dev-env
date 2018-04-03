FROM centos:7

LABEL name="DCI DB" version="0.0.2"
MAINTAINER DCI Team <distributed-ci@redhat.com>

RUN yum install -y centos-release-scl && \
    yum install -y rh-postgresql94-postgresql \
    rh-postgresql94-postgresql-server && \
    yum clean all

RUN ln -s /opt/rh/rh-postgresql94/root/lib64/libpq.so.rh-postgresql94-5 /usr/lib64/libpq.so.rh-postgresql94-5 && \
    ln -s /opt/rh/rh-postgresql94/root/lib64/libpq.so.rh-postgresql94-5 /usr/lib/libpq.so.rh-postgresql94-5

ENV PGDATA /var/opt/rh/rh-postgresql94/lib/pgsql/data
ENV PASSWORD "dci"

USER postgres

RUN . /opt/rh/rh-postgresql94/enable && initdb

# Adjust PostgreSQL configuration to allow connection from all remotes
RUN sed -ri \
    "s/#listen_addresses = '.*?'(.*)/listen_addresses = '*'        \1/" \
    "$PGDATA/postgresql.conf"

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN sed -i \
    "87ahost    all             all             0.0.0.0/0               md5" \
    "$PGDATA/pg_hba.conf"


RUN . /opt/rh/rh-postgresql94/enable && pg_ctl -w -t 300 start &&\
    psql -c "UPDATE pg_database SET encoding = pg_char_to_encoding('UTF8') WHERE datname = 'template1';" &&\
    psql -c "CREATE USER dci WITH SUPERUSER PASSWORD '${PASSWORD}';" &&\
    createdb -O dci dci

VOLUME ["$PGDATA"]
EXPOSE 5432
CMD ["/opt/rh/rh-postgresql94/root/usr/bin/postgres"]
