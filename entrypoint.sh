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

image_repo=$(echo ${image} | cut -f1 -d ":")
image_tag=$(echo ${image} | cut -f2 -d ":")

if [ "${cmd}" == "init" ]; then
  echo "In init"
  helm init 

  # wait until tiller is ready
  is_tiller_running=$(kubectl get po -n kube-system |awk '/tiller.*Running/')
  rc_is_tiller_running=$(echo $?)
  while [ ${rc_is_tiller_running} -ne 0 ]; do
    sleep 5
    is_tiller_running=$(kubectl get po -n kube-system |awk '/tiller.*Running/')
    rc_is_tiller_running=$(echo $?)
  done
  
  # Add serviceaccount to tiller with clusterrole=cluster-admin
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule \
     --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy \
     -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

  helm install --set image.repository=${image_repo} --set image.tag=${image_tag} --namespace default ./ademo

elif [ "${cmd}" == "upgrade" ]; then
  echo "In upgrade"
  release=$(helm ls | awk '/ademo-1.0.0/ {print $1}')
  helm upgrade ${release} ./ademo --set image.repository=${image_repo} --set image.tag=${image_tag} --namespace default 
else 
  echo "ERROR: Invalid option ${cmd}"
  exit 1
fi

exit 0
