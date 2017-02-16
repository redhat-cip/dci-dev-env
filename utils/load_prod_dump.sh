#!/bin/bash

if ! grep -q '127.0.0.1:\*:dci:dci:dci' ~/.pgpass; then
    echo 'Please do: echo "127.0.0.1:*:dci:dci:dci" >> ~/.pgpass; chmod 600 ~/.pgpass'
    exit 1
fi
swift download -o /tmp/last$$.dump backup $(swift list backup -p current/current_|tail -n1)
docker stop dcidevenv_api_1
pg_restore --clean -p 5432 -h 127.0.0.1 -U dci -d dci /tmp/last$$.dump
docker start dcidevenv_api_1
rm /tmp/last$$.dump
