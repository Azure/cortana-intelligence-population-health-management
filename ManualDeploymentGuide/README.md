# Population Health Management - Manual Deployment Guide  

The goal of the solution guide presented here is to create a Population Health Management solution. It is geared towards hospitals and health care providers to manage and control the health care expenditure through disease prevention and management. This Manual Deployment Guide shows you how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite. It will walk you through how to manually set up and deploy all the individual services used in this solution. In the process you will learn about the underlying technology and function of each component, how to stitch them together to create an end to end solution.
 
**For technical problems or questions about deploying this solution, please post in the issues tab of the repository.**

Solution architecture 
=================================
![Solution Diagram Picture](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/PHMarchitecture.PNG?token=AKE1nXC5BJDaxMRP14WOp2kgGeBpAiOSks5ZF7o1wA%3D%3D)

The architecture diagram above shows the solution design for Population Health Management Solution for Healthcare. 

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
 

----------

To build the pipeline above for this solution, we will need to carry out the following steps:

- Create an Azure Resource Group for the solution
- Create Azure Storage Account (Move resources to this storage account)
- Create an Azure Event Hub (Add two Consumer Groups)
- Create an Azure Data Lake Store
- Create Azure Data Lake Analtytics 
- Create Azure Stream Analytics Job (Cold and Hot Paths)
- Create Azure Data Factory (Linked Services, Datasets, Pipeline)
- Download and configure the data generator

Detailed instructions to carry out these steps can be found below under Deployment Steps. Before we start deploying, there are some prerequisites required and naming conventions to be followed.

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
  
where [UI] is the user's initials, N is a random integer(01-99) that you choose. Note that all characters must be entered in in lowercase.  
  
To achieve this, all names used in this guide that contain string **healthcare** should be actually spelled as healthcare[UI][N]. So for example, user **Mary Jane** might use a base service name of healthcare**mj01**, and all services names below should follow the same naming pattern. For example, in the section "Create an Azure Event 
Hub" below: 

 - healthcare***ehns*** should actually be spelled healthcare***mj01ehns*** 
 - healthcare***eh*** should actually be spelled healthcare***mj01eh***  
  
----------

Deployment Steps:
====================


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
  - You will need these credentials to access the files (usql scripts, R scripts and csv file) in your blob through ADF.

## Create an Azure Event Hub
  The Azure Event Hub is the ingestion point of raw records that will be processed in this solution. The role of Event Hub in solution architecture is as the "front door" for an event pipeline. It is often called an event ingestor.

 - Log into the [Azure Management Portal](https://portal.azure.com) 
 - In the left hand menu select *Resource groups*
 - Locate the resource group  you created for this project and click on it displaying the resources associated with the group in the resource group blade.
 - At the top of the Resource Group blade click __+Add__.
 - In the *Search Everything* search box enter **Event Hubs**
 - Choose ***Event Hubs*** from the results, then click *Create*, this will create the namespace for the Azure Event Hub.
 - For the name, use ***healthcareehns***
 - Subscription, resource group, and location should be correctly set.
 - Click ***Create*** 
 - The creation step may take several minutes.  
 - Navigate back to *Resource groups* and choose the resource group for this solution.
 - Click on ***healthcareehns***, then on the subsequent blade click __+Event Hub__
 - Enter ***healthcareeh*** as the Even Hub name, move partition count to 16 and click *Create*
 
 Once the Event Hub is created we will create Consumer Groups. In a stream processing architecture, each downstream application equates to a consumer group. We will create two Consumer Groups here corresponding to writing event data to two separate locations: Data Lake Store (cold path) and Power BI (hotpath). (There is always a default consumer group in an event hub)

 - Click on the Event Hub ***healthcareeh*** you just created, then on the subsequent blade click __+ Consumer Group__
 - Enter coldpathcg as Name
 - Add the second consumer group by clicking on __+ Consumer Group__ again.
 - Enter hotpathcg as Name 
 - You will need the names (coldpathcg and hotpathcg) when setting up stream analytics job.

 From the **healthcareehns** you will collect the following information as it will be required in future steps to set up Stream Analytics Jobs.

 - On the ***healthcareeehns*** blade choose *Shared access policies* from the menu
 - Select **RootManageSharedAccessKey** and record the value for *CONNECTION STRING -PRIMARY KEY*
 - Return to the ***healthcareehns*** blade and choose *Overview* from the menu and record the event hub name you just created above.
 - Click on ***healthcareeh** and locate Consumer Groups under Entities
 - Click on Consumer Groups under Entities and it will open a pane contaning the list of Consumer Groups you just added. Copy the names coldpathcg and hotpathcg.
 


##   Create an Azure Data Lake Store
  The Azure Data Lake store is used as to hold raw and scored results from the raw data points generated by the data generator and streamed in through Stream Analytics job.

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
  value which from the Data Lake Store blade which will be in the form **adl://---.azuredatalakestore.net**  e.g. adl://gsciqs1w6yadls.azuredatalakestore.net/
  - You will need this to connect PBI to the data in your Data Lake Store. 
  - Next we will create three folders (adfscripts, historicdata and models) in our Data Lake Store and upload files to them.
     - Navigate back to the resource group blade and select the ***healthcareadls*** Data Lake Store.
     - In the next blade, click in Data Explorer at the top.
     - In the Data Explorer blade, click on New Folder. You will be prompted to enter folder name. Enter adfscripts.
     - Create two other new folders the same way and name them historicdata and models.
     - Select the folder adfscripts and click on Upload at the top. Upload the contents of scripts/datafactory/scripts_adls here.
     - Select the folder historic data and upload the contents of rawevents/files_historic/ here
     - Select the folder models and upload the contents of scripts/datafactory/models here. 


##   Start the Generator now 
  With the data in rawevents/files_datagenerator folder uploaded to storage, the Event hub set up and Data Lake Store created, we can start the generator at this point before carrying out the next steps. Once the generator is turned on, the Event Hub will start collecting the data. We will set up Stream Analytics job in the next steps that will process events from the Azure Event Hub and store in Data Lake Store and also push the incoming data to Power BI for visualization.

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
    ***NOTE:*** The PowerBI Dashboards (see HotPath) will only be dynamically updated when this generator is running.  
    ***NOTE:*** Data generator can also be run in the cloud, using an Azure [Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-hero-tutorial). For some of the snapshots we show here, a Windows Server 2008 R2 SP1 [Virtual Machine](https://azure.microsoft.com/en-us/marketplace/virtual-machines/) was used with A4 Basic (8 Cores, 14 GB, 16 Data disks, 16x300 Max IOPS) configuration.



## Create Azure Stream Analytics Job - Cold and Hot Paths
  [Azure Stream Analytics](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-introduction) facilitates setting up real-time analytic computations on streaming data. Azure Stream Analytics job can be authored by specifying the input source of the streaming data, the output sink for the results of your job, and a data transformation expressed in a SQL-like language. In this solution, for the incoming streaming data, we will have two different output sinks - Data Lake Store (the *Cold Path*) and Power BI (the *Hot Path*). Below we will outline the steps to set up the cold path and the hot path. 

## Cold Path
  For the cold path, the Azure Stream Analytics job will process events from the Azure Event Hub and store them into the Azure Data Lake Store. We will name the Steam Analytics Job that we create for this, **HealthCareColdPath**. 

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Stream Analytics job***
  - Choose ***Stream Analytics job*** from the results then click *Create*
  - Enter ***HealthCareColdPath*** as the Job name.
  - Subscription, resource group, and location should be correctly set.
  - Click *Create*  
  - The creation step may take several minutes.  
  - Return to the resource group blade.
  - Select the ***HealthCareColdPath*** resource to open the Stream Analytics job to modify the job settings.  
  - In the Stream Analytics job blade click *Inputs* 
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
    - Download the file StreamAnalyticsJobQueryColdPath.txt from the [scripts/streamanalytics folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window.  
    - Click *SAVE*  
- When all inputs, functions, outputs and the query have been entered, click *Start* at the top of the Overview page for the Stream Analytics job and for *Job output start time*
select now, then click on **Start**.   

Raw data will start to appear in the Azure Data Lake Store (in stream/raw/severity/, stream/raw/core/ etc.) after approximately 5 minutes.

## Hot Path
  For the hot path, the Azure Stream Analytics job will process events from the Azure Event Hub and push them to Power BI for real time visualisation. We will name the Steam Analytics Job that we create for this, **HealthCareHotPath**. 

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Stream Analytics job***
  - Choose ***Stream Analytics job*** from the results then click *Create*
  - Enter ***HealthCareHotPath*** as the Job name.
  - Subscription, resource group, and location should be correctly set.
  - Click *Create*  
  - The creation step may take several minutes.  
  - Return to the resource group blade.
  - Select the ***HealthCareHotPath*** resource to open the Stream Analytics job to modify the job settings (specify Inputs, Outputs and Query).  
  
- In the Stream Analytics job blade click ***Inputs*** 
    - At the top of the *Inputs* page click ***+ Add***
        - Input alias : **HotPathInput**
        - Source Type : Data Stream
        - Source : Event hub
        - Import Option: Use event hub from current subscription
        - Service bus namespace: ***healthcareeehns*** (or whatever you have chosen for the __Event Hub**s**__ namespace previously)
        - Event hub name: ***healthcareeh*** (or whatever you have chosen for the event hub previously, NO it is healthcareeh)
        - Event hub policy name: leave unchanged at *RootManageSharedAccessKey*
        - Event hub consumer group: **hotpathcg** (we created this above)
        - Event serialization format : CSV
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
    - Download the file StreamAnalyticsJobQueryHotPath.txt from the [scripts/streamanalytics folder](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window. 
    - Click *SAVE*  
- When all inputs, functions, outputs and the query have been entered, click *Start* at the top of the Overview page for the Stream Analytics job and for *Job output start time*
select Now, then click on **Start**.   
- After some time in the Datasets section of your PowerBI, this new dataset hotpathcore will appear.
 
##   Create Azure Data Lake Analtytics 
  Azure Data Lake Analytics is an on-demand analytics job service to simplify big data analytics. It is used here to process the raw records and perform other jobs such as feature engineering, scoring etc. You must have a Data Lake Analytics account before you can run any jobs. A job in ADLA is submitted using a [usql](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-usql-activity) script. The usql script for various jobs (joining, scoring etc. ) can be found at scripts/datafactory/scripts_storage/ and will need to be uploaded to storage from where the ADF will access them to automatically submit the various jobs. The usql scripts  will deploy various resources (e.g. R scipts, trained models, csv files with historic and metadata etc), these can be found in your data lake store adfscripts/, historicdata/ and models/. We created these folders in the steps above when we created the Data Lake Store and uploaded the contents to these folders.

  - Log into the [Azure Management Portal](https://ms.portal.azure.com) 
  - In the left hand menu select *Resource groups*
  - Locate the resource group you created for this project and click on it displaying the resources associated with the group in the resource group blade.
  - At the top of the Resource Group blade click __+Add__.
  - In the *Search Everything* search box enter ***Data Lake Analytics***
  - Choose ***Data Lake Analytics*** from the results then click *Create*
  - Enter ***healtcahreadla*** as the name.
  - Subscription and resource group should be correctly set and the location should be the closest location to the one chosen for the resource group.
  - Click on *Data Lake Store* and choose the Azure Data Lake store created in the previous step. (Data Lake Analytics account has an Azure Data Lake Store account dependency and is referred as the default Data Lake Store account.)
  - Click ***Create***  
  - The creation step may take several minutes.
  - When completed, navigate back to the resource group blade and select the ***healthcareadla*** Data Lake Account.
  - In the Overview Panel on the left, scroll down to the GETTING STARTED section, locate and click on 'Sample Scripts'.
  - In the Sample Scripts blade, click on Install U-SQL Extensions to install U-SQL Extensions to your account.
  - This is an important step to enable R (and python) extensions to work with ADLA.
  

## Create Azure Data Factory
  Azure Data Factory (ADF) is a cloud-based data integration service that automates the movement and transformation of data and other steps necessary to convert raw stream data to useful insights. Using Azure Data Factory, you can create and schedule data-driven workflows (called pipelines). A pipeline is a logical grouping of activities that together perform a task. The activities in a pipeline define actions to perform on your data. In this data factory we have only one pipeline. The compute service we will be using for data transformation in this ADF is Data Lake Analytics. In our pipeline we have essentially three activities and three sets of each of these activities.
  
  Before we start authoring the ADF, let us get our requirements together and understand the design of the pipeline.

 Activity 1 -  Join

 If you recall the stream analytics job (ColdPath above) had 4 outputs that were being stored in ADLS. (Note: ASA is independent of ADF and is not part of it). The first activity in this pipeline is an ADLA job that will merge these four files into one. The usql script that ADF will fire to submit this job is called "hcadfstreamjoin.usql". This joining activity will be done every 5 mins. To carry out this activity we will need to specify the location of the input Dataset (DataLakeInputSet) and location to store the output Dataset (JoinSliceOutputSet). We do this by creating 'Datasets' in ADF. A dataset in Data Factory is defined in JSON format. In order for data factory to link to your Data Lake Store, we will need to create a 'LinkedService' which are much like connection strings, which define the connection information needed for Data Factory to connect to external resources. The Linked Service "AzureDataLakeStoreLinkedService" will link your Data Lake Store to Data Factory. The usql script for this job sits in a storage account that you created above. We will create a second LinkedService  called "AzureStorageLinkedService" for ADF to connect to this storage account to access the usql script. Additionally the ADF will submit this job in Azure Data Lake Analytics account. Hence for ADF to access your ADLA we will create "AzureDataLakeAnalyticsLinkedService" which is actually a compute service.

There are 3 sets of this activity producing  
"JoinSliceOutputSet1", "JoinSliceOutputSet2" and "JoinSliceOutputSet3"

  
 Activity 2 - Score

 The second activity will be taking this merged file and push it through scoring pipeline. The usql script (hcadfstreamjoin.usql) that the ADF will fire can be found here. This usql script will deploy the pre-trained R models and return the predictions as well as the raw data. There are 3 sets of this activity producing  
"ScoreSliceOutputSet1", "ScoreSliceOutputSet2" and "ScoreSliceOutputSet3"

Activity 3 - Create data for visialization

  Once we have the predictions, we want to create a dateset for visualisation. The usql script (hcadfstreamforpbi.usql) that ADF will fire to curate the data for visualisation purpose can be found here. There are 3 sets of this activity producing
"ForPBISliceOutputSet1", "ForPBISliceOutputSet2" and "ForPBISliceOutputSet3"

  The shortest execution time of data factory is 15 minutes. However we want to process every 5 minutes. To achieve this we have to set up multiple activities using offsets ( 3 sets of each activity). This explains the 9 activities instead of 3 in our pipeline. This demo accelerates actual processing
  time for the sake of useful visualizations in a short amount of time. To accomplish that this demo will utilize overlapping Azure Data Lake activities in the pipeline to produce results approximately every 5 minutes. To produce results every 5 minutes requires that this demo create additional resources that may not be neccesary in an actual enterprise deployment. This is because Azure Data Factory works by allowing pipelines to flow using dependencies. To understand the concept better, read [this](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-scheduling-and-execution) article.

  Now that we understand the pipeline design, we can get started on creating the Data Factory.

### Azure Data Factory - get started

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
  This Azure Data Factory is going to require certain services to work on the raw data and produce insights. These services are a link to the Azure Storage account which contains the USQL scripts for Azure Data Lake Analytics, the Azure Data Lake store where the data resides, and finally the Azure Data Lake analytics instance. 
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
  - At the top of the page, click **Authorize** and when complete you can remove the properties marked as [Optional]. These will be *accountName*, *resourceGroupName*, and *subscriptionId*.  
  -  what about ? "servicePrincipalId": "<Specify the service principal id>",
            "servicePrincipalKey": "<Specify the Service principal key>",
            "tenant": "microsoft.onmicrosoft.com",
  - At the top of the blade, click *Deploy*

  Azure Data Lake Analytics Linked Service Compute Service

  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade instead of *New data store* choose *... More* and choose **New compute** and then *Azure Data Lake Analytics* from the list
  - At the setting *accountName* enter the Azure Data Lake Analytics resource name you provided earlier. 
  - You will be presented a draft
  - At the top of the page, click **Authorize** and when complete you can remove the properties marked as [Optional]. These will be *resourceGroupName*, 
  and *subscriptionId*.  what about ? *"sessionId"* 
  - At the top of the blade, click *Deploy*

### Azure Data Factory Datasets
  Now that we have the services out of the way, we need to set up Datasets which will act as inputs and outputs to the Data Factory pipeline. For this, we use a single 
  input to start off the processing.

  Setting up the starting file. This file does not exist, but will be tagged as an *external* file so that Data Factory does not check for it's existence.
 
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Under *Actions* select *Author and deploy*
  - At the top of the blade instead of *New data store* choose *... More* and choose **New dataset** and then *Azure Data Lake Store* from the list.
  - The template contains quite a few settings, which we will not cover. Instead download the file *inputdataset.json* from the [scripts/datafactoryobjects](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/TechnicalDeploymentGuide/scripts/datafactoryobjects)
  folder.
  - Replace the content in the editor with the content of the downloaded file. 
  - At the top of the blade, click *Deploy*
  - You should see 'DataLakeInputSet' appear under Datasets.

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
  - You should see 'JoinSliceOutputSet1' appear under Datasets
  - Click on the newly created set *JoinSliceOutputSet1*
    - Click the *Clone* button at the top of the blade. 
    - Enter in one of the names below and hit the *Deploy* button at the top of the blade:
      - JoinSliceOutputSet2
      - JoinSliceOutputSet3
      - ScoreSliceOutputSet1
      - ScoreSliceOutputSet2
      - ScoreSliceOutputSet3
      - ForPBISliceOutputSet1
      - ForPBISliceOutputSet2
      - ForPBISliceOutputSet3
   - When finished you will have a total of 10 datasets.
  
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

  For simplicity, lets look at one of the activity pairings in the file *First Phase Join*, *First Phase Scoring* and *First Phase ForPBI*. 

  #### First Phase Join

  This activity executes a USQL script located in the Azure Storage account and accepts three parameters - *queryTime*, *queryLength* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to join the 4 data streams (severity, charges, core, and dxpr) according to an id field and a time. The result 
  is a single output file with the results for the 5 minute window this activity should cover. 

  The output of this activity is then tied to the input of the *First Phase Scoring* activity, which will not execute until this activity is complete. 
  
  #### First Phase Scoring

  This activity executes a USQL script located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to perform feature engineering, score the data, and output the results of that work to
  a single output file with the scoring results for the 5 minute window this activity should cover.

  The output of this activity is then tied to the input of the *First Phase ForPBI* activity, which will not execute until this activity is complete.  

  #### First Phase ForPBI

  This activity executes a USQL script located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the 
  parameters and the exact work going on internally, but the effect is to create data for visualization, and output the results of that work to
  a single output file for the 5 minute window this activity should cover.
 

  #### Activity Period

  Every pipeline has an activity period associated with it. This is the period in time in which the pipeline should be actively processing data. Those time stamps are in the 
  properties *start* and *end* located at the bottom of the pipeline editor. 

  These times are UTC. Set the *start* property to the time right now, and set the *end* property to 1 week from now. This will ensure that your factory will not be 
  producing data over too long a period of time and we do that only because the generator (to be set up next) will not run infinitely. 

  Once you have updated the *start* and *end* properties ***you should now click the *Deploy* button at the top of the blade***.
  



 Azure Data Factory is deployed now. Scored results will start to appear in the Azure Data Lake store after a period of between 5 and 15 minutes. 

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. After completion of hot path steps above, the data is being pushed to Power BI for real time visualization. Additionally we also connect to the streaming data and predictions being stored in the Data Lake Store (cold path) along with historic data from Power BI for visualization. A picture is worth a thousand words. Lets head over to the [visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data. 
 
  



