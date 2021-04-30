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
## Documentation references
*  [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)
*  [Use a static public IP address for egress traffic in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/egress)

## Prerequsites
### Source code
Access to code repository in GitHub:

`https://github.com/mchudinov/K8sAzureTerraform.git`

### Azure environment
* Storage account *sacommonterraform*
* Storage account container *terraform*

Names are hardcoded in *main.tf* terraform script.

Both storage accounts and container exist in DIFA Azure subscription.

## Tools
This instruction assumes that you use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview). Cloud Shell is an online tool.

In order to use this instruction from a local machine, the folloiwng tools are needed:
*  Terraform version >= 0.15
*  Azure CLI version >= 2.8
*  git
*  kubectl - Kubernetes command line tool

## How to deploy
### 1. Login to Cloud Shell
Open Azure Cloud Shell https://shell.azure.com in a web-browser and login.

### 2. Clone the repository 
```sh
git clone https://github.com/mchudinov/K8sAzureTerraform.git

Cloning into 'K8sAzureTerraform'...
```
### 3. Change to source code directory
`cd K8sAzureTerraform`

### 4. Run deploy.sh script
`./deploy.sh -c mytestk8s -n 3 -r westeurope`

Where flags are:
*  s) Azure service principal ID for terraform
*  c) Cluster name
*  n) Number of nodes
*  r) Azure region

After a couple of minutes a new Kubernetes cluster will be ready.

# How-tos
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

## Kubernetes dashboard is deprecated
The AKS dashboard add-on is set for deprecation. Use the Kubernetes resource view in the Azure portal (preview) instead.

https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard

## How to run an interactive shell

`kubectl apply -f interactive.yaml`

## Check CSI driver is running
```sh
kubectl get csidrivers
kubectl describe csidriver secrets-store.csi.k8s.io
kubectl get pods -l app=secrets-store-csi-driver
```

# Clean up
How to delete everything created in Azure:

Use `./destroy.sh` script with the same parameters as for `./deploy.sh`

For example:

`./destroy.sh -c mytestk8s -n 5`

Delete the source code directory in Cloud Shell:

`rm -rf K8sAzureTerraform`