#!/bin/bash -e
env SOURCE_DATE_EPOCH=$(./get-source-epoch.sh) task process-ubuntu-imgs
