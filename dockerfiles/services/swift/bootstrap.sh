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

# Create all User / Service / Endpoints
AUTH="--os-url=http://localhost:35357/v2.0/ --os-token=root"
ROLE_ID=`openstack role create admin $AUTH | grep " id " | awk '{print $4}'`
SOP_ID=`openstack role create SwiftOperator $AUTH | grep " id " | awk '{print $4}'`
SERVICE_ID=`openstack project create service $AUTH | grep " id " | awk '{print $4}'`
PROJECT_ID=`openstack project create test $AUTH | grep " id " | awk '{print $4}'`
ADMIN_ID=`openstack user create admin --project $SERVICE_ID $AUTH | grep " id " | awk '{print $4}'`
SWIFT_ID=`openstack user create swift --project $SERVICE_ID --pass swift $AUTH | grep " id " | awk '{print $4}'`
USER_ID=`openstack user create swift --project $PROJECT_ID --pass test $AUTH | grep " id " | awk '{print $4}'`
openstack role add --project $SERVICE_ID --user $SWIFT_ID admin $AUTH
openstack role add --project $SERVICE_ID --user $ADMIN_ID admin $AUTH
openstack role add --project $PROJECT_ID --user $USER_ID SwiftOperator $AUTH


systemctl enable openstack-swift-account
systemctl enable openstack-swift-container
systemctl enable openstack-swift-object
systemctl enable openstack-swift-proxy
systemctl start openstack-swift-account
systemctl start openstack-swift-container
systemctl start openstack-swift-object
systemctl start openstack-swift-proxy

systemctl disable systemd-bootstrap
