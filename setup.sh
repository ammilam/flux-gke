#! /bin/bash

#sets environment variables

export NAME=terraria
export REPO=flux-gke
export USERNAME=ammilam
#sets github specific environment variables to be used later
#read -p 'GitHub Repo: ' REPO
#read -p 'GitHub Username: ' USERNAME
read -sp 'GitHub Password: ' PASSWORD


#gcloud container --project $DEVSHELL_PROJECT_ID clusters create $NAME-$REGION --zone $ZONE

#creates the flux namespace and generates an ssh key
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add fluxcd https://charts.fluxcd.io
kubectl create namespace flux
ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)

kubectl apply -f ./nginx-controller.yaml


#creates an executable to be invoked that creates a git deploy key on the repo specified above
cat <<EOF >>git-key-deploy.sh
#! /bin/bash
curl \
  -X POST \
  -u $USERNAME:$PASSWORD \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$USERNAME/$REPO/keys \
  -d '{"key":"$(cat ./flux/id_rsa.pub)","title":"flux-ssh"}'
EOF
sudo chmod +x git-key-deploy.sh
./git-key-deploy.sh
rm git-key-deploy.sh

#installs flux and helm operator that will kick off and manage the terraria server deployment
cd flux
./installFlux.sh
./installHelmOperator.sh
rm id_rsa*
