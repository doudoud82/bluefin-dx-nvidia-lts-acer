#!/bin/bash

set -ouex pipefail

mkdir /rpms

wget https://windscribe.com/install/desktop/linux_rpm_x64 -O /rpms/windscribe.rpm
wget https://www.hamrick.com/files/vuex6498.rpm -O /rpms/vuescan.rpm

cp /ctx/local_rpms/*.rpm /rpms