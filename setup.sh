#! /bin/bash

#sets environment variables
export REGION=us-east1
export ZONE=$REGION-b
export NAME=terraria-world-1
export WORLD=worlds_World_1.wld
export COMPUTE_ENGINE_SA_EMAIL=$(gcloud iam service-accounts list --filter="name:Compute Engine default service account" --format "value(email)")
export REPO=terraria-world-1
export USERNAME=ammilam
#sets github specific environment variables to be used later
read -p 'GitHub Repo: ' REPO
read -p 'GitHub Username: ' USERNAME
read -sp 'GitHub Password: ' PASSWORD



#creates the flux namespace and generates an ssh key
helm repo add fluxcd https://charts.fluxcd.io
kubectl create namespace flux
ssh-keygen -t rsa -N '' -f ./flux/id_rsa -C flux <<< y
kubectl create secret generic flux-ssh --from-file=identity=./flux/id_rsa -n flux

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
