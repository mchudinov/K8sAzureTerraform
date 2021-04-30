#!/bin/bash

while getopts c:i:n:e: flag
do
  case "${flag}" in
    c) name=${OPTARG};;
    n) nodes=${OPTARG};;
  esac
done

if test -z "$name" 
then
  echo "Cluster name is empty. Use -c flag"
  exit 0  
fi

if test -z "$nodes" 
then
  echo "Number of nodes in the cluster is not defined. Use -n flag. Use default 3 nodes."
  export nodes=3
fi

echo "Cluster name:                     $name";
echo "Number of nodes:                  $nodes";

export DEPLOYMENT_NAME=$name
export RESOURCE_GROUP=rg-$DEPLOYMENT_NAME
export AKS_NAME=k8s-$DEPLOYMENT_NAME
export SERVICE_PRINCIPAL_TERRAFORM_ID=846f0948-ede3-4a1a-82fb-5cb3c47ba4ca
export STORAGE_TERRAFORM_NAME=sacommonterraform  
export STORAGE_TERRAFORM_CONTAINER=terraform
export STORAGE_TERRAFORM_CONTAINER_KEY=tfstate-$DEPLOYMENT_NAME

echo "Deployment name:                    $DEPLOYMENT_NAME"
echo "Azure resource group name:          $RESOURCE_GROUP"
echo "AKS resource name:                  $AKS_NAME"
echo "SERVICE_PRINCIPAL_TERRAFORM_ID:     $SERVICE_PRINCIPAL_TERRAFORM_ID"
echo "STORAGE_TERRAFORM_NAME:             $STORAGE_TERRAFORM_NAME"
echo "STORAGE_TERRAFORM_CONTAINER:        $STORAGE_TERRAFORM_CONTAINER"
echo "STORAGE_TERRAFORM_CONTAINER_KEY:    $STORAGE_TERRAFORM_CONTAINER_KEY"

# Get storage account key for terraform storage
export STORAGE_TERRAFORM_KEY=$(az storage account keys list --account-name $STORAGE_TERRAFORM_NAME --query "[0].value" --out tsv)
if test -z "$STORAGE_TERRAFORM_KEY" 
then
  echo "Error: STORAGE_TERRAFORM_KEY is empty. Terraform needs it to save the state. Perhaps you need az login. Exit script"
  exit
fi

# Create a new secret for Azure service principal
export SERVICE_PRINCIPAL_TERRAFORM_SECRET=$(az ad app credential reset --id  $SERVICE_PRINCIPAL_TERRAFORM_ID --append --query "password" --out tsv)
if test -z "$SERVICE_PRINCIPAL_TERRAFORM_SECRET" 
then
  echo "Error: SERVICE_PRINCIPAL_TERRAFORM_SECRET is empty. Terraform needs it to operate. Exit script"
  exit
fi

# Export variables to terraform
export TF_VAR_service_princial_terraform_id=$SERVICE_PRINCIPAL_TERRAFORM_ID
export TF_VAR_service_princial_terraform_secret=$SERVICE_PRINCIPAL_TERRAFORM_SECRET
export TF_VAR_k8s_agent_count=$nodes
export TF_VAR_deployment_name=$DEPLOYMENT_NAME
export TF_VAR_rg_name=$RESOURCE_GROUP
export TF_VAR_k8s_cluster_name=$AKS_NAME

terraform destroy -auto-approve