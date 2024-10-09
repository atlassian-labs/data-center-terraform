#!/usr/bin/env bash

source "./scripts/common.sh"

NAMESPACE="atlassian"
TIMEOUT=120
INTERVAL=5
PRODUCT=$1
DESIRED_REPLICAS=$2

# check if this is the initial release and exit
STS=$(kubectl get sts -l=app.kubernetes.io/instance="${PRODUCT}" -n "${NAMESPACE}" -o jsonpath='{.items[*].metadata.name}')
if [ -z "$STS" ]; then
  log "No StatefulSets found"
  exit 0
fi

# get existing sts replicas
STS_REPLICAS=$(kubectl get sts $STS -n "${NAMESPACE}" -ojsonpath='{.spec.replicas}')
# Check if DESIRED_REPLICAS is less than STS_REPLICAS and manually scale down
# before Terraform attempts destroying local-home PVC, PV and EBS vol
if [ "${DESIRED_REPLICAS}" -lt "${STS_REPLICAS}" ]; then
  log "Scaling down ${PRODUCT} StatefulSet to ${DESIRED_REPLICAS} replicas"
  kubectl scale sts "${PRODUCT}" -n "${NAMESPACE}" --replicas="${DESIRED_REPLICAS}"

  # make sure pods are gone
  START_TIME=$(date +%s)
  while true; do
    TERMINATING_PODS=$(kubectl get pods -n "${NAMESPACE}" | grep Terminating)
    if [ -z "${TERMINATING_PODS}" ]; then
      log "No pods in Terminating state"
      exit 0
    else
      log "Terminating pods found: ${TERMINATING_PODS}"
    fi
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
    if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
      log "ERROR" "Timeout reached. Pods are still in Terminating state."
      exit 1
    fi
    sleep ${INTERVAL}
  done
else
  log "No need to scale down"
fi
