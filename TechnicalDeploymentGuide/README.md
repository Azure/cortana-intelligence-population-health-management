# Population Health Management - Technical Deployment Guide  

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
  - Select the 4 files in the **TechnicalDeploymentGuide\rawevents** folder in the project zip file and select **Upload**.
  - Select the *scripts* container
  - Click ***Upload*** at the top of the container blade and copy the contents 
  - Select all of the files in the **TechnicalDeploymentGuide\scripts\datafactory** folder in the project zip file and select **Upload**.

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
          
 - Navigate back to the Stream Analytics job blade and  Click *Outputs*  
   - At the top of the *Outputs* page click ***+ Add***
	   - Output alias : SeverityOutput  
         - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
         - Subscription: Should be set correctly
         - Account Name: Choose the Azure Data Lake Store created previously. 
         - Path prefix pattern: *stream/raw/severity/{date}/{time}_severity*
         - Date format: *YYYY/MM/DD*
         - Time format: *HH*
         - Event serialization format: CSV
         - Delimiter: remains comma (,)
         - Encoding: remains comma UTF-8
         - Click the **Create** button to complete  
   - At the top of the *Outputs* page click ***+ Add***
	   - Output alias : ChargesOutput  
         - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
         - Subscription: Should be set correctly
         - Account Name: Choose the Azure Data Lake Store created previously. 
         - Path prefix pattern: *stream/raw/charges/{date}/{time}_charges*
         - Date format: *YYYY/MM/DD*
         - Time format: *HH*
         - Event serialization format: CSV
         - Delimiter: remains comma (,)
         - Encoding: remains comma UTF-8
         - Click the **Create** button to complete  
   - At the top of the *Outputs* page click ***+ Add***
	   - Output alias : CoreOutput  
         - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
         - Subscription: Should be set correctly
         - Account Name: Choose the Azure Data Lake Store created previously. 
         - Path prefix pattern: *stream/raw/core/{date}/{time}_core*
         - Date format: *YYYY/MM/DD*
         - Time format: *HH*
         - Event serialization format: CSV
         - Delimiter: remains comma (,)
         - Encoding: remains comma UTF-8
         - Click the **Create** button to complete  
   - At the top of the *Outputs* page click ***+ Add***
	   - Output alias : DxprOutput  
         - Sink: Data Lake Store, then Click **Authorize** to allow access to the Data Lake  
         - Subscription: Should be set correctly
         - Account Name: Choose the Azure Data Lake Store created previously. 
         - Path prefix pattern: *stream/raw/dxpr/{date}/{time}_dxpr*
         - Date format: *YYYY/MM/DD*
         - Time format: *HH*
         - Event serialization format: CSV
         - Delimiter: remains comma (,)
         - Encoding: remains comma UTF-8
         - Click the **Create** button to complete  
  
- Click *QUERY*  
    - Download the file StreamAnalyticsJob.txt from the [resources folder](https://github.com/Azure/cortana-intelligence-quality-assurance-manufacturing/tree/master/Manual%20Deployment%20Guide/resources) of this repository. Copy and paste the content into the query window.  
    - Click *SAVE*  
- When all inputs, functions, outputs and the query have been entered, click *START* at the top of the Overview page.   

## **TBD Requires Longer Instructions ADLA/ADLS**  Create Azure Data Lake Store
  The Azure Data Lake store is used as to hold a number of data points

   - Raw streaming data from Event Hub 
   - Raw stream processed data
   - Scored results. 

## **TBD Requires Longer Instructions ADLA/ADLS**  Create Azure Data Lake Analytics
  The Azure Data Lake Analytics service required as a compute resource in Azure Data Factory and is used to process the raw stream data into insights that will be shown in the Power BI dashbaords.


## **TBD Requires Longer Instructions ADLA/ADLS**  Create Azure Data Factory
  The Azure Data Factory orchestrates the steps neccesary to process raw stream data



  
  
## **TBD Need full instrutions** Download and configure the data generator  
 - Download the file ***ManufacturingGenerator.zip*** from the [resources folder](https://github.com/Azure/cortana-intelligence-quality-assurance-manufacturing/tree/master/Manual%20Deployment%20Guide/resources) of this repository.  
 - Unzip this file to the local disk drive of a Windows Machine.  
 - Open the file **ManfuacturingGenerator.exe.config** and modify the following AppSettings  
    - EventHubName : ***manufactureeh*** (or whatever you have chosen for the event hub previously).  
    - EventHubConnectionString : Find this value with these steps  
	- Log into the [Azure Management Portal](https://ms.portal.azure.com)   
	- In the left hand menu select *Resource groups*  
	- Locate the resource group  you created for this project and click on it displaying the resources associated with the group in the resource group blade.  
	- Select the Event Hubs (service bus namespace) created for this project (***healthcareeehns*** or whatever you have chosen for the **Event Hubs** previously).  
	- From the menu on the namespace blade select *Shared access policies*  
	- Select *RootManageSharedAccessKey*  
	- Copy the content of the **CONNECTION STRING - PRIMARY KEY** (Warning: the string, *not* the plain *PRIMARY KEY*)  
 - Double click the file **ManfuacturingGenerator.exe** to start data generation. This will open a console and show messages as data are streamed from the local computer into the event hub **manufactureeh**.  
    ***NOTE:*** The following PowerBI Dashboards will only be dynamically updated when this generator is running.  
    ***NOTE:*** Data generator can also be run in the cloud, using an Azure [Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-hero-tutorial). For some of the snapshots we show here, a Windows Server 2008 R2 SP1 [Virtual Machine](https://azure.microsoft.com/en-us/marketplace/virtual-machines/) was used with A4 Basic (8 Cores, 14 GB, 16 Data disks, 16x300 Max IOPS) configuration.


## Configure a Power BI dashboard
 
 **TBD Need actual instructions**

 You can go to [Power BI Dashboard](https://powerbi.microsoft.com/) and use a Real-time dataset to build reports and dashboards using your data! This section is about creating a real-time dashboard through connecting Azure Stream Analytics queries to Power BI. There is another example of a Power BI Dashboard below in the SQL Data Warehouse section, where it is described how one can build dashboards using Power BI Desktop on top of data sitting in a database.
 
  



