#!/bin/bash
TASK_DIR=/usr/src/ubuntu-freepbx/tasks
tar -xf ${TASK_DIR}.tar -C /usr/src/ubuntu-freepbx
rm ${TASK_DIR}.tar
for t in systemd-journal modprobe systemd-units rm-pkgs pam freepbx rpi; do
    task -d ${TASK_DIR}/${t}
done
