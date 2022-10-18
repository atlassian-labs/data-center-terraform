#!/bin/bash

CLUSTER_NAME=$1
AWS_REGION=$2
DEBUG_FOLDER=$3

SCRIPT=$(basename "$0")

if [ -z ${CLUSTER_NAME} ]; then
  echo "[ERROR]: cluster name not provided as the first argument to the script"
  echo "[ERROR]: example: ${SCRIPT} my-cluster us-east-1"
  exit 1
fi

if [ -z ${AWS_REGION} ]; then
  echo "[ERROR]: AWS region not provided as the second argument to the script"
  echo "[ERROR]: example: ${SCRIPT} my-cluster us-east-1"
  exit 1
fi

# update kubeconfig context to authenticate with the cluster
echo "[INFO]: Updating kubeconfig context"
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}

if [ -z "${DEBUG_FOLDER}" ]; then
  DEBUG_FOLDER="../test/e2etest/artifacts/k8s-debug-$1-$2"
fi

mkdir -p "${DEBUG_FOLDER}"

echo "[INFO]: Getting pods logs"

PODS=$(kubectl get pods -n atlassian --no-headers -o custom-columns=":metadata.name")
for POD in ${PODS[@]}; do
  kubectl logs ${POD} -n atlassian > "${DEBUG_FOLDER}"/${POD}_log.log 2>&1
  kubectl describe pod ${POD} -n atlassian > "${DEBUG_FOLDER}"/${POD}_describe.log 2>&1
done

NGINX_PODS=$(kubectl get pods -n ingress-nginx --no-headers -o custom-columns=":metadata.name")
for POD in ${NGINX_PODS[@]}; do
  kubectl logs ${POD} -n ingress-nginx > "${DEBUG_FOLDER}"/${POD}_log.log 2>&1
  kubectl describe pod ${POD} -n ingress-nginx > "${DEBUG_FOLDER}"/${POD}_describe.log 2>&1
done

# checking status of Nginx ingress is important to troubleshoot any LOadBalancer issues
kubectl describe svc -n ingress-nginx > "${DEBUG_FOLDER}"/nginx_svc_describe.log 2>&1

echo "[INFO]: Getting namespaces pods and events"

kubectl get events -n atlassian > "${DEBUG_FOLDER}"/events.log 2>&1
kubectl get pods -n atlassian > "${DEBUG_FOLDER}"/all_pods.log 2>&1

echo "[INFO]: Describing resources"

RESOURCES=(svc ingress pvc pv)
for RESOURCE in ${RESOURCES[@]}; do
  kubectl describe ${RESOURCE} -n atlassian > "${DEBUG_FOLDER}"/${RESOURCE}_describe.log 2>&1
done

echo "[INFO]: Describing nodes"
kubectl describe nodes > "${DEBUG_FOLDER}"/nodes.log 2>&1

echo "[INFO]: Logs and events saved to ${DEBUG_FOLDER}"
ls -la "${DEBUG_FOLDER}"
