# Flux

## Prerequisites
Install fluxctl
```
brew install fluxctl
```

Create SSH key:
```
ssh-keygen -t rsa -N '' -f ./id_rsa -C flux <<< y
```

Create Kuberrnetes namespace for flux:
```
kubectl create namespace flux
```

Create Kubernetes secret from private key generated:
```
kubectl create secret generic flux-ssh --from-file=identity=id_rsa -n flux
```

Add public SSH key to Flux Bitbucket Repository using personal access token(Manage Account->Personal Access Token):
```
export BITBUCKET_ACCESS_KEY=<PERSONAL ACCESS TOKEN>
./addAccessKey.sh
```

## Deploy
Add helm repo:
```
helm repo add fluxcd https://charts.fluxcd.io
```


Install flux:
```
./installFlux.sh den3sbx
```

Install Helm Operator:
```
./installHelmOperator.sh
```

## Usage
Force flux sync:
```
fluxctl sync --k8s-fwd-ns=flux
Synchronizing with http://steve@gitlab-sandbox-gitlab-ce.gitlab.svc.cluster.local/devops/k8s-releases-cwow.git
Revision of master to apply is 3c8a9f7
Waiting for 3c8a9f7 to be applied ...
Done.
```
