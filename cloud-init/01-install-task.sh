#!/bin/bash -e
echo '[start] Install (go-)task'
ARCHITECTURE=$(dpkg --print-architecture)
unset DEB_FILE
case $ARCHITECTURE in
    arm64) DEB_FILE=task_linux_arm64.deb;;
    armhf) DEB_FILE=task_linux_arm.deb;;
esac
if [ -z ${DEB_FILE} ]; then
    echo "[error] Unable to download go-task - unknown architecture $ARCHITECTURE" >&2
    exit 1
fi
WORK_DIR=$(mktemp -d)
cd $WORK_DIR
wget -q http://github.com/go-task/task/releases/latest/download/${DEB_FILE}
dpkg --install ${DEB_FILE}
cd ..
rm -rf $WORK_DIR
task --version
echo '[done] Install (go-)task'
