#!/bin/bash
systemctl enable mariadb
systemctl start mariadb

sleep 5

mysqladmin create keystone
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';"

touch /var/log/keystone/keystone.log
chown keystone:keystone /var/log/keystone/keystone.log
keystone-manage db_sync
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

systemctl enable httpd
systemctl start httpd

mkdir -p /srv/node/sdb

swift-ring-builder /etc/swift/object.builder create 7 1 1
swift-ring-builder /etc/swift/container.builder create 7 1 1
swift-ring-builder /etc/swift/account.builder create 7 1 1
swift-ring-builder /etc/swift/object.builder add r1z1-127.0.0.1:6000/sdb 1
swift-ring-builder /etc/swift/container.builder add r1z1-127.0.0.1:6001/sdb 1
swift-ring-builder /etc/swift/account.builder add r1z1-127.0.0.1:6002/sdb 1
swift-ring-builder /etc/swift/object.builder rebalance
swift-ring-builder /etc/swift/container.builder rebalance
swift-ring-builder /etc/swift/account.builder rebalance

chown -R swift:swift /srv/node

# Create all User / Service / Endpoints
IP=`ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}'`

keystone-manage bootstrap \
    --bootstrap-password admin \
    --bootstrap-admin-url http://${IP}:5001/v3/ \
    --bootstrap-internal-url http://${IP}:5001/v3/ \
    --bootstrap-public-url http://${IP}:5001/v3/ \
    --bootstrap-region-id RegionOne

export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_DOMAIN_NAME=default
export OS_AUTH_URL=http://${IP}:5001/v3
export OS_IDENTITY_API_VERSION=3

openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "DCI Project" dci

# openstack role create user
openstack role create service
openstack role create member
openstack role create user
openstack role create swiftoperator

openstack user create --project service --password swift swift
openstack role add --project service --user swift service
openstack role add --project service --user admin admin

openstack user create --project dci --password dci dci
openstack role add --project dci --user dci member
openstack role add --project dci --user dci user
openstack role add --project dci --user dci swiftoperator

openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region regionOne object-store public http://$IP:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region regionOne object-store internal http://$IP:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region regionOne object-store admin http://$IP:8080/v1

# Remove ipv6 binding
sed -i -e "s/,::1//" /etc/sysconfig/memcached

systemctl enable openstack-swift-account openstack-swift-container openstack-swift-object openstack-swift-proxy memcached
systemctl start openstack-swift-account openstack-swift-container openstack-swift-object openstack-swift-proxy memcached

systemctl disable systemd-bootstrap
