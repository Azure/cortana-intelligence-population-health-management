# Azure Machine Learning Workbench

## Outline

- [Prerequisites](#prereqs)
- [Provision Azure Resources](#provision)
   - [Choose a Unique String](#unique)
   - [Create a Resource Group](#rg)
   - [Create a Storage Account with Source Data](#storageaccount)
   - [Create an Ubuntu DSVM](#dsvm)
   - [Create an HDInsight Spark cluster](#hdinsight)  
- [Model Tuning with AML Workbench](#useamlworkbench)
   - [Create a New Project](#createproj)
   - [Hyperparameter Tuning in Remote Docker Container](#train_docker)
   - [Hyperparameter Tuning in HDInsight Spark Cluster](#train_sparkcluster)
- [Extended Reading](#details)
	- [Feature Engineering](#featurnengineering)
	- [Compute in Remote Docker Container](#er_docker)
	- [Compute in Spark Cluster](#er_cluster)
- [Architecture Diagram](#diagram)
- [Conclusion](#conclusion)
- [References](#reference)

<a name="prereqs"></a>
## Prerequisites

Before you begin, ensure that you have the following:

* An [Azure account](https://azure.microsoft.com/en-us/free/) (free trials are available).
* An installed copy of [Azure Machine Learning Workbench](./overview-what-is-azure-ml.md) following the [quick start installation guide](./quick-start-installation.md) to install the program and create a workspace.
* This scenario assumes that you are running AML Workbench on Windows 10 or MacOS with Docker engine locally installed. 
* To run scenario with remote Docker container, provision Ubuntu Data Science Virtual Machine (DSVM) by following the instructions [here](https://docs.microsoft.com/en-us/azure/machine-learning/machine-learning-data-science-provision-vm). We recommend using a virtual machine with at least 8 cores and 28 Gb of memory. D4 instances of virtual machines have such capacity. 
* To run this scenario with Spark cluster, provision HDInsight cluster by following the instructions [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-provision-linux-clusters). We recommend having a cluster with at least six worker nodes and at least 8 cores and 28 Gb of memory in both header and worker nodes. D4 instances of virtual machines have such capacity. To maximize performance of the cluster, we recommend to change the parameters spark.executor.instances, spark.executor.cores, and spark.executor.memory by following the instructions [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-resource-manager) and editing the definitions in "custom spark defaults" section.

     >**Note**: Your Azure subscription might have a quota on the number of cores that can be used. Azure portal does not allow creation of cluster with the total number of cores exceeding the quota. To find you quota, go in Azure portal to Subscriptions section, click on the subscription used to deploy a cluster and then click on Usage+quotas. Usually quotas are defined per Azure region and you can choose to deploy Spark cluster in a region where you have enough free cores.
* Create Azure storage account that is used for storing dataset. You can find instructions for creating storage account [here](https://docs.microsoft.com/en-us/azure/storage/common/storage-create-storage-account).
* Source data. The data can be downloaded from [TalkingData dataset](https://www.kaggle.com/c/talkingdata-mobile-user-demographics/data) (Seven files including app\_events.csv.zip, 
app\_labels.csv.zip, events.csv.zip, gender\_age\_test.csv.zip, gender\_age\_train.csv.zip, label\_categories.csv.zip, phone\_brand\_device\_model.csv.zip).   



<a name="provision"></a>
## Provision Azure Resources

<a name="unique"></a>
### Choose a Unique String

To help keep track of the Azure resources you create in this tutorial, we suggest that you select a unique string that will be incorporated into the name of each Azure resource you create. This string should include only lowercase letters and numbers, and be less than 20 characters in length. To ensure that your string is unique and has not been chosen by another Azure user, we recommend including your initials as well as a random number. 

<a name="rg"></a>
### Create a Resource Group

We recommend creating all the Azure resources needed for this tutorial under the same, temporary resource group: you can then easily delete all the resources in one go once you are finished with this deployment guide. You will be asked to choose a location for your resource group: we recommend choosing a location in which your Azure subscription has at least 24 cores available for the creation of a HDInsight cluster. (There is typically no limit in the creation of the other types of Azure resources used in this tutorial).

To create the resource group:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button located at the upper left portion of the screen.
1. Type "Resource group" into the search box and then press Enter.
1. Click on the "Resource group" option published by Microsoft from the search results. Click on the blue "Create" button that appears on right pane.
1. In the new pane:    
    1. Enter your **unique string** for the "Resource group name".
    1. Select the appropriate subscription and resource group location.
    1. Check the "Pin to dashboard" checkbox option.
    1. Press "Create".
    > **NOTE:** The resource availability in different regions depends on your subscription. When deploying you own resources, make sure all data storage and compute resources are created in the same region to avoid inter-region data movement. Azure Resource Group does not have to be in the same region as the other resources. It is a virtual group that groups all the resources into one solution. All the above mentioned resources should be deployed using the same subscription.
    
You will be taken to the resource group's overview page when the deployment is complete. In the future, you can navigate to the resource group's overview page from your [Azure Portal](https://ms.portal.azure.com/) dashboard.

<a name="storageaccount"></a>
#### Create a Storage Account with Source Data 

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "storage account" into the search box and then press Enter.
1. Click on the "storage account - blob, file, table, queue" option published by Microsoft from the search results. Click on the blue "Create" button that appears on the  right pane.
1. In the "Create storage account" pane that appears:
    1. Enter your **unique string** in the "Name" field.
    1. Select the appropriate subscription, resource group, and location.
    1. Click "Create".

The storage account should be deployed momentarily. You will need the primary key for your storage account to proceed with the model tuning job in python scripts. To find the storage account's key:

1. Navigate to the resource group's overview pane.
1. Click on the resource of type "Storage account" once it has deployed. (You may need to refresh the list).
1. In the storage account overview pane that appears, click on the "Access keys" link on the left-hand list.
1. Press the "Click to copy" button next to "key1" to copy the primary key to your clipboard. Save this key in a memo file where you can easily access it as you continue through this guide.

You will also need to create a container inside the storage account to store glucose level readings for later:

1. Navigate to the storage account's overview pane and click "Blobs".
1. Click the "+ Container" button at the upper left in the "Blob service" pane that appears.
1. Create a container named `dataset` with "Private" access type.
1. Upload the source data files to the `dataset` container:
   1. Click on the container named `dataset` in the "Blob service" pane. Click "Upload".
   1. In your local machine, locate the seven files downloaded from [TalkingData dataset](https://www.kaggle.com/c/talkingdata-mobile-user-demographics/data) (app\_events.csv.zip, 
app\_labels.csv.zip, events.csv.zip, gender\_age\_test.csv.zip, gender\_age\_train.csv.zip, label\_categories.csv.zip, phone\_brand\_device\_model.csv.zip).
	1. Click "Upload."
	> **Note:** A Kaggle account is needed to download these files.
   




<a name="dsvm"></a>
### Create an Ubuntu Data Science Virtual Machine (DSVM)
	 **NOTE:** This Azure resource is only needed if you want to tune the models with the remote Docker container.

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "data science virtual machine" into the search box and then press Enter.
1. Click on the "Data Science Virtual Machine for Linux (Ubuntu)" option published by Microsoft from the search results. Click on the blue "Create" button that appears on the  right pane.
1. In the "Basics" pane that appears:
    1. Enter your **unique string** in the "Name" field.
    1. Enter **your user name** the "User name" field.
    1. Select Password as "Authentication" type.
    1. Enter **your password** the "Password" field and "Confirm password".
    1. Select the appropriate subscription, resource group, and location.
    1. Click "OK".
1. In the "Size" pane that appears:
	1. Choose "DS4_V2 Standard" machine or above to have at least 8 cores and 28 Gb of memory.
	1. Click "Select".

1. Leaving default setting in "Settings" pane and click "OK".
1. Click "Purchase" in "Purchase".


<a name="hdinsight"></a>
### Create a HDInsight Spark cluster
	**NOTE:** This Azure resource is only needed if you want to tune the models with the Spark cluster.
We recommend creating a HDInsight Spark cluster to train, evaluate, and apply the machine learning model on a predefined schedule to new data. To deploy the cluster:
 
1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "HDInsight" into the search box and then press Enter.
1. Click on the "HDInsight" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
1. In the "Basics" pane that appears:
    1. Enter your **unique string** in the "Cluster name" field.
    1. Choose the appropriate subscription.
    1. Click on Cluster type to load additional options:
       1. Choose "Spark" from the "Cluster type" drop-down menu.
       1. Choose "Spark 2.1.0 (HDI 3.6)" as the version number.
       1. Click "Select".
    1. Choose a cluster login name and password (ensure to note this down for future reference).
    1. Leave the secure shell (SSH) settings with their default values.
    1. Select the appropriate resource group and location.
    1. Press "Next".
1. In the "Storage" pane that appears:
    1. Ensure that the "Primary storage type" is set to "Azure Storage".
    1. Under the "Selection method", choose "My subscriptions".
    1. Under "Select a storage account", click the small arrow and enter your **unique string** as the storage account name under appropriate subscription. This is the storage account created in a previous step.
    1. Leaving all other fields at their default values, then click "Next".
1. In the "Summary" pane that appears:
    1. Click on the "Edit" link next to "Cluster size".
    1. Ensure that the number of worker nodes is set to "6". (Select the option 'View all' if you do not see this option by default).
    1. Set the "Worker node size" and "Head node size" to "D4 V2 Optimized". (Select the option 'View all' if you do not see this option by default).
    1. Click "Next".
1. Click "Next" at the bottom of the "Advanced settings" pane that appears.
1. Click "Create" at the bottom of the "Summary" pane that appears.

	> **Note:** The cluster deployment may take around twenty minutes to complete. As you wait for the cluster deployment, you can proceed with the modeling tuning expriments in remote Docker container compute environment first.



<a name="useamlworkbench"></a>
## Model Tuning with Azure Machine Learning (AML) Workbench
This section mainly outlines the step-by-step instructions on how to finish this exercise using AML Workbench. In order to further understand how the machine learning tasks are implemented and why the experiments are performed in such as way, please refer to section [Extended Reading](#details) for details.

We recommend to clone, or download/extract, a copy of [this git repository](https://github.com/Azure/MachineLearningSamples-DistributedHyperParameterTuning) in order to conveniently refer to the files in the [Code](https://github.com/Azure/MachineLearningSamples-DistributedHyperParameterTuning/Code) folder.

We define the 
"Code" folder in your copy of [this git repository](https://github.com/Azure/MachineLearningSamples-DistributedHyperParameterTuning) as "**origin code**" folder; and the name of your new created AML Workbench project folder as "**your project**" folder. Blew section shows how this new project is created.



<a name="createproj"></a>
### Create a New Project

Following steps show how to configure the settings in AML Workbench:


1. Launch AML Workbench and create a new project.
1. In the next steps, we connect execution environment to Azure account. 
	1. Open command line window (CLI) by clicking File menu in the top left corner of AML Workbench and choosing "Open Command Prompt." Then run following command in CLI:
		> az login
	
	1. Above command produces following response. Open a browser and navigate to https://aka.ms/devicelogin and enter the **YOUR_CODE**. You will sign into your Azure account.
		> To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code **YOUR_CODE** to authenticate.
	1. Switch back to the CLI console and run following command:
		> az account list -o table
	1. Locate the subscription ID of your Azure subscription that has your AML Workbench Workspace account. Then run folloiwng command in CLI to complete the connection to your Azure subscription.
		> az account set -s <subscription ID>

1. Copy the file 1\_Data\_Preparation\_AMLwb.ipynb from the origin code folder to your project folder. 
1. Locate the file 1\_Data\_Preparation\_AMLwb.ipynb in your project folder and open it. As shown below, replace the ACCOUNT_NAME and ACCOUNT_KEY variable with your provisioned storage account name and key. Save and close this file. Notice that you do not need to run load\_data.py file manually. Later on it will be called from other files.
		
		# Fill in your Azure storage account information here
   		ACCOUNT_NAME = "<ACCOUNT_NAME>"
   		ACCOUNT_KEY = "<ACCOUNT_KEY>"
    	

  

   		
    


<a name="train_docker"></a>
### Train Model in Remote Docker Container

1. To set up a remote Docker container, run following command in CLI with your DSVM's IP address, user name and password of . These information can be found in Overview section of your provisioned DSVM resource in Azure portal. After executing following command successfully, two files *myvm.compute* and *myvm.runconfig* will be generated in the aml_config folder of your project folder.

    > az ml computetarget attach --name myvm --address <IP address> --username <username> --password <password> --type remotedocker

1. Locate and open file myvm.runconfig in the aml_config folder of your project folder. 
1. Set property "PrepareEnvironment" to "true". The purpose is to enable create a Docker container in the remote VM. 

		PrepareEnvironment: true


1. Run following command in CLI console to launch the Jupyter notebook server. 

    > az ml notebook start

1. In the shown up browser window, click 1\_Data\_Preparation\_AMLwb.ipynb. Choose *Your\_Project\_Name myvm* as the kernel. 
1. The kernel start to show busy, indicating the process of creating Docker container  has started. It takes several minutes. You can check the progress in the CLI console.
1. run first cell to initialize variables
1. run second cell to create a container "preprocess" in the Storage and populate it with file *diabetic_data.csv*

<a name="train_sparkcluster"></a>
### Train Model in HDI Spark Cluster

1. Create a new project
1. Open CLI console and run following command. After executing following command successfully, two files *myspark.compute* and *myspark.runconfig* will be generated in the aml_config folder of your project folder.
    
    az ml computetarget attach --name myspark --address <cluster name\>-ssh.azurehdinsight.net  --username sshuser --password <password> --type cluster

1. Locate and open file myspark.runconfig in the aml_config folder of your project folder. 
1. Set property "PrepareEnvironment" to "true". The purpose is to enable create a Docker container in the remote VM. 

		PrepareEnvironment: true


1. Run following command in CLI console to launch the Jupyter notebook server. 

    > az ml notebook start