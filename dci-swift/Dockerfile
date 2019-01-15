FROM centos/systemd

LABEL name="DCI SWIFT" version="0.0.3"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

ENV LANG en_US.UTF-8

RUN yum install -y centos-release centos-release-openstack-pike && \
    yum install -y openstack-swift openstack-swift-proxy memcached \
    openstack-swift-object openstack-swift-container openstack-swift-account \
    openstack-keystone mariadb-server httpd mod_wsgi python-swiftclient \
    python-openstackclient && \
    yum clean all

ADD conf/bootstrap.sh /sbin/bootstrap.sh
ADD conf/systemd-bootstrap /etc/systemd/system/systemd-bootstrap.service
ADD conf/wsgi-keystone.conf /etc/httpd/conf.d/
ADD conf/account-server.conf /etc/swift/
ADD conf/object-server.conf /etc/swift/
ADD conf/container-server.conf /etc/swift/
ADD conf/proxy-server.conf /etc/swift/
ADD conf/keystone.conf /etc/keystone/

RUN chmod +x /sbin/bootstrap.sh

RUN systemctl enable systemd-bootstrap

EXPOSE 5000 8080 35357
