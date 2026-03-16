#!/bin/bash

DATE=$(date +%Y%m%d)

pg_basebackup -D /backup/base_$DATE \
-U replicator \
-P -Xs
