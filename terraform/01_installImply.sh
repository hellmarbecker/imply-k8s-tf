#!/usr/bin/env bash
set -e
REGION=${1}
PROVIDER=${2}

# set current directory of this script
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "MYDIR is ${MYDIR}"

# Deploy Kubernetes Metric Server 
echo "Deploying K8s Metric Server ..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
kubectl get deployment metrics-server -n kube-system

echo "Deploying K8s dashboard ..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc2/aio/deploy/recommended.yaml

echo "Updating Helm repo ..."
helm repo add imply https://static.imply.io/onprem/helm
helm repo update

echo "Installing license file ..."
if [ -f IMPLY_MANAGER_LICENSE_KEY ]; then
    kubectl create secret generic imply-secrets --from-file=IMPLY_MANAGER_LICENSE_KEY
else
    echo " ... License file not found, using evaluation license"
fi

echo "Installing Imply ..."
helm install imply imply/imply -f ${MYDIR}/${PROVIDER}/imply-${PROVIDER}.yaml

echo "####################################"
echo "#### Imply Deployment finished #####"
echo "####################################"
