#!/bin/bash -e
if ! git log -n 1 '--pretty=format:%ct' -- :/$1
then
    date -r Taskfile.dist.yml -u '+%s'
fi