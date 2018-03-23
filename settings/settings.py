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

HOST = '0.0.0.0'

db_url = six.moves.urllib_parse.urlparse(os.environ.get('DB_PORT'))

SQLALCHEMY_DATABASE_URI = (
    'postgresql://dci:dci@%s/dci' % db_url.netloc
)

SQLALCHEMY_ECHO = False


FILES_UPLOAD_FOLDER = '/var/lib/dci-control-server/files'

# Stores configuration, to store files and components
# STORE
STORE_ENGINE = 'Swift'
STORE_USERNAME = 'test'
STORE_PASSWORD = 'test'
STORE_TENANT_NAME = 'test'
swift_url = six.moves.urllib_parse.urlparse(os.environ.get('SWIFT_PORT'))
STORE_AUTH_URL = 'http://%s:5000/v2.0' % swift_url.hostname
STORE_CONTAINER = 'test_components'
STORE_FILES_CONTAINER = 'test_files'
STORE_COMPONENTS_CONTAINER = 'test_components'

ZMQ_CONN = "tcp://127.0.0.1:5557"

SSO_PUBLIC_KEY = os.getenv('SSO_PUBLIC_KEY')
