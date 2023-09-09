#!/bin/bash -eux
OS_NAME=$(awk -F'=' '/^NAME/{gsub(/"/, ""); print $2}' < /etc/os-release)
[ "$OS_NAME" = "Debian GNU/Linux" ] && apt install -y cloud-init
[ "$OS_NAME" = "Ubuntu" ] && apt install -y cloud-init
[ "$OS_NAME" = "Rocky Linux" ] && dnf install -y cloud-init
cloud-init clean --logs --machine-id
chown root:root /tmp/99-vmware-guest-customization.cfg && mv /tmp/99-vmware-guest-customization.cfg /etc/cloud/cloud.cfg.d/.
vmware-toolbox-cmd config set deployPkg enable-custom-scripts true
systemctl enable cloud-init-local.service cloud-init.service cloud-config.service cloud-final.service
