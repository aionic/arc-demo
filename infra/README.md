1. Make sure to either edit the enve file at the root of the repo or add a .env file next too it to override any values you might want to change.
1. Make sure you are logged into Azure on bash command line and the correct subscription is selected
1. To deploy everything run 0-deploy-all.sh
1. Alternatively you can run the scripts one at a time in order


## 1-configCli.sh
This will install the required extensions to your Azure command line interface and will register required resource prviders in you account.  The following will be installed or upgraded:


1. [connectedk8s extension](https://docs.microsoft.com/cli/azure/connectedk8s?view=azure-cli-latest): Adds commands required to manage Arc connected Kubernetes.
1. [k8s-extensions extension](https://docs.microsoft.com/cli/azure/k8s-extension?view=azure-cli-latest): Adds commands required to manage extensions for Arc connected clusters
1. [customlocation extension](https://docs.microsoft.com/cli/azure/customlocation?view=azure-cli-latest): Adds commands to manage custom locations.
1. [appservice-kub](https://docs.microsoft.com/cli/azure/appservice/kube?view=azure-cli-latest): Adds commands to manage kubernetes hosted app service environment
1. [Register Microsoft.ExtendedLocation](https://docs.microsoft.com/azure/azure-arc/kubernetes/custom-locations): Manages custom locations in your subscription
1. [Register Microsoft.Web](https://docs.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers): Manages App Services and Functions resources in your subscription
1. [Register Microsoft.KubernetesConfiguration](https://docs.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers): Manages Arc enabled Kubernetes resources in your subscription

## 2-deploy-cluster.sh
We are going to use a AKS cluster, though Arc enabling an AKS cluster is redundant it's much easier than creating a Kubernetes cluster from scratch.  However this can be deployed on any CNCF compliant Kubernetes.  This will deploy an AKS cluster into your subscription the following resources will be created: (see main.bicep for details)
1. Resource group to contain your AKS cluster and related services
1. A Log Analytics workspace
1. A 3 node AKS cluster (with all required resources)
1. An external IP address, in your cluster's managed resources resource group, used to connect the cluster to Arc later.

## 3-connect-cluster.sh
In this we connect the cluster to Azure Arc using the connectedk8s extension we installed in step 1.  This step is going to take a while, since the process will be deploying a series resources to your cluster for management through Azure. [See here for more information of what is happening at this step](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-cluster-connect).
The following changes are going to be made:
1. A new resource group is created to hold the Arc enabled Kubernetes's resources
1. Connect to the cluster as an administrator
1. Run **az connectedk8s connect** command to connect the cluster to azure after this step you should be able to find a resource of **type Kubernetes - Azure Arc** in the above resource group.
1. Run **az connectedk8s enable-features --features cluster-connect** command to enable the connected cluster feature.

AT this point you should have a new namespace in your cluster called *azure-arc* try **kubectl get all -n azure-arc** to see what was added to the cluster.

## 4-deploy-appservice.sh 
In this step we are going to install a [cluster extension](https://docs.microsoft.com/azure/azure-arc/kubernetes/conceptual-extensions) called [Microsoft.Web.Appservice](https://docs.microsoft.com/azure/app-service/overview-arc-integration) which will install all resources required to run App Service, Functions and Logic Apps on your cluster.  All these resources will be deployed in the namespace you specify (by default appservice-ns)

## 5-create-custom-location.sh
In this step we will create a [custom location](https://docs.microsoft.com/azure/azure-arc/kubernetes/custom-locations) to identify this cluster and the extension we created.

## 6-create-cube-ase.sh
Finally create an app service environment and connect it to the custom location we created before to enable deployment.