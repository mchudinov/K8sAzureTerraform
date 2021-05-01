# Deploy a Kunernetes cluster with a static public IP for egress

## Infrastructure
An Azure Kubernetes Service (AKS) with a static public IP address for egress traffic.
```
╔══════════════════════════════════════════════════════════════╗                  ╔══════════════╗  
║ Azure                                                        ║                  ║ https://...  ║
║ ┌────────────────────┐       ┌────────────┐                  ║                  ║              ║
║ │░ Kuebernetes(AKS) ░│   ┌─<─┤ Inbound IP ├<─────────────────╟<─────https───────╢ web-browser  ║
║ │░░░░░░░░░░░░░░░░░░░░│   │   └────────────┘                  ║                  ╚═════╤══╤═════╝
║ │░░░ Ingress Nginx <─┼<──┘                                   ║                       ═╧══╧═ 
║ │░░░░░░░░░░░░░░░░░░░░│       ┌────────────┐                  ║                    
║ │░░░░░░░░░░ secrets ░├<────<─┤ Key Vault  │                  ║
║ │░░░░░░░░░░░░░░░░░░░░│       └────────────┘                  ║
║ │░░░░░░░░░░░░░░░░░░░░│                         ┌─────────────╢               
║ │░░░░░░░░░░░░░░░░░░░░┼>───────────────────>────┤ Outbound IP ║ 
║ │░░░░░░░░░░░░░░░░░░░░│                         └─────────────╢                
║ └────────────────────┘                                       ║               
╚══════════════════════════════════════════════════════════════╝                                                                                               
```
* Hardcoded Kubernetes version: **1.20.5**
* Hardcoded VM size for nodes: **Standard_B2s** (2 vCPU, 4GiB memory)

These values can be chenged in _deploy.sh_ script.

## Related documentation
*  [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)
*  [Use a static public IP address for egress traffic in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/egress)

## Prerequsites
### Source code
Access to code repository in GitHub
https://github.com/mchudinov/K8sAzureTerraform.git

### Azure environment
* Service principal that has access to subscription at _Contributor_ role
* Storage account to store terrraform state
* Azure Kubernetes policy insights registered on subscription level
```sh
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.PolicyInsights
```

## Tools
This instruction assumes that you use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)

In order to use this instruction from a local machine, the folloiwng tools are needed:
*  Terraform version >= 0.14
*  Azure CLI version >= 2.8
*  git
*  kubectl - Kubernetes command line tool
*  Bash shell 

## How to deploy
### 1. Login to Cloud Shell
Open Azure Cloud Shell https://shell.azure.com in a web-browser and login.

### 2. Clone the repository 
`git clone https://github.com/mchudinov/K8sAzureTerraform.git`

### 3. Change to source code directory
`cd K8sAzureTerraform`

### 4. Run deploy.sh script
`./deploy.sh -c mytestk8s -n 3 -r westeurope -p XXX-XXXX-XXX-XXX -s terraformstate`

The keys are:
*  c) Cluster name
*  n) Number of nodes (default 3)
*  r) Azure region (default WestEurope)
*  p) Azure service principal ID for Terraform
*  s) Storage account name for Terraform state

After a couple of minutes a new Kubernetes cluster will be ready.

# How-tos
## Add Kubernetes credentials to the local .cube config file
`az aks get-credentials --name <AKS_NAME> --resource-group <RESOURCE_GROUP>`

## Verify egress address
This command will run a tiny Alpine linux on a pode inside the cluster:

`kubectl run -it --rm checkip --image alpine`

Then from inside the Alpine linux install a **curl** program.

`apk --no-cache add curl`

And finally check the outging IP on the public service **checkip.dyndns.org**.
```sh
curl checkip.dyndns.org

<html><head><title>Current IP Check</title></head><body>Current IP Address: 40.121.183.52</body></html>
```
The IP address must be the same as created by the template.

Then exit the Alpine:

`exit`

Alpine pod will be immidiately automatically destroed after exit.

## How to run an interactive shell
`kubectl apply -f interactive.yaml`

## Check CSI driver is running
```sh
kubectl get csidrivers
kubectl describe csidriver secrets-store.csi.k8s.io
kubectl get pods -l app=secrets-store-csi-driver
```

# Clean up
## Delete everything created in Azure:
Use _destroy.sh_ script with the same parameters as for _deploy.sh_

For example:

`./destroy.sh -c mytestk8s -n 3 -r westeurope -p XXX-XXXX-XXX-XXX -s terraformstate`

## Reset changes in git
`git reset`

## Delete the source code directory in Cloud Shell
`rm -rf K8sAzureTerraform`