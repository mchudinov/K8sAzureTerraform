#!/bin/bash

while getopts c:n:r:p:s: flag
do
  case "${flag}" in
    c) name=${OPTARG};;
    n) nodes=${OPTARG};;
    r) region=${OPTARG};;
    p) principal=${OPTARG};;
    s) storage=${OPTARG};;
  esac
done

if test -z "$principal" 
then
  echo "Azure service principal ID for Terraform is empty. Use -s flag"
  exit 0  
fi

if test -z "$name" 
then
  echo "Cluster name is empty. Use -c flag"
  exit 0  
fi

if test -z "$storage" 
then
  echo "Azure storage account to keep Terraform state is empty. Use -s flag"
  exit 0  
fi

if test -z "$nodes" 
then
  echo "Number of nodes in the cluster is not defined. Use -n flag. Use default 3 nodes."
  export nodes=1
fi

if test -z "$region" 
then
  echo "Azure region is not defined. Use -r flag. Default WestEurope"
  export region=westeurope
fi

echo "Cluster name:                     $name";
echo "Number of nodes:                  $nodes";
echo "Azure region:                     $region";

export DEPLOYMENT_NAME=$name
export RESOURCE_GROUP=rg-$DEPLOYMENT_NAME
export AKS_NAME=k8s-$DEPLOYMENT_NAME
export SERVICE_PRINCIPAL_TERRAFORM_ID=$principal
export STORAGE_TERRAFORM_NAME=$storage  
export STORAGE_TERRAFORM_CONTAINER=terraform
export STORAGE_TERRAFORM_CONTAINER_KEY=tfstate-$DEPLOYMENT_NAME

echo "Deployment name:                    $DEPLOYMENT_NAME"
echo "Azure resource group name:          $RESOURCE_GROUP"
echo "AKS resource name:                  $AKS_NAME"
echo "SERVICE_PRINCIPAL_TERRAFORM_ID:     $SERVICE_PRINCIPAL_TERRAFORM_ID"
echo "STORAGE_TERRAFORM_NAME:             $STORAGE_TERRAFORM_NAME"
echo "STORAGE_TERRAFORM_CONTAINER:        $STORAGE_TERRAFORM_CONTAINER"
echo "STORAGE_TERRAFORM_CONTAINER_KEY:    $STORAGE_TERRAFORM_CONTAINER_KEY"

# Create storage container 
az storage container create --account-name $STORAGE_TERRAFORM_NAME --name $STORAGE_TERRAFORM_CONTAINER

# Get storage account key for terraform storage
export STORAGE_TERRAFORM_KEY=$(az storage account keys list --account-name $STORAGE_TERRAFORM_NAME --query "[0].value" --out tsv)
if test -z "$STORAGE_TERRAFORM_KEY" 
then
  echo "Error: STORAGE_TERRAFORM_KEY is empty. Terraform requires it to save the state. Perhaps you need az login. Exit script"
  exit
fi

# Create a new secret for Azure service principal
export SERVICE_PRINCIPAL_TERRAFORM_SECRET=$(az ad app credential reset --id  $SERVICE_PRINCIPAL_TERRAFORM_ID --append --query "password" --out tsv)
if test -z "$SERVICE_PRINCIPAL_TERRAFORM_SECRET" 
then
  echo "Error: SERVICE_PRINCIPAL_TERRAFORM_SECRET is empty. Terraform requires it to operate. Exit script"
  exit
fi

# Export variables to terraform
export TF_VAR_service_princial_terraform_id=$SERVICE_PRINCIPAL_TERRAFORM_ID
export TF_VAR_service_princial_terraform_secret=$SERVICE_PRINCIPAL_TERRAFORM_SECRET
export TF_VAR_k8s_agent_count=$nodes
export TF_VAR_deployment_name=$DEPLOYMENT_NAME
export TF_VAR_rg_name=$RESOURCE_GROUP
export TF_VAR_k8s_cluster_name=$AKS_NAME
export TF_VAR_azure_region=$region
export TF_VAR_k8s_version="1.20.5"
export TF_VAR_k8s_vm_size="Standard_B2s"

# Init Terraform
terraform init \
  -backend-config="storage_account_name=$STORAGE_TERRAFORM_NAME" \
  -backend-config="container_name=$STORAGE_TERRAFORM_CONTAINER" \
  -backend-config="key=$STORAGE_TERRAFORM_CONTAINER_KEY" \
  -backend-config="access_key=$STORAGE_TERRAFORM_KEY" \

# Create the plan
terraform plan -out out.plan

# Apply the plan
terraform apply out.plan

# Add cluster key to the local .kubeconfig file
az aks get-credentials --name $AKS_NAME --resource-group $RESOURCE_GROUP

# Install helm charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add csi-secrets-store-provider-azure https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts
helm repo update

# Add Azure Key Vault CSI driver
helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --generate-name

echo Cluster FQDN:
terraform output fqdn

export PUBLIC_IP_INBOUND=$(terraform output public_ip_inbound_address)
if test -z "$PUBLIC_IP_INBOUND" 
then
  echo "Error: PUBLIC_IP_INBOUND is empty. It is required to configure the ingress. Exit script"
  exit
fi
echo "PUBLIC_IP_INBOUND:    $PUBLIC_IP_INBOUND"

# Nginx ingress controller
kubectl create namespace ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --set controller.service.loadBalancerIP=$PUBLIC_IP_INBOUND 
