#!/bin/bash

grep 'localhost:*:dci:dci:dci' ~/.pgpass || echo 'Please echo do "localhost:*:dci:dci:dci" >> ~/.pgpass; chmod 600 ~/.pgpass'
swift download -o /tmp/last$$.dump backup $(swift list backup -p current/current_|tail -n1) 
docker stop dcidevenv_api_1
PGPASSWORD="dci" pg_restore --clean -h localhost -U dci -W -d dci /tmp/last$$.dump
docker start dcidevenv_api_1
rm /tmp/last$$.dump
