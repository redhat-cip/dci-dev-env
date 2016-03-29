# -*- encoding: utf-8 -*-
#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

import os
import six

db_url = six.moves.urllib_parse.urlparse(os.environ.get('DB_PORT'))

SQLALCHEMY_DATABASE_URI = (
    'postgresql://dci:password@%s/dci_control_server_test' % db_url.netloc
)

es_url = six.moves.urllib_parse.urlparse(os.environ.get('ES_PORT'))

ES_HOST = es_url.hostname
ES_PORT = es_url.port

influxdb_url = six.moves.urllib_parse.urlparse(
                   os.environ.get('INFLUXDB_PORT_8086_TCP'))
INFLUXDB_HOST = influxdb_url.hostname
INFLUXDB_PORT = influxdb_url.port
