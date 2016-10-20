#!/bin/bash
systemctl enable mariadb
systemctl start mariadb

sleep 5

mysqladmin create keystone
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';"

keystone-manage db_sync

systemctl enable httpd
systemctl start httpd


mkdir -p /srv/node
cd /etc/swift/

swift-ring-builder object.builder create 7 1 1
swift-ring-builder object.builder add r1z1-127.0.0.1:6010/sdb1 1
swift-ring-builder object.builder rebalance
swift-ring-builder container.builder create 7 1 1
swift-ring-builder container.builder add r1z1-127.0.0.1:6011/sdb1 1
swift-ring-builder container.builder rebalance
swift-ring-builder account.builder create 7 1 1
swift-ring-builder account.builder add r1z1-127.0.0.1:6012/sdb1 1
swift-ring-builder account.builder rebalance

cp *.gz /srv
cp *.builder /srv

systemctl enable openstack-swift-account
systemctl enable openstack-swift-container
systemctl enable openstack-swift-object
systemctl enable openstack-swift-proxy
systemctl start openstack-swift-account
systemctl start openstack-swift-container
systemctl start openstack-swift-object
systemctl start openstack-swift-proxy

systemctl disable systemd-bootstrap
