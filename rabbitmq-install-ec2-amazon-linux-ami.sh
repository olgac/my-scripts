#!/bin/bash
yum install -y http://www.rabbitmq.com/releases/rabbitmq-server/v3.5.8/rabbitmq-server-3.5.8-1.noarch.rpm
chkconfig rabbitmq-server on
service rabbitmq-server start
rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server restart
rabbitmqctl add_user ahmet ahmet123
rabbitmqctl set_permissions -p / ahmet ".*" ".*" ".*"
rabbitmqctl set_user_tags ahmet administrator
service rabbitmq-server restart
