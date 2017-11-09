# database-dumps

This file is here to host database dumps one wants to load in its dci-dev-env
setup.

## How it works ?

Drop the dump in this repository. Specify `DUMP_FILE` variable in
`dci-dev-env/.env` file and start `docker-compose` as usual.

## How to retrieve a production backup ?

Production backup are stored on a Swift cluster.

To retrieve a production backup you need first to retrieve
the Swift `openrc` file that you can find at `dci@swift.distributed-ci.io:openrc`

One can then list the backups: `swift list backup`

One can then download the backup: `swift download backup BACKUPNAME`
