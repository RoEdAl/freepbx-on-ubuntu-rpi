#!/bin/bash -e
TASK_DIR=/usr/src/ubuntu-freepbx/tasks
tar -xf ${TASK_DIR}.tar -C /usr/src/ubuntu-freepbx
rm ${TASK_DIR}.tar
task -d ${TASK_DIR}
