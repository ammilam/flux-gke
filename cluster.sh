#! /bin/bash

#sets environment variables
read -p 'GCP Region: ' REGION
export ZONE=$REGION-b
#sets github specific environment variables to be used later
read -p 'Name of Cluster: ' NAME


#creates the k8s cluster in the sepcified region/zone and applies the startup-script daemonset
gcloud container --project $DEVSHELL_PROJECT_ID clusters create $NAME-$REGION --zone $ZONE