# Population Health Management - Manual Deployment Guide  

The goal of the solution guide presented here is to create a Population Health Management solution. It is geared towards hospitals and health care providers to manage and control the health care expenditure through disease prevention and management. This Manual Deployment Guide shows you how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite. It will walk you through how to manually set up and deploy all the individual services used in this solution. In the process you will learn about the underlying technology and function of each component, how to stitch them together to create an end to end solution.
 
**For technical problems or questions about deploying this solution, please post in the issues tab of the repository.**

Solution architecture 
=================================
![Solution Diagram Picture](https://cloud.githubusercontent.com/assets/16708375/25901999/3190e1f8-3590-11e7-93b5-408afd5d2e3e.png)

The architecture diagram above shows the solution design for Population Health Management Solution for Healthcare. The solution is composed of several Azure components that perform various tasks, viz. data ingest, data storage, data movement, advanced analytics and visualization.  [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) is the ingestion point of raw records that will be processed in this solution. These are then pushed to Data Lake Store for storage and further processing by [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/). A second Stream Analytics job sends selected data to [PowerBI](https://powerbi.microsoft.com/) for near real time visualizations. [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) orchestrates, on a schedule, the scoring of the raw events from the Azure Stream Analytics job
 by utilizing [Azure Data Lake Analytics](https://azure.microsoft.com/en-us/services/data-lake-analytics/) for processing with both [USQL](https://msdn.microsoft.com/en-us/library/azure/mt591959.aspx) and [R](https://docs.microsoft.com/en-us/azure/machine-learning/machine-learning-r-quickstart). Results of the scoring are then stored in [Azure Data Lake Store](https://azure.microsoft.com/en-us/services/data-lake-store/) and visualized using Power BI.

----------

To build the pipeline above for this solution, we will need to carry out the following steps:

- [Create an Azure Resource Group for the solution](#azurerg)
- [Create Azure Storage Account](#azuresa) 
- [Create an Azure Event Hub](#azureeh) 
- [Create an Azure Data Lake Store](#azuredls)
- [Download and configure the data generator](#gen)
- [Create an Azure Web Job](#webjob)
- [Create Azure Data Lake Analtytics](#azuredla)
- [Create Azure Stream Analytics Job](#azurestra) 
- [Create Azure Data Factory](#azuredf) 

Detailed instructions to carry out these steps can be found below under Deployment Steps. Before we start deploying, there are some prerequisites required and naming conventions to be followed.

### Prerequisites

This tutorial will require:

 - An Azure subscription, which will be used to deploy the project 
   (a [one-month free
   trial](https://azure.microsoft.com/en-us/pricing/free-trial/) is
   available for new users)
 - A Windows Desktop or a Windows based [Azure Virtual Machine](https://azure.microsoft.com/en-us/services/virtual-machines/) to run a data generation tool.
 - Download a copy of this repository to gain access to the necessary files that will be used in certain setup steps.     
 
### Naming Convention  

This deployment guide walks the readers through the creation of each of the Cortana Intelligence Suite services in the solution architecture shown above. 
As there are usually many interdependent components in a solution, [Azure Resource Manager](https://azure.microsoft.com/en-gb/features/resource-manager/) enables you to 
group all Azure services in one solution into a resource group. Each component in the resource group is called a resource. We want to use a common name for the different 
services we are creating. However, several services, such as Azure Storage, require a unique name for the storage account across a region and hence a naming convention 
is needed that should provide the user with a unique identifier. The idea is to create a unique string (that has not been chosen by another Azure user) that will be incorporated into the name of each Azure resource you create. This string can include only lowercase letters and numbers, and must be less than 20 characters in length. To address this, we suggest employing a base service name based on solution scope (**healthcare**) and 
user's specific details like name and/or a custom numeric ID:  

 **healthcare[UI][N]**  
  
where [UI] is the user's initials (in lowercase), N is a random integer(01-99) that you choose.  
  
To achieve this, all names used in this guide that contain string **healthcare** should be actually spelled as healthcare[UI][N]. A user, say, *Mary Jane* might use a base service name of healthcare**mj01**, and all services names below should follow the same naming pattern. For example, in the section "Create an Azure Event 
Hub" below: 

 - healthcareehns should actually be spelled healthcare**mj01**ehns 
 - healthcareeh should actually be spelled healthcare**mj01**eh  

### Accessing Files in the Git Repository

This tutorial will refer to files available in the Manual Deployment Guide section of the [Population Health Management  git repository](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide). You can download all of these files at once by clicking the "Clone or download" button on the repository.

You can download or view individual files by navigating through the repository folders. If you choose this option, be sure to download the "raw" version of each file by clicking the filename to view it, then cliking Download.

### Installing AzCopy Command-Line Utility

AzCopy is a Windows command-line utility designed for copying data to and from Microsoft Azure storage. Download AzCopy from [here](https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy). Open this desktop App you just installed by [searching](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/azcopy1.jpg?token=AKE1nQrJ204qRnprULTFa5APQBGY43g4ks5ZLbawwA%3D%3D) for ‘Microsoft Azure Storage command line’ or simple ‘azure storage command’. Open this app and you will get a [command prompt](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/azcopy2.PNG?token=AKE1nVnp0yWCsgwyopVrNOIS4-NmbLSSks5ZLbbJwA%3D%3D). We will use this utility to transfer files to and from blob.


----------

Deployment Steps:
====================


This section will walk you through the steps to manually create the population health management solution in your Azure subscription.

<a name="azurerg"></a>
## Create an Azure Resource Group for the solution
  The Azure Resource Group is used to logically group the resources needed for this architecture. To better understand the Azure Resource Manager click [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview). 

 - Log into the [Azure Management Portal](https://portal.azure.com) 
 - Click "Resource groups" button in the menu bar on the left, and then click __+Add__ at the top of the blade. 
 - Enter in a name for the resource group and choose your subscription.
 - For *Resource Group Location* you should choose one of the following:
    - South Central US
    - West Europe
    - Southeast Asia  

**NOTE** : It may be helpful for future steps to record the resource group name and location for later steps in this manual. 

<a name="azuresa"></a>
## Create Azure Storage Account 
  The Azure Storage Account is required for several parts of this solution
  - It is used as a the storage location for the raw event data used by the data generator that will feed the Azure Event Hub. 
  - It is used as a Linked Service in the Azure Data Factory and holds the USQL scripts required to submit Data Lake Analytics jobs to process data by Azure Data Factory.

  ### Creation Steps
  - Log into the [Azure Management Portal](https://portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group  you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter **Storage account**
  - Choose ***Storage account*** from the results, then click *Create*
  -	Change the deployment model to *Classic* and click create.
  -	Set the name to **healtcarestorage** 
  -	Subscription, resource group, and location should be correctly set. 
  -	Click ***Create***
  - The creation step may take several minutes. 

Navigate back to the storage account blade to collect important information that will be required in future steps. 
  - On the storage account blade, select [**Access keys**](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/storageaccountcredentials.PNG?token=AKE1nbeKGf8s4WfcRtjjYfw0yZyJy5ZBks5ZLbnvwA%3D%3D) from the menu on the left.
  - Record the *STORAGE ACCOUNT NAME*, *KEY* and *CONNECTION STRING* values for *key1*.
  - You will need these three credentials to upload files to your storage account below, when setting up a Linked Service to access the files in your blob through Azure Data Factory and when starting the data generator.
  - Next we will create some containers and move the necessary files into the newly created containers. These files are the raw events used by the data generator as well as usql scripts that will be called by the Azure Data Factory pipeline. 


  ### Move resources to the storage account
  - We will create three containers - 'data','scripts' and 'forphmdeploymentbyadf'
  - Navigate back to the Resource group and select the storage account just created.
  - Click on *Blobs* in the storage account blade.
  - Click __+ Container__  
  - Enter the name ***data*** and change the *Access type* to **blob**.
  - Click ***Create***
  - You should see *data* appear in the list of containers
  - On the [AzCopy terminal](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/azcopy2.PNG?token=AKE1nb9u5bYbePzq9r-wHL85y-qvMtN4ks5ZLbbqwA%3D%3D) command prompt type [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/rawevents/azCopy_command_data.txt?token=AKE1nS1SxXX5kks01buBZfRGFMwsXS3cks5ZOCAywA%3D%3D) command
  - Replace 'EnterYourStorageAccountkeyhere' with your storage account key and \<storageaccountname\> with your storage account name in the command before executing. 
  - Click refresh and you should see [these](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/rawevents/files_datagenerator) csv files appear in your container *data*
  - Click __+ Container__  to create the second container.
  - Enter the name ***scripts*** and change the *Access type* to **blob**.
  - Click ***Create***
  - You should see *scripts* appear in the list of containers
  - On the [AzCopy terminal](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/azcopy2.PNG?token=AKE1nb9u5bYbePzq9r-wHL85y-qvMtN4ks5ZLbbqwA%3D%3D) command prompt type [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/azCopy_command_scripts_toblob.txt?token=AKE1nYOIVk9_QjxSFVJqw9G-YXAosxpSks5ZLyPiwA%3D%3D) command 
  - Replace 'EnterYourStorageAccountkeyhere' with your storage account key and \<storageaccountname\> with your storage account name in the command before executing.
  - Click refresh and you should see the [these](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactory/scripts_blob) four usql files appear in your container *scripts*
  - Click __+ Container__  to create the third container.
  - Enter the name ***forphmdeploymentbyadf*** and change the *Access type* to **blob**.
  - Click ***Create***
  - You should see *forphmdeploymentbyadf* appear in the list of containers
  - On the [AzCopy terminal](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/azcopy2.PNG?token=AKE1nb9u5bYbePzq9r-wHL85y-qvMtN4ks5ZLbbqwA%3D%3D) command prompt type [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/azCopy_command_forphmdeploymentbyadf_toblob.txt?token=AKE1nXF52h4kF_kx02M7gzZxpLUJvlkQks5ZOCEewA%3D%3D) command 
  - Replace 'EnterYourStorageAccountkeyhere' with your storage account key and \<storageaccountname\> with your storage account name in the command before executing.
  - Click refresh and you should see seventeen files listed [here](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactory) appear in your container *forphmdeploymentbyadf*. 

  
  
<a name="azureeh"></a>
## Create an Azure Event Hub
  The Azure Event Hub is the ingestion point of raw records that will be processed in this solution. The role of Event Hub in solution architecture is as the "front door" for an event pipeline. It is often called an event ingestor.

 - Log into the [Azure Management Portal](https://portal.azure.com) 
 - In the left hand menu select *Resource groups*
 - Locate the resource group  you created for this project and click on it displaying the resources associated with the group in the resource group blade.
 - At the top of the Resource Group blade click __+Add__.
 - In the *Search Everything* search box enter **Event Hubs**
 - Choose ***Event Hubs*** from the results, then click *Create*, this will create the **namespace** for the Azure Event Hub.
 - For the name, use ***healthcareehns*** (e.g. Mary Jane would enter healthcaremj01ehns).
 - Subscription, resource group, and location should be correctly set.
 - Click ***Create*** 
 - The creation step may take several minutes.  
 - Navigate back to *Resource groups* and choose the resource group for this solution.
 - Click on ***healthcareehns***, then on the subsequent blade click __+Event Hub__
 - Enter ***healthcareehub*** as the Even Hub name (e.g. Mary Jane would enter healthcaremj01ehub), move partition count to 16 and click *Create*
 
 Once the Event Hub is created we will create Consumer Groups. In a stream processing architecture, each downstream application equates to a consumer group. We will create two Consumer Groups here corresponding to writing event data to two separate locations: Data Lake Store (cold path) and Power BI (hotpath). (There is always a default consumer group in an event hub)

 - Click on the Event Hub ***healthcareehub*** you just created, then on the subsequent blade click __+ Consumer Group__
 - Enter coldpathcg as Name
 - Add the second consumer group by clicking on __+ Consumer Group__ again.
 - Enter hotpathcg as Name 
 - You will need the names (coldpathcg and hotpathcg) when setting up stream analytics job.

 From the **healthcareehns** you will collect the following information as it will be required in future steps to set up Stream Analytics Jobs.

 - On the ***healthcareeehns*** blade choose [*Shared access policies*](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/eventhub1.PNG?token=AKE1nbxn0yvjW04vjuNLprBto3cyzmieks5ZLbz7wA%3D%3D) from the menu under Settings.
 - Select [**RootManageSharedAccessKey**](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/eventhub2.PNG?token=AKE1nXUjKUgJL3wh1vgoyn9wKU8jTntHks5ZLb0kwA%3D%3D) and record the value for **CONNECTION STRING -PRIMARY KEY** in the third row. You will need this when starting the generator.
 - Return to the ***healthcareehns*** blade and choose *Overview* from the menu, click on Event Hub under Entities and record the event hub name you just created.
 - Click on **healthcareehub** and choose *Overview* from the menu. 
 - Click on Consumer Groups under Entities and it will open a pane containing the list of Consumer Groups you just added. Copy the names coldpathcg and hotpathcg. You will need these when setting up the stream analytics job.
 

<a name="azuredls"></a>
##   Create an Azure Data Lake Store
  The Azure Data Lake store is used as to hold raw and scored results from the raw data points generated by the data generator and streamed in through Stream Analytics job.

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Lake Store***
  - Choose ***Data Lake Store*** from the results then click *Create*
  - Enter ***healthcareadls*** as the name (e.g. Mary Jane would enter healthcaremj01adls).
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click ***Create***  
  - The creation step may take several minutes. 
  - When completed, navigate back to the resource group blade and select the ***healthcareadls*** Data Lake Store and record the *ADL URI*
  value which from the Data Lake Store blade which will be in the [form](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adlsuri1.PNG?token=AKE1nZJeOG7q3pFgLOTS-Cp-7CHCOKZIks5ZLcgEwA%3D%3D) **adl://__********__.azuredatalakestore.net**  
  - You will need this to connect PBI to the data in your Data Lake Store. 

  ### Move resources to Data Lake Store
  - Navigate back to the Resource group and select the Data lake Store you just created. 
  - In the next blade, click on Data Explorer at the top.
  - In the Data Explorer blade, click on New Folder. You will be prompted to enter folder name. Enter **forphmdeploymentbyadf**. This folder will contain all the scripts, models and files needed for deployment that will be used by Data Factory.
  - We will move resources to this folder in Data Lake Store using AdlCopy
  - Download and install AdlCopy from [here](https://www.microsoft.com/en-us/download/details.aspx?id=50358).
  - Open Command Prompt by typing cmd in search field and navigate to the folder where AdlCopy was [installed](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adlcopy1.PNG?token=AKE1nUJIxLtXqqcp2Fzob6rilufbb147ks5ZMeVzwA%3D%3D). e.g. cd C:\Users\\\<username>\Documents\AdlCopy
  - Type adlcopy to ensure the command is [available](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adlcopy2.PNG?token=AKE1nQd9d3mgwhk9JQWul4J2eR6BltS3ks5ZMeWWwA%3D%3D).
  - On the prompt type [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/adlcopy_command_forphmdeploymentbyadf_blobtoadls.txt?token=AKE1nZaK1jc5pjB1w79TkefgUl0bU6Qjks5ZMeefwA%3D%3D) command
  - Replace 'EnterYourStorageAccountkeyhere' with your storage account key, \<storageaccountname\> with your storage account name and \<adlsccountname\> with your Data Lake Store name in the command before executing. 
  - If prompted 'Do you wish to continue' type 'Y'
  - In ~5 minutes (depending on the bandwidth) the files will be transferred to your folder forphmdeploymentbyadf in your Data Lake Store.
  - For the Azure Data Factory to run we need these files to be in the folder forphmdeploymentbyadf in Data Lake Store.
  

##   Start the Data Generator now 
  With the [data for generator](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/rawevents/files_datagenerator) uploaded to your storage account, the Event hub set up and Data Lake Store created, we can start the data generator at this point before carrying out the next steps. Once the generator is turned on, the Event Hub will start collecting the data. We will set up Stream Analytics job in the next steps that will process events from the Azure Event Hub and store in Data Lake Store and also push the incoming data to Power BI for visualization. If the generator is not running, you will not see streaming data coming in.

<a name="gen"></a>
## Download and configure the data generator  
 - Download the file ***healthcaregenerator.zip*** from the [datagenerator folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/datagenerator) of this repository.  
 - Unzip this file to the local disk drive of a Windows Machine. 
 - Unzip in C:/ to ensure a short path name to avoid the 255 character limit on folder names. 
 - Navigate to the *folder healthcaregenerator* where all the extracted files.
 - Open the file **HealthCareGenerator.exe.config** in a notepad and modify the [following](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/configfile.PNG?token=AKE1nQA4mCO26xSQUIW769KncrUpniCHks5ZOX7hwA%3D%3D) AppSettings  
 **NOTE:** If you do not see the .config file, in your explorer window, click on View and check 'File name extensions'.
    - EventHubName : Enter the name used to create the Azure Event Hub (not the Event Hub Namespace).  
    - EventHubConnectionString : Enter the value of *CONNECTION STRING -PRIMARY KEY* (not the PRIMARY KEY value) that was [collected](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/eventhub2.PNG?token=AKE1nTMdNyLOAmJjatV1hPHM4wQegojgks5ZLgLuwA%3D%3D) after creating the Azure Event Hub.
    - StorageAccountName: Enter the value of *STORAGE ACCOUNT NAME* that was [collected](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/storageaccountcredentials.PNG?token=AKE1nb5k9XP4_eSxJ9Qlluwc4ucw5imKks5ZLgMLwA%3D%3D) after creating the Azure Storage account.
    - StorageAccountKey: Enter the value of *PRIMARY ACCESS KEY* that was [collected](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/storageaccountcredentials.PNG?token=AKE1nb5k9XP4_eSxJ9Qlluwc4ucw5imKks5ZLgMLwA%3D%3D) after creating the Azure Storage account.  
	- Save and close **HealthCareGenerator.exe.config** 
 - Next we will **test that that data generator is working correctly** before setting up a Web Job.
 - Double click the file **HealthCareGenerator.exe** to start data generation. This should open a console and show messages as data are streamed from the local computer into the event hub **healthcareeh**.  
 - If you see messages on your console that look like   
EVENTHUB: Starting Raw Upload  
EVENTHUB: Upload 600 Records Complete  
EVENTHUB: Starting Raw Upload  
   then your data generator was configured correctly and we can shut it down.
 - **Shut down the generator** now by simply closing the console.
 - Zip the contents of the folder healthcaregenerator by selecting all the files in this folder -> right click and Send To Compressed (zipped) folder.
 - Look for the zipped file in the folder. You can rename it if you want. This zipped file will be uploaded to Azure portal for the Web Job.
 

<a name="webjob"></a>
## Create an Azure WebJob
We will use Azure [App Service](https://docs.microsoft.com/en-us/azure/app-service/app-service-value-prop-what-is) to create a Web App to run Data Generator Web Job which will simulate streaming data from hospitals. [Azure WebJobs](https://docs.microsoft.com/en-us/azure/app-service-web/websites-webjobs-resources) provide an easy way to run scripts or programs as background processes. We can upload and run an executable file such as cmd, bat, exe (.NET), ps1, sh, php, py, js, and jar. These programs run as WebJobs and can be configured to run on a schedule, on demand or continuously. Below we show how to use Azure portal to create a Web App with a new App Service Plan (S1 standard) and then create a Web Job. We will upload the zip file (created above after modifying the settings in .config file) and set the Web Job as continuous and single instance.
  
 - Log into the [Azure Portal](https://ms.portal.azure.com/). 
 - Press the "+ New" button at the upper left portion of the screen.
 - Type "Web App" into the search box and then press Enter.
 - Click on the "Web App" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
 -  In the "Web App" pane that appears:
    - Enter ***healthcarewebapp*** in the "App name" field (e.g. Mary Jane would enter healthcaremj01webapp).
    - Select the appropriate subscription and resource group.
    - Next we will select an App Service Plan
    - Click on App Service plan/Location to load more options.
    - Click "+ Create New".
    - Enter ***healthcarewebappplan*** in the "App Service plan" field.
    - Choose your desired location and pricing tier (select '+new' to select our recommended option "S1 Standard").
    - Click "OK" and then click "Create".
    - Wait for your Web App deployment to complete (will take a few seconds).

 - Navigate back to the Resource group and select the App Service just created.
 - In the App Service blade on the left scroll down and under Settings locate WebJobs
 - Click on WebJobs.
 - In the WebJobs blade click ***+ Add*** 
    - In the Add WebJob pane 
    - Enter ***healthcarewebjob*** in the "Name" field (e.g. Mary Jane would enter healthcaremj01webjob).
    - Upload the zipped file created above.
    - Select ***Continuous*** from drop down for "Type" field.
    - Select ***Single Instance*** from drop down for "Scale" field.
    - Click "OK".
 - The WebJob will appear in the WebJobs list in a few seconds. Once the STATUS field says Running, data should start pumping in your Event Hub.
 - To monitor your WebJob select the WebJob and click on Logs at the top. You should [see](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/webjob2.PNG?token=AKE1nY950d_-IioHtLuVmEMOvRKVFkKoks5ZOX6kwA%3D%3D) similar messages as you saw in console when you tested the generator locally:   
EVENTHUB: Upload 600 Records Complete 
EVENTHUB: Starting Raw Upload  
EVENTHUB: Upload 600 Records Complete  

- Once the data generator is running you should [see](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/datageneratorstarted.PNG?token=AKE1nW-W3OLSRFim3KeWQPxwYG3akBKBks5ZLxExwA%3D%3D) incoming data in your Event Hub within a few minutes.
 
    ***NOTE:*** The PowerBI Dashboards (see HotPath) will only be dynamically updated when the WebJob is running.  
    

<a name="azurestra"></a>
## Create Azure Stream Analytics Job - Cold and Hot Paths
  [Azure Stream Analytics](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-introduction) facilitates setting up real-time analytic computations on streaming data. Azure Stream Analytics job can be authored by specifying the input source of the streaming data, the output sink for the results of your job, and a data transformation expressed in a SQL-like language. In this solution, for the incoming streaming data, we will have two different output sinks - Data Lake Store (the *Cold Path*) and Power BI (the *Hot Path*). Below we will outline the steps to set up the cold path stream and the hot path stream. 

## Cold Path Stream
  For the cold path stream, the Azure Stream Analytics job will process events from the Azure Event Hub and store them into the Azure Data Lake Store. We will name the Steam Analytics Job that we create for this, **healthcareColdPath**. 

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Stream Analytics job***
  - Choose ***Stream Analytics job*** from the results then click *Create*
  - Enter ***healthcareColdPath*** as the Job name (e.g. Mary Jane would enter healthcaremj01ColdPath).
  - Subscription, resource group, and location should be correctly set.
  - Click *Create*  
  - The creation step may take several minutes.  
  - Return to the resource group blade.
  - Next we will add Inputs, Outputs and Query for the Stream Analytics job
  - Select the ***healthcareColdPath*** resource to open the Stream Analytics job to modify the job settings.  
  - In the Stream Analytics job blade click *Inputs* 
    - At the top of the *Inputs* page click ***+ Add***
        - Input alias : InputHub
        - Source Type : Data Stream
        - Source : Event hub
        - Import Option: Use event hub from current subscription
        - Service bus namespace: ***healthcareeehns*** (or whatever you have chosen for the Event Hub namespace previously)
        - Event hub name: ***healthcareehub*** (or whatever you have chosen for the event hub previously)
        - Event hub policy name: leave unchanged at *RootManageSharedAccessKey*
        - Event hub consumer group: leave empty
        - Event serialization format : CSV (**not** json)
        - Delimiter: remains comma(,)
        - Encoding: remains UTF-8
        - Click the bottom **Create** button to complete.  
          
 - Navigate back to the Stream Analytics job blade and click *Outputs*
   - **NOTE** for each of the four outputs you will create the only step that differs between them is the *Output alias* and *Path prefix pattern*. Use these steps for each output and look into the following sections for the values to put in for each output.  
   - At the top of the *Outputs* page click ***+ Add***   
	    - Output alias : **Find Value Below**  
        - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
        - Import option: Select Data Lake Store form your subscription
        - Subscription: Should be set correctly
        - Account Name: Choose the Azure Data Lake Store created previously. 
        - Path prefix pattern: **Find value below**
        - Date format: *YYYY/MM/DD*
        - Time format: *HH*
        - Event serialization format: CSV (**not** json)
        - Delimiter: remains comma (,)
        - Encoding: remains comma UTF-8
        - Click the **Create** button to complete  
   - Output 1
     - *Output alias* : SeverityOutput
     - *Path prefix pattern* : stream/raw/severity/{date}/{time}_severity
   - Output 2
     - *Output alias* : ChargesOutput
     - *Path prefix pattern* : stream/raw/charges/{date}/{time}_charges
   - Output 3
     - *Output alias* : CoreOutput
     - *Path prefix pattern* : stream/raw/core/{date}/{time}_core
   - Output 4
     - *Output alias* : DxprOutput
     - *Path prefix pattern* : stream/raw/dxpr/{date}/{time}_dxpr
  
  
- Navigate back to the Stream Analytics job blade and click *Query*  
    - Download the file StreamAnalyticsJobQueryColdPath.txt from the [scripts/streamanalytics folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window.  
    - Click *SAVE*  
- When all inputs, functions, outputs and the query have been entered, click *Start* at the top of the Overview page for the Stream Analytics job and for *Job output start time*
select **now,** then click on **Start**.   

Raw data will start to appear in the Azure Data Lake Store (in stream/raw/severity/, stream/raw/core/, stream/raw/charges/ and stream/raw/dxpr/ with the directory structure defined by *Path prefix pattern* above) after approximately 5 minutes.

## Hot Path Stream
  For the hot path, the Azure Stream Analytics job will process events from the Azure Event Hub and push them to Power BI for real time visualisation. We will name the Steam Analytics Job that we create for this, **healthcareHotPath**. 

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Stream Analytics job***
  - Choose ***Stream Analytics job*** from the results then click *Create*
  - Enter ***healthcareHotPath*** as the Job name (e.g. Mary Jane would enter healthcaremj01HotPath).
  - Subscription, resource group, and location should be correctly set.
  - Click *Create*  
  - The creation step may take several minutes.  
  - Return to the resource group blade.
  - Select the ***healthcareHotPath*** resource to open the Stream Analytics job to modify the job settings (specify Inputs, Outputs and Query).  
  
- In the Stream Analytics job blade click ***Inputs*** 
    - At the top of the *Inputs* page click ***+ Add***
    - Input alias : **HotPathInput**
    - Source Type : Data Stream
    - Source : Event hub
    - Import Option: Use event hub from current subscription
    - Service bus namespace: ***healthcareehns*** (or whatever you have chosen for the Event Hub namespace previously)
    - Event hub name: ***healthcareehub*** (or whatever you have chosen for the event hub previously)
    - Event hub policy name: leave unchanged at *RootManageSharedAccessKey*
    - Event hub consumer group: **hotpathcg** (we created this above)
    - Event serialization format : CSV (not json)
    - Delimiter: remains comma(,)
    - Encoding: remains UTF-8
    - Click the bottom **Create** button to complete.  
           
 - Navigate back to the Stream Analytics job blade and click ***Outputs***
    - **NOTE** We will add one output below. To add more you would simply repeat the steps below with different names for your Output alias and Dataset name.
    - At the top of the *Outputs* page click ***+ Add*** to add the first output
	- Output alias : PBIoutputcore   
    - Sink: PowerBI, then Click **Authorize** to Authorize Connection 
    - Group Workspace: My Workspace
    - Dataset Name: **hotpathcore** 
    - Table Name: same as Dataset Name above
    - Click the **Create** button to complete  
   
 - Navigate back to the Stream Analytics job blade and click ***Query***  
    - Download the file StreamAnalyticsJobQueryHotPath.txt from the [scripts/streamanalytics folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window. 
    - Click *SAVE*    
    
- When all inputs, outputs and the query have been entered, click *Start* at the top of the Overview page for the Stream Analytics job and for *Job output start time*
select *Now*, then click on **Start**.   
- After some time in the Datasets section of your PowerBI, this new dataset *hotpathcore* will appear.
 
<a name="azuredla"></a>
##   Create Azure Data Lake Analtytics 
  Azure Data Lake Analytics is an on-demand analytics job service to simplify big data analytics. It is used here to process the raw records and perform other jobs such as feature engineering, scoring etc. You must have a Data Lake Analytics account before you can run any jobs. A job in ADLA is submitted using a [usql](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-usql-activity) script. The usql script for various jobs (joining, scoring etc. ) can be found at [scripts/datafactory/scripts_storage/](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactory/scripts_storage) folder of this repository and will need to be uploaded to storage from where Azure Data Factory will access them to automatically submit the various jobs. The usql scripts  will deploy various resources (viz. R scipts, trained models, csv files with historic and metadata etc), these can be found in your data lake store in the folders adfrscripts, historicdata and models. We created these folders in the steps above when we created the Data Lake Store and uploaded the contents to these folders. One additional important step is to Install U-SQL Extensions in your account. R Extensions for U-SQL enable developers to perform massively parallel execution of R code for end to end data science scenarios covering: merging various data files, feature engineering, partitioned data model building, and post deployment, massively parallel FE and scoring.

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Lake Analytics***
  - Choose ***Data Lake Analytics*** from the results then click *Create*
  - Enter ***healtcahreadla*** as the name (e.g. Mary Jane would enter healthcaremj01adla).
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click on *Data Lake Store* and choose the Azure Data Lake store created in the previous step. (Data Lake Analytics account has an Azure Data Lake Store account dependency and is referred as the default Data Lake Store account.)
  - Click ***Create***  
  - The creation step may take several minutes.
  - When completed, navigate back to the resource group blade and select the ***healthcareadla*** Data Lake Account.
  - In the Overview Panel on the left, scroll down to the GETTING STARTED section, locate and click on 'Sample Scripts'.
  - In the Sample Scripts [blade](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adla_install.PNG?token=AKE1nX-aGvhIuARaBrFRaCHlaMhlwn7cks5ZLcd2wA%3D%3D), click on Install U-SQL Extensions to install U-SQL Extensions to your account.
  - This step will enable R (and python) extensions to work with ADLA.

<a name="azuredf"></a>
## Create Azure Data Factory
  Azure Data Factory is a cloud-based data integration service that automates the movement and transformation of data and other steps necessary to convert raw stream data to useful insights. Using Azure Data Factory, you can create and schedule data-driven workflows (called pipelines). A pipeline is a logical grouping of activities that together perform a task. The activities in a pipeline define actions to perform on your data. In this data factory we have only one pipeline with four different activities. The compute service we will be using for data transformation in this Data Factory is Data Lake Analytics.
  
  
### Azure Data Factory - get started

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Factory***
  - Choose ***Data Factory*** from the results then click *Create*
  - Enter ***healthcareadf*** as the name (e.g. Mary Jane would enter healthcaremj01adf). 
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click ***Create***  
  - The creation step may take several minutes.  


### Azure Data Factory Linked Services
  In order for data factory to link to the data locations, we will need to create a '[Linked Service](https://docs.microsoft.com/en-us/rest/api/datafactory/data-factory-linked-service)' which are much like connection strings, which define the connection information needed for Data Factory to connect to external resources. We will create Linked Service for Azure Storage account which contains the USQL scripts, the Azure Data Lake Store where the data resides, and finally the Azure Data Lake Analytics instance. We will set up these Linked Services first before we define the Datasets.

  Azure Storage Linked Service

  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade choose *New data store* and choose **Azure Storage** from the list
  - You will be presented a draft
  - At the setting *connectionString* copy the *PRIMARY CONNECTION STRING* value retrieved from the Azure Storage account earlier.
  - At the top of the blade, click *Deploy*

  Azure Data Lake Store Linked Service

  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade choose *New data store* and choose **Azure Data Lake Store** from the list
  - You will be presented a draft
  - At the setting *dataLakeStoreUri* copy the *ADL URI* value saved during the creation of the Azure Data Lake Store. 
  - Remove the properties marked as [Optional]. These would be *accountName*, *resourceGroupName*, and *subscriptionId*.
  - At the top of the page, click **Authorize** . 
  - You will notice some fields will get auto filled after authorization. 
  - At the top of the blade, click *Deploy*

  Azure Data Lake Analytics Linked Service Compute Service

  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade instead of *New data store* click on **...More** and from the drop down select **New compute** and choose *Azure Data Lake Analytics* from the list
  - You will be presented a draft.
  - At the setting *accountName* enter the Azure Data Lake Analytics resource name you provided earlier. 
  - You **must** remove the properties marked as [Optional]. These would be *resourceGroupName*, and *subscriptionId*. 
  - At the top of the page, click **Authorize**.
  - You will notice some fields will get auto filled after authorization. 
  - At the top of the blade, click *Deploy*

### Azure Data Factory Datasets
  Now that we have the Linked Services out of the way, we need to set up [Datasets](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-create-datasets) which will act as inputs and outputs for each of the activity in the Data Factory pipeline. In Azure Data Factory these are defined in JSON format. The input dataset for the first activity in the pipeline will have external flag set to true as it is not explicitly produced by a data factory pipeline (this is the streaming data that is being collected in Data Lake Store through Stream Analytics job). This flag is set to false otherwise. The processing window is defined by availability and is set to 15 minutes which means a data slice will be produced every 15 minutes.
 
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade instead of *New data store* click on *... More* and from the drop down choose **New dataset** and then *Azure Data Lake Store* from the list.
  - The template contains quite a few settings, which we will not cover. Instead download the file [*inputdataset.json*](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactoryobjects/inputdataset.json?token=AKE1nXBpPSdfNf84d6sI2_NVhFkYK9cXks5ZMenuwA%3D%3D) from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file. 
  - At the top of the blade, click *Deploy*
  - You should see 01StreamedData appear under Datasets.

  The input datasets for the other three activities is produced by the current pipeline and will have external flag set to false. Let us set these up. 
 
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade click on *...More* and choose **New dataset** and then *Azure Data Lake Store* from the list.
  - You will be presented a template.
  - The template contains quite a few settings, which we will not cover. Instead download the file [*outputdataset.json*](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactoryobjects/outputdataset.json?token=AKE1nc5mgAdsHAXnKX5c9n4NZTHCWL8Lks5ZMeqOwA%3D%3D) from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file.
  - Change the *name* field to *02JoinedData*
  - At the top of the blade, click *Deploy*
  - You should see *02JoinedData* appear under Datasets
  - Create three more datasets by cloning 02JoinedData and replacing the name with the names below.
  - Click on the newly created set *02JoinedData* 
  - Click the *Clone* button at the top of the blade
  - Enter in one of the names below and hit the *Deploy* button at the top of the blade:
  - Repeat for      
      - 03ScoredData      
      - 04ProcessedForPBIData      
      - 05AppendedToHistoricData      
   - When finished you will have a total of five datasets.
  
### Azure Data Factory Pipeline
  With the services and datasets in place it is time to set up a pipeline that will process the data. 

  ***Note***: The shortest execution time of data factory is 15 minutes.

 - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - Right click on *Pipelines* and choose *New pipeline*
  - The template contains an empty pipeline. Download the file [*pipeline.json*](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactoryobjects/pipeline.json?token=AKE1nYHRlMg2NTSOs1bUixLHDS2yiPhiks5ZMeqywA%3D%3D) from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file. 
  - **DO NOT** click  *Deploy* yet

  Lets look closely at these activities and what they are doing. 

  #### Joining

  This activity executes a [USQL script](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamjoin.usql?token=AKE1nbzw6MDZdCO0qoEbsYSR1de5-8Tjks5ZL9E0wA%3D%3D) located in the Azure Storage account and accepts three parameters - *queryTime*, *queryLength* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to join the 4 data streams (severity, charges, core, and dxpr) according to an id field and a time. The result 
  is a single output file with the results for the 15 minute window this activity should cover. 

  The output of this activity is then tied to the input of the *Scoring* activity, which will not execute until this activity is complete. 
  
  #### Scoring

  This activity executes a [USQL script](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamscore.usql?token=AKE1nfKVqHwIbXUVsTRW6P89DE_QB-Fuks5ZL9FdwA%3D%3D) located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to perform feature engineering, score the data, and output the results of that work to
  a single output file with the scoring results for the 15 minute window this activity should cover.

  The output of this activity is then tied to the input of the *Process for PBI* activity, which will not execute until this activity is complete.  

  #### Processing for PBI

  This activity executes a [USQL script](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamforpbi.usql?token=AKE1nQUfc7i_H4bsc357cDbrlwXNGm1Xks5ZL9F3wA%3D%3D) located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to create data for visualization, and output the results of that work to
  a single output file for the 15 minute window this activity should cover.

  #### Appending

  This activity executes a [USQL script](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamappend.usql?token=AKE1nTvBM3CuJdJEy5De65f8fwLfk3ceks5ZL9GPwA%3D%3D) located in the Azure Storage account and does not accept any input parameters. This activity in effect appends the data created for visualization above to the historic visualization data, and output the latest records to a single output file. 

  #### Activity Period

  Every pipeline has an activity period associated with it. This is the period in time in which the pipeline should be actively processing data. Those time stamps are in the 
  properties *start* and *end* located at the bottom of the pipeline editor. These times are in UTC. In the json for pipeline provided [here](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/scripts/datafactoryobjects/pipeline.json?token=AKE1nYHRlMg2NTSOs1bUixLHDS2yiPhiks5ZMeqywA%3D%3D) the start and end are listed as such -     
  "start": "2017-05-20T10:00:00Z",      
  "end": "2017-05-30T18:51:55Z",        
  Set the *start* property to the time right now, and set the *end* property to 1 week from now. This will ensure that your data factory will not be producing data over too long a period of time and we do that only because the [data generator](#gen) (which you set up earlier and should be running) will not run infinitely. 

  Once you have updated the *start* and *end* properties ***you should now click the *Deploy* button at the top of the blade***.

 **Azure Data Factory is deployed now**. Joined results will start to appear in the Azure Data Lake store in stream/joined followed by scored results in stream/scoring etc. For more on how to monitor the pipeline read [here](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-monitor-manage-pipelines). 

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. After completion of hot path stream steps above, the data is being pushed to Power BI for real time visualization. Additionally we also connect to the streaming data and predictions being stored in the Data Lake Store (cold path) along with historic data from Power BI for visualization. A picture is worth a thousand words. Lets head over to the [visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data. 
 
  



