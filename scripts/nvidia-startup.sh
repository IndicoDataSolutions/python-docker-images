#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

CHECKPOINT_PATH="${CHECKPOINT_PATH:-/tmp/startup-script.kubernetes.io_$(md5sum <<<"${STARTUP_SCRIPT}" | cut -c-32)}"
CHECK_INTERVAL_SECONDS="30"
EXEC=(nsenter -t 1 -m -u -i -n -p --)
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
POD_NAME=$(uname -n)
NAMESPACE="nvidia-install"
NODE_NAME=$(curl -k -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -X GET https://kubernetes.default/api/v1/namespaces/$NAMESPACE/pods/$POD_NAME | jq -r ". | {node: .spec.nodeName} | .node")

remove_node_taints() {
    while true; do
        if "$EXEC[@]" bash -c "nvidia-smi" 2>&1 | grep -q 'command not found' ; then
            echo "nvidia-smi not installed..."
            sleep 30
        else
            echo "Removing taints from $NODE_NAME"
            curl -k \
                -X PATCH \
                -d '[{"op": "remove","path": "/spec/taints"}]' \
                -H "Authorization: Bearer $TOKEN" \
                -H 'Accept: application/json' \
                -H 'Content-Type: application/json-patch+json' \
                https://kubernetes/api/v1/nodes/$NODE_NAME
            break
        fi

    done
}

add_nvidia_node_taint() {
    echo "Adding taints to $NODE_NAME"
    curl -k \
      -X PATCH \
      -d '[{"op": "add","path": "/spec/taints/0","value": {"key": "nvidia-install","value": "present","effect": "NoSchedule"}}]' \
      -H "Authorization: Bearer $TOKEN" \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json-patch+json' \
      https://kubernetes/api/v1/nodes/$NODE_NAME
}



do_startup_script() {

  add_nvidia_node_taint

  local err=0;

  "${EXEC[@]}" bash -c "${STARTUP_SCRIPT}" && err=0 || err=$?
  if [[ ${err} != 0 ]]; then
    echo "!!! startup-script failed! exit code '${err}'" 1>&2
    return 1
  fi

  "${EXEC[@]}" touch "${CHECKPOINT_PATH}"
  echo "!!! startup-script succeeded!" 1>&2
  remove_node_taints
  return 0
}

while :; do
  "${EXEC[@]}" stat "${CHECKPOINT_PATH}" > /dev/null 2>&1 && err=0 || err=$?
  if [[ ${err} != 0 ]]; then
    do_startup_script
  fi

  sleep "${CHECK_INTERVAL_SECONDS}"
done
