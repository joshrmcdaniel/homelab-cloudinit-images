set -euo pipefail;

VM_ID=$(vim-cmd vmsvc/getallvms | awk "/$VM_NAME/"'{print $1}')
until [ ! -z "$VM_ID" ]; do
    echo "[`date +'%Y-%m-%dT%H:%M:%S'`] Waiting for VM ID.."
    sleep 5;
    VM_ID=$(vim-cmd vmsvc/getallvms | awk "/$VM_NAME/"'{print $1}')
done;

until vim-cmd vmsvc/power.getstate $VM_ID | grep "Powered off"; do
    echo "[`date +'%Y-%m-%dT%H:%M:%S'`] VM still provisioning.. (ID: $VM_ID)"
    sleep 15;
done
