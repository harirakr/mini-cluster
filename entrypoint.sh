#!/usr/bin/env bash

set +ex

if [ $# != 2 ]; then
  echo "Usage: <CMD (init/upgrade)> <image-name>"
  exit 1
fi

cmd=$1
image=$2
echo "CMD: $cmd"
echo "IMAGE: $image"

image_repo=$(echo "${image}" | cut -f1 -d ":")
image_tag=$(echo "${image}" | cut -f2 -d ":")

if [ "${cmd}" == "init" ]; then
  echo "In init"
  helm init --wait --tiller-connection-timeout 300

  if [ "$(kubectl get pods -n kube-system -o name |grep tiller)" -ne 0 ]; then
    echo "Return $?: Issue with deploying tiller"
    exit 1
  fi

  # Add serviceaccount to tiller with clusterrole=cluster-admin
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule \
     --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy \
     -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

  echo "running helm install"
  helm install --debug --set image.repository="${image_repo}" \
     --set image.tag="${image_tag}" --namespace default ./ademo

elif [ "${cmd}" == "upgrade" ]; then
  echo "In upgrade"
  release=$(helm ls | awk '/DEPLOYED.*ademo-1.0.0/ {print $1}' | head -1)
  if [ -n "${release}" ]; then
    helm upgrade --debug "${release}" ./ademo --set image.repository="${image_repo}" \
       --set image.tag="${image_tag}" --namespace default 
  else
    echo "Could not find prior deployment"
    exit 1
  fi
else 
  echo "ERROR: Invalid option ${cmd}"
  exit 1
fi

exit 0
