# Population Health Management - Manual Deployment Guide  

Introduction **TBD NEEDS UPDATING**:
===============

The goal of the solution guide presented here is to .....

This tutorial will guide you through the process creating, from the ground up, a Predictive Analytics solution. Other related resources provided here:
 -  a [solution description](https://github.com/Azure/cortana-intelligence-quality-assurance-manufacturing/blob/master/Manual%20Deployment%20Guide/SolutionDescription.md) that includes more details on the machine learning approach and related resources.
 -  [data flow](https://github.com/Azure/cortana-intelligence-quality-assurance-manufacturing/blob/master/Manual%20Deployment%20Guide/DataFlowReport.md) report demonstrating how post deployment monitoring can be used to visualize the timing and work-load of each key components of the solution.
 
**For technical problems or questions about deploying this solution, please post in the issues tab of the repository.**

Solution architecture description **TBD NEEDS UPDATING/IMAGES**:
=================================
![Solution Diagram Picture](https://cloud.githubusercontent.com/assets/16708375/24055289/5e69ddca-0b37-11e7-953e-b2e0d7758cb4.png)

<sub>Solution design for Predictive Analytics for Population Helath Management in Manufacturing</sub>


  
Solution [Lambda](http://social.technet.microsoft.com/wiki/contents/articles/33626.lambda-architecture-implementation-using-microsoft-azure.aspx) architecture uses the hot (upper) path for real time processing and cold (lower) path for distributed processing that can handle complex queries on very large quantities of historical data.  
   
Speed Layer:  
 - Event from 4 different connected datasets are ingested using an [Azure Event Hub](https://azure.microsoft.com/en-us/documentation/articles/event-hubs-overview/) 
 which receives the event records sent using an [Azure WebJob](https://azure.microsoft.com/en-us/documentation/articles/web-sites-create-web-jobs/).  
 - Event processing is performed using an [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/) job which separate events based on the dataset
 the event orginated from and stores the records in [Azure Data Lake Store](https://azure.microsoft.com/en-us/services/data-lake-store/).
 - A second [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/) job performs some aggregations on the data which are then sent to 
 [PowerBI](https://powerbi.microsoft.com/) data sets for near real time visualizations.

  
Batch Layer:  
 -  [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) orchestrates, on a schedule, the scoring of the raw events from the [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/) job
 by utilizing [Azure Data Lake Analytics](https://azure.microsoft.com/en-us/services/data-lake-analytics/) for processing with both [USQL](https://msdn.microsoft.com/en-us/library/azure/mt591959.aspx) and [R](https://docs.microsoft.com/en-us/azure/machine-learning/machine-learning-r-quickstart)
 - Results of the scoring are then stored in [Azure Data Lake Store](https://azure.microsoft.com/en-us/services/data-lake-store/) files and visualized using [PowerBI](https://powerbi.microsoft.com/).  
 

Deployment Steps:
====================

### Prerequisites

This tutorial will require:

 - An Azure subscription, which will be used to deploy the project 
   (a [one-month free
   trial](https://azure.microsoft.com/en-us/pricing/free-trial/) is
   available for new users)
 - A Windows Desktop or a Windows based [Azure Virtual Machine](https://azure.microsoft.com/en-us/services/virtual-machines/) to run a data generation tool.
 - Download a copy of this repository to gain access to the neccesary files that will be used in certain setup steps.     
 
### Naming Convention  

This deployment guide walks the readers through the creation of each of the Cortana Intelligence Suite services in the solution architecture defined in Section 2. 
As there are usually many interdependent components in a solution, [Azure Resource Manager](https://azure.microsoft.com/en-gb/features/resource-manager/) enables you to 
group all Azure services in one solution into a resource group. Each component in the resource group is called a resource. We want to use a common name for the different 
services we are creating. However, several services, such as Azure Storage, require a unique name for the storage account across a region and hence a naming convention 
is needed that should provide the user with a unique identifier. To address this, we suggest employing a base service name based on solution scope (manufacturing) and 
user's specific details like name and/or a custom numeric ID:  

 **healthcare[UI][N]**  
  
where [UI] is the user's initials, N is a random integer that you choose. Note that all characters must be entered in in lowercase.  
  
To achieve this, all names used in this guide that contain string **healthcare** should be actually spelled as healthcare[UI][N]. So for example, user Steven **X. Smith** 
might use a base service name of manufact**xs01**, and all services names below should follow the same naming pattern. For example, in the section "Create an Azure Event 
Hub" below: 
 - healthcare***ureehns*** should actually be spelled healthcare***xs01ehns*** 
 - healthcare***ureeh*** should actually be spelled healthcare***xs01eh***  
  

# Manual Steps
This section will walk you through the steps to manually create the population health management solution in your Azure subscription.

## Create an Azure Resource Group for the solution
  The Azure Resource Group is used to logically group the resources needed for this architecture. To better understand the Azure Resource Manager click [read more here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview). 

 - Log into the [Azure Management Portal](https://portal.azure.com) 
 - Click "Resource groups" button in the menu bar on the left, and then click __+Add__ at the top of the blade. 
 - Enter in a name for the resource group and choose your subscription.
 - For *Resource Group Location* you should choose one of the following:
    - South Central US
    - West Europe
    - Southeast Asia  

**NOTE** : It may be helpful for future steps to record the resource group name and location for later steps in this manual. 

## Create Azure Storage Account 
  The Azure Storage Account is required for several parts of this pattern
  - It is used as a the storage location for the raw event data used by the data generator that will feed the Azure Event Hub. 
  - It is used as a Linked Service in the Azure Data Factory and holds the USQL and R scripts required to process the raw stream data.

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

  ### Move resources to the storage account
  - Navigate back to the Resource group and select the storage account just created.
  - Click on *Blobs* in the storage account blade.
  - Click __+ Container__  
  - Enter the name *data* and changes the *Access type* to blob.
  - Click ***Create***
  - Click __+ Container__  
  - Enter the name *scripts* and changes the *Access type* to blob.
  - Click ***Create***

  Now you will move the neccesary files into the newly created containers. These files are the raw events used by the data generator as well as scripts that 
  will be called by the Azure Data Factory pipeline.  
  - Select the *data* container
  - Click ***Upload*** at the top of the container blade and copy the contents 
  - Download the files in the [rawevents folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/rawevents) locally, then choose 
  the local files and select **Upload**.
  - Select the *scripts* container
  - Click ***Upload*** at the top of the container blade and copy the contents 
  - Dowload the files in the [scripts/datafactory folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/datafactory) locally then choose
  the local files and select **Upload**.

  Navigate back to the storage account blade to collect important information that will be required in future steps. 
  - On the storage account blade, select **Access keys** from the menu on the left.
  - Record the *STORAGE ACCOUNT NAME*, *PRIMARY ACCESS KEY*, and *PRIMARY CONNECTION STRING* values.

## Create an Azure Event Hub
  The Azure Event Hub is the ingestion point of raw records that will be processed in this example pattern.

 - Log into the [Azure Management Portal](https://portal.azure.com) 
 - In the left hand menu select *Resource groups*
 - Locate the resource group  you created for this project and click on it displaying the resources associated with the group in the resource group blade.
 - At the top of the Resource Group blade click __+Add__.
 - In the *Search Everything* search box enter **Event Hubs**
 - Choose ***Event Hubs*** from the results, then click *Create*, this will create the namespace for the Azure Event Hub.
 - For the name, use ***healthcareeehns***
 - Subscription, resource group, and location should be correctly set.
 - Click ***Create*** 
 - The creation step may take several minutes.  
 - Navigate back to *Resource groups* and choose the resource group for this solution.
 - Click on ***healthcareeehns***, then on the subsequent blade click __+Event Hub__
 - Enter ***healthcareeh*** as the name, move partition count to 16 and click *Create*

 From the **healthcareehns** you will collect the following information as it will be required in future steps.
 - On the ***healthcareeehns*** blade choose *Shared access policies* from the menu
 - Select **RootManageSharedAccessKey** and record the value for *CONNECTION STRING -PRIMARY KEY*
 - Return to the ***healthcareeehns*** blade and choose *Overview* from the menu and record the event hub name you created above.
 
##   Create an Azure Data Lake Store
  The Azure Data Lake store is used as to hold raw and scored results from the raw data points generated by the data generator.
  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Lake Store***
  - Choose ***Data Lake Store*** from the results then click *Create*
  - Enter ***healthcareadls*** as the name.
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click ***Create***  
  - The creation step may take several minutes. 
  - When completed, navigate back to the resource group blade and select the ***healthcareadls*** Data Lake Store and record the *ADL URI*
  value which from the Data Lake Store blade which will be in the form adl://****.azuredatalakestore.net 

##   Create Azure Data Lake Analtytics 
  The Azure Data Lake Analytics is used as to process the raw records and perform the machine learning steps of feature engineering and scoring. 
  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Lake Analytics***
  - Choose ***Data Lake Analytics*** from the results then click *Create*
  - Enter ***healtcahreadla*** as the name.
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click on *Data Lake Store* and choose the Azure Data Lake store created in the previous step. 
  - Click ***Create***  
  - The creation step may take several minutes.  

## Create Azure Stream Analytics Job
  The Azure Stream Analytics job is used to process events from the Azure Event Hub and store them into the Azure Data Lake Store. For this pattern we will utilized 4
  outputs, one for each record type, which will all produce output in the Azure Data Lake Store. 
  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Stream Analytics job***
  - Choose ***Stream Analytics job*** from the results then click *Create*
  - Enter ***healthcareasa*** as the name.
  - Subscription, resource group, and location should be correctly set.
  - Click *Create*  
  - The creation step may take several minutes.  
  - Return to the resource group blade.
  - Select the ***healthcareasa*** resource to open the Stream Analytics job to modify the job settings.  
  - Click *Inputs* on the Stream Analytics job blade  
    - At the top of the *Inputs* page click ***+ Add***
      - Input alias : InputHub
        - Source Type : Data Stream
        - Source : Event hub
        - Import Option: Use event hub from current subscription
        - Service bus namespace: ***healthcareeehns*** (or whatever you have chosen for the __Event Hub**s**__ namespace previously)
        - Event hub name: ***healthcareeh*** (or whatever you have chosen for the event hub previously)
        - Event hub policy name: leave unchanged at *RootManageSharedAccessKey*
        - Event hub consumer group: leave empty
        - Event serialization format : CSV
        - Delimiter: remains comma(,)
        - Encoding: remains UTF-8
        - Click the bottom **Create** button to complete.  
          
 - Navigate back to the Stream Analytics job blade and click *Outputs*
   - **NOTE** for each of the four outputs you will create the only step that differs between them is the *Output alias* and *Path prefix pattern*. Use these steps for
   each output and look into the following sections for the values to put in for each output.  
   - At the top of the *Outputs* page click ***+ Add***
	   - Output alias : **Find Value Below**  
         - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
         - Subscription: Should be set correctly
         - Account Name: Choose the Azure Data Lake Store created previously. 
         - Path prefix pattern: **Find value below**
         - Date format: *YYYY/MM/DD*
         - Time format: *HH*
         - Event serialization format: CSV
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
    - Download the file StreamAnalyticsJobQuery.txt from the [scripts/streamanalytics folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window.  
    - Click *SAVE*  
- When all inputs, functions, outputs and the query have been entered, click *Start* at the top of the Overview page for the Stream Analytics job and for *Job output start time*
select now, then click on **Start**.   


## Create Azure Data Factory
  The Azure Data Factory orchestrates data movement an other processing steps the steps neccesary to process raw stream data to useful insights. This demo accelerates actual processing
  time for the sake of useful visualizations in a short amount of time. To accomplish that this demo will utilized overlapping Azure Data Lake activities in the pipeline to produce
  results approximately every 5 minutes. 

  To produce results every 5 minutes requires that this demo create additional resources that may not be neccesary in an actual enterprise deployment. This is because Azure Data Factory
  works by allowing pipelines to flow using dependencies. To understand the concept better, read [this](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-scheduling-and-execution) article.

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Factory***
  - Choose ***Data Factory*** from the results then click *Create*
  - Enter ***healthcareadf*** as the name. 
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click ***Create***  
  - The creation step may take several minutes.  

### Azure Data Factory Linked Services
  This Azure Data Factory is going to require certain servies to work on the raw data and produce insights. These services are a link to the Azure Storage account which
  contains the USQL scripts for Azure Data Lake Analytics, the Azure Data Lake store where the data resides, and finally the Azure Data Lake analytics instance. 
  We will set those up first.

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
  - At the top of the page, click **Authorize** and when complete you can remove the properties marked as [Optional]. These will be *accountName*, *resourceGroupName*, 
  and *subscriptionId*.  
  - At the top of the blade, click *Deploy*

  Azure Data Lake Analytics Compute Service
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade choose *... More* and choose **New compute** and then *Azure Data Lake Analytics* from the list
  - At the setting *accountName* enter the Azure Data Lake Analytics resource name you provided earlier. 
  - You will be presented a draft
  - At the top of the page, click **Authorize** and when complete you can remove the properties marked as [Optional]. These will be *resourceGroupName*, 
  and *subscriptionId*.  
  - At the top of the blade, click *Deploy*

### Azure Data Factory Datasets
  Now that we have the services out of the way, we need to set up Datasets which will act as inputs and outputs to the Data Factory pipeline. For this, we use a single 
  input to start off the processing.

  Setting up the starting file. This file does not exist, but will be tagged as an *external* file so that Data Factory does not check for it's existence. 
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade choose *... More* and choose **New dataset** and then *Azure Data Lake Store* from the list.
  - The template contains quite a few settings, which we will not cover. Instead download the file *inputdataset.json* from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file. 
  - At the top of the blade, click *Deploy*

  Setting up the working files is next. These files also don't exist, but with data factory being a dependency flow, they are also required to help orchestrate the 
  steps of processing in the pipeline.  
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade choose *... More* and choose **New dataset** and then *Azure Data Lake Store* from the list.
  - The template contains quite a few settings, which we will not cover. Instead download the file *outputdataset.json* from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file.
  - Change the *name* field to *JoinSliceOutputSet1*
  - At the top of the blade, click *Deploy*
  - Click on the newly created set *JoinSliceOutputSet1*
    - Click the *Clone* button at the top of the blade. 
    - Enter in one of the names below and hit the *Deploy* button at the top of the blade:
      - JoinSliceOutputSet2
      - JoinSliceOutputSet3
      - ScoreSliceOutputSet1
      - ScoreSliceOutputSet2
      - ScoreSliceOutputSet3
   - When finished you will have a total of 7 datasets.
  
### Azure Data Factory Pipeline
  With the services and datasets in place it is time to set up a pipeline that will process the data. Again, because we want to process every 5 minutes, and the shortest 
  execution time of data factory is 15 minutes, we have to set up multiple activities using offsets. 

 - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - Right click on *Pipelines* and choose *New pipeline*
  - The template contains an empty pipeline. Download the file *pipeline.json* from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file. 
  - **DO NOT** click  *Deploy* yet

  For simplicity, lets look at one of the activity pairings in the file *First Phase Join* and *First Phase Scoring*. 
  #### First Phase Join
  This activity executes a USQL script located in the Azure Storage account and accepts three parameters - *queryTime*, *queryLength* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to join the 4 data streams (severity, charges, core, and dxpr) according to an id field and a time. The result 
  is a single output file with the results for the 5 minute window this activity should cover. 

  The output of this activity is then tied to the input of the *First Phase Scoring* activity, which will not execute until this activity is complete. 
  
  #### First Phase Scoring
  This activity executes a USQL script located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to perform feature engineering, score the data, and output the results of that work to
  a single output file with the scoring results for the 5 minute window this activity should cover.

  The output of this activity is what will feed the Power BI dataset.  

  #### Activity Period
  Every pipeline has an activity period associated with it. This is the period in time in which the pipeline should be actively processing data. Those time stamps are in the 
  properties *start* and *end* located at the bottom of the pipeline editor. 

  These times are UTC. Set the *start* property to the time right now, and set the *end* property to 1 week from now. This will ensure that your factory will not be 
  producing data over too long a period of time and we do that only because the generator to be set up next will not run infinitely. 

  Once you have updated the *start* and *end* properties ***you should now click the *Deploy* button at the top of the blade***.
  

## Download and configure the data generator  
 - Download the file ***healthcaregenerator.zip*** from the [datagenerator folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/datagenerator) of this repository.  
 - Unzip this file to the local disk drive of a Windows Machine.  
 - Open the file **HealthCareGenerator.exe.config** and modify the following AppSettings  
    - EventHubName : Enter the name used to create the Azure Event Hub (not the Event Hub Namespace).  
    - EventHubConnectionString : Enter the value of *CONNECTION STRING -PRIMARY KEY* that was collected after creating the Azure Event Hub.
    - StorageAccountName: Enter the value of *STORAGE ACCOUNT NAME* that was collected after creating the Azure Storage account.
    - StorageAccountKey: Enter the value of *PRIMARY ACCESS KEY* that was collected after creating the Azure Storage account.  
	- Save and close **HealthCareGenerator.exe.config** 
 - Double click the file **HealthCareGenerator.exe** to start data generation. This will open a console and show messages as data are streamed from the local computer into the event hub **manufactureeh**.  
    ***NOTE:*** The following PowerBI Dashboards will only be dynamically updated when this generator is running.  
    ***NOTE:*** Data generator can also be run in the cloud, using an Azure [Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-hero-tutorial). For some of the snapshots we show here, a Windows Server 2008 R2 SP1 [Virtual Machine](https://azure.microsoft.com/en-us/marketplace/virtual-machines/) was used with A4 Basic (8 Cores, 14 GB, 16 Data disks, 16x300 Max IOPS) configuration.

 Raw data will start to appear in the Azure Data Lake Store after approximately 5 minutes. Scored results will start to appear in the Azure Data Lake store after a period of 
 between 5 and 15 minutes.  

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. A picture is worth a thousand words. Lets head over to the [visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to connect to a Real-time dataset to build reports and dashboards using your data! 
 
  



