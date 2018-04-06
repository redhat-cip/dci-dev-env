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
AUTH="--os-url=http://localhost:35357/v2.0/ --os-token=root"
IP=`ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}'`
openstack role create admin $AUTH
openstack role create SwiftOperator $AUTH
openstack project create service $AUTH
openstack project create dci $AUTH
openstack user create admin --project service $AUTH
openstack user create swift --project service --password swift $AUTH
openstack user create dci --project dci --password dci $AUTH
openstack role add --project service --user swift admin $AUTH
openstack role add --project service --user admin admin $AUTH
openstack role add --project dci --user dci SwiftOperator $AUTH
openstack service create --name swift --description "OpenStack Object Storage" object-store $AUTH
openstack endpoint create --region RegionOne object-store --publicurl http://$IP:8080/v1/AUTH_%\(tenant_id\)s --internalurl http://$IP:8080/v1/AUTH_%\(tenant_id\)s --adminurl http://$IP:8080/v1 $AUTH

# Remove ipv6 binding
sed -i -e "s/,::1//" /etc/sysconfig/memcached

systemctl enable openstack-swift-account openstack-swift-container openstack-swift-object openstack-swift-proxy memcached
systemctl start openstack-swift-account openstack-swift-container openstack-swift-object openstack-swift-proxy memcached

systemctl disable systemd-bootstrap
