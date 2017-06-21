# Population Health Management - Manual Deployment Guide  

The goal of the solution guide presented here is to create a Population Health Management solution. It is geared towards hospitals and health care providers to manage and control the health care expenditure through disease prevention and management. This Manual Deployment Guide shows you how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite. It will walk you through how to manually set up and deploy all the individual services used in this solution. In the process you will learn about the underlying technology and function of each component, how to stitch them together to create an end to end solution.
 
**For technical problems or questions about deploying this solution, please post in the issues tab of the repository.**

Solution architecture 
=================================
![Solution Diagram Picture](media/PHMarchitecture.PNG?raw=true)

The architecture diagram above shows the solution design for Population Health Management Solution for Healthcare. The solution is composed of several Azure components that perform various tasks, viz. data ingestion, data storage, data movement, advanced analytics and visualization.  [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) is the ingestion point of raw records that will be processed in this solution. These are then pushed to Data Lake Store for storage and further processing by [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/). A second Stream Analytics job sends selected data to [PowerBI](https://powerbi.microsoft.com/) for near real time visualizations. [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) orchestrates, on a schedule, the scoring of the raw events from the Azure Stream Analytics job
 by utilizing [Azure Data Lake Analytics](https://azure.microsoft.com/en-us/services/data-lake-analytics/) for processing with both [USQL](https://msdn.microsoft.com/en-us/library/azure/mt591959.aspx) and [R](https://www.r-project.org/about.html). Results of the scoring are then stored in [Azure Data Lake Store](https://azure.microsoft.com/en-us/services/data-lake-store/) and visualized using Power BI.

----------
<a name="dsteps"></a>
[Deployment Steps:](#dsteps)
====================

To build the pipeline above for this solution, we will need to carry out the following steps:

- [Prerequisites](#prereq)
- [Create an Azure Resource Group for the solution](#azurerg)
- [Create Azure Storage Account](#azuresa) 
- [Create an Azure Event Hub](#azureeh) 
- [Create an Azure Data Lake Store](#azuredls)
- [Download and configure the data generator](#gen)
- [Create an Azure Web Job](#webjob)
- [Create Azure Stream Analytics Job](#azurestra) 
- [Create Azure Data Lake Analytics](#azuredla)
- [Create Azure Data Factory](#azuredf) 
- [Visualization](#vis) 

Below you will find the detailed instructions to carry out these steps.

<a name="prereq"></a>
## Prerequisites

Before we start deploying, there are some prerequisites required and naming conventions to be followed. This tutorial will require:

- An Azure subscription, which will be used to deploy the project 
   (a [one-month free
   trial](https://azure.microsoft.com/en-us/pricing/free-trial/) is
   available for new users)
- AzCopy installation.
- AdlCopy installation.
 
### Naming Convention - Create a unique string

This deployment guide walks the readers through the creation of each of the Cortana Intelligence Suite services in the solution architecture shown above. 
As there are usually many interdependent components in a solution, [Azure Resource Manager](https://azure.microsoft.com/en-gb/features/resource-manager/) enables you to 
group all Azure services in one solution into a resource group. Each component in the resource group is called a resource. We want to use a common name for the different 
services we are creating. However, several services, such as Azure Storage, require a unique name for the storage account across a region and hence a naming convention 
is needed that should provide the user with a unique identifier. The idea is to create a ***unique string*** (that has not been chosen by another Azure user) that will be incorporated into the name of each Azure resource you create. This string can include only lowercase letters and numbers, and must be less than 20 characters in length. To address this, we suggest employing a base service name based on solution scope (**healthcare**) and 
user's specific details like name and/or a custom numeric ID:  
**healthcare[UI][N]**  
where [UI] is the user's initials (in lowercase), N is a random integer(01-99) that you choose.  
  
To achieve this, all names used in this guide that contain string **healthcare** should be actually spelled as healthcare[UI][N]. A user, say, *Mary Jane* might create a ***unique string*** by using a base service name of healthcare**mj01** and all services names below should follow the same naming pattern. For example, in the section "Create an Azure Event 
Hub" below:   
- healthcareehns should actually be spelled healthcare**mj01**ehns   
- healthcareehub should actually be spelled healthcare**mj01**ehub   
 

### Installing AzCopy Command-Line Utility

AzCopy is a Windows command-line utility designed for copying data to and from Microsoft Azure storage. Download AzCopy from [here](https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy). Open this desktop App you just installed by [searching](media/azcopy1.jpg?raw=true) for ‘Microsoft Azure Storage command line’ or simple ‘azure storage command’. Open this app and you will get a [command prompt](media/azcopy2.PNG?raw=true). We will use this utility to transfer files to and from blob.

### Installing AdlCopy Command-Line Utility
AdlCopy is a command line tool to copy data from Azure Storage Blobs into Data Lake Store and between two Azure Data Lake Store accounts. The installation instructions are provided below.

Now that the prerequisites are fulfilled we can start the deployment process.

[..](#dsteps)
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
- Record the resource group name and location for later steps in this manual. We suggest you download the [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt) from above and store these there for future reference.


[..](#dsteps)
<a name="azuresa"></a>
## Create Azure Storage Account 
  The Azure Storage Account is required for several parts of this solution:
- It is used as the storage location for the raw event data used by the data generator that will feed the Azure Event Hub. 
- It is used as a Linked Service in the Azure Data Factory and holds the USQL scripts required to submit Data Lake Analytics jobs to process data by Azure Data Factory.

### Creation Steps
- Log into the [Azure Management Portal](https://portal.azure.com) 
- In the left hand menu select *Resource groups*
- Locate the resource group you created for this project and click on it, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click __+Add__.
- In the *Search Everything* search box, enter **Storage account**.
- Choose ***Storage account*** from the results, then click ***Create***.
    - Change the deployment model to *Classic*.
    - Set the name to **healthcarestorage** (modified to include your unique initials and number, e.g. **healthcaremj01storage**). 
    - Correctly set the subscription, resource group, and location. 
    - Click ***Create***.
  
The creation step may take several minutes. Navigate back to your resource group's blade and click "Refresh" until the storage account appears. Then follow the instructions below to collect important information that will be required in future steps:
- Click on the storage account's name in your resource group to load the storage account blade.
- On the storage account blade, select [**Access keys**](media/storageaccountcredentials.PNG?raw=true) from the menu on the left.
- Record the *STORAGE ACCOUNT NAME*, *KEY* and *CONNECTION STRING* values for *key1* in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt) you downloaded earlier.

You will need these three credentials to upload files to your storage account below, when starting the data generator and when setting up a Linked Service to access the files in your blob through Azure Data Factory. 

### Move resources to the storage account
  
Next we will create some containers and move the necessary files into the newly created containers. These files are the raw events used by the data generator as well as USQL scripts that will be called by the Azure Data Factory pipeline. We will create three containers: `data`, `scripts` and `forphmdeploymentbyadf`.

- Navigate to the storage account's overview blade. (If you are still on the **Access keys** page, click on **Overview** in the menu at left.)
- Click on *Blobs* in the storage account blade.
- Copy the input for the data generator:
    - Click __+ Container__.
       - Enter the name `data` and change the *Access type* to **Blob**.
       - Click ***Create***. You should see `data` appear in the list of containers.
    - On the [AzCopy terminal](../ManualDeploymentGuide/media/azcopy2.PNG?raw=true) command prompt, type [this](../ManualDeploymentGuide/rawevents/azCopy_command_data.txt) command.
       - Replace `EnterYourStorageAccountkeyhere` with your storage account key and `<storageaccountname>` with your storage account name in the command before executing. 
    - Return to the storage account's *Blobs* pane in Azure Portal and click on the container name `data`. You should see that [these](../ManualDeploymentGuide/rawevents/files_datagenerator) csv files have appeared in your container `data`.
- Copy the USQL scripts:
    - Click __+ Container__.
        - Enter the name `scripts` and change the *Access type* to **Blob**.
        - Click ***Create***. You should see `scripts` appear in the list of containers.
    - On the [AzCopy terminal](../ManualDeploymentGuide/media/azcopy2.PNG?raw=true) command prompt, type [this](../ManualDeploymentGuide/scripts/datafactory/azCopy_command_scripts_toblob.txt) command.
        - Replace `EnterYourStorageAccountkeyhere` with your storage account key and `<storageaccountname>` with your storage account name in the command before executing.
    - Return to the storage account's *Blobs* pane in Azure Portal and click on the container name `scripts`. You should see the [these](../ManualDeploymentGuide/scripts/datafactory/scripts_blob) four USQL files have appeared in your container `scripts`.
- Copy the supporting files for ADF:
    - Click __+ Container__.
        - Enter the name `forphmdeploymentbyadf` and change the *Access type* to **Blob**.
        - Click ***Create***. You should see `forphmdeploymentbyadf` appear in the list of containers.
    - On the [AzCopy terminal](../ManualDeploymentGuide/media/azcopy2.PNG?raw=true) command prompt, type [this](../ManualDeploymentGuide/scripts/datafactory/azCopy_command_forphmdeploymentbyadf_toblob.txt) command.
        - Replace 'EnterYourStorageAccountkeyhere' with your storage account key and \<storageaccountname\> with your storage account name in the command before executing.
    - Return to the storage account's *Blobs* pane in Azure Portal and click on the container name `forphmdeploymentbyadf`. You should see seventeen files listed [here](../ManualDeploymentGuide/scripts/datafactory) appear in your container `forphmdeploymentbyadf`. 
  
[..](#dsteps)  
<a name="azureeh"></a>
## Create an Azure Event Hub
  The Azure Event Hub is the ingestion point of raw records that will be processed in this solution. The role of Event Hub in solution architecture is as the "front door" for an event pipeline. It is often called an event ingestor.

- In the left-hand menu of the [Azure Management Portal](https://portal.azure.com), select *Resource groups*.
- Locate the resource group you created for this project and click on it, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click __+Add__.
- In the *Search Everything* search box enter **Event Hubs**.
- Choose ***Event Hubs*** from the results, then click *Create*. This will create the **namespace** for the Azure Event Hub.
- For the name, use ***healthcareehns*** (e.g. Mary Jane would enter healthcaremj01ehns).
- Correct set the subscription, resource group, and location.
- Click ***Create***.

The creation step may take several minutes.  Navigate back to *Resource groups* and choose the resource group for this solution. Refresh until the event hub namespace appears in the list of resources, then continue with the instructions below:

- Click on ***healthcareehns*** in the resource list, then on the subsequent blade click __+Event Hub__.
- Enter ***healthcareehub*** as the Event Hub name (e.g. Mary Jane would enter healthcaremj01ehub), move the partition count slider to 16, and click *Create*.
 
Once the Event Hub is created, we will create Consumer Groups. In a stream processing architecture, each downstream application equates to a consumer group. We will create two Consumer Groups here corresponding to writing event data to two separate locations: Data Lake Store (cold path) and Power BI (hotpath). (There is always a default consumer group in an event hub.)

- Click on the Event Hub ***healthcareehub*** you just created. (You may need to scroll down to see it listed on the event hub namespace's overview pane.)
- Click __+ Consumer Group__.
    - Enter `coldpathcg` as the "Name".
    - Click *Create*.
- Add the second consumer group by clicking on __+ Consumer Group__ again.
    - Enter `hotpathcg` as the "Name". 
    - Click *Create*.

From the **healthcareehns** resource (i.e. the event hub namespace that you created first), you will collect the following information required in future steps to set up Stream Analytics Jobs:

- On the ***healthcareeehns*** blade, choose [*Shared access policies*](../ManualDeploymentGuide/media/eventhub1.PNG?raw=true) from the menu under Settings.
- Select [**RootManageSharedAccessKey**](../ManualDeploymentGuide/media/eventhub2.PNG?raw=true) and record the value for **CONNECTION STRING -PRIMARY KEY** in the third row. You will need this when starting the generator.
- We suggest you record these in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt) downloaded earlier.

[..](#dsteps)
<a name="azuredls"></a>
## Create an Azure Data Lake Store
  The Azure Data Lake store is used as to hold raw and scored results from the raw data points generated by the data generator and streamed in through Stream Analytics job.

- In the left-hand menu of the [Azure Management Portal](https://ms.portal.azure.com), select *Resource groups*.
- Locate the resource group you created for this project and click on it, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click __+Add__.
- In the *Search Everything* search box, enter ***Data Lake Store***.
- Choose ***Data Lake Store*** from the results then click *Create*.
- Enter ***healthcareadls*** as the name (e.g. Mary Jane would enter healthcaremj01adls).
- Correctly set the subscription and resource group.
- Choose the location closest to the one used for the resource group.
- Click ***Create***.

The creation step may take several minutes. When deployment has finished, retrieve the Data Lake Store's URI as follows:
- Navigate back to the resource group blade and select the ***healthcareadls*** Data Lake Store.
- In the main pane, record the *ADL URI* value, which will be in the [form](../ManualDeploymentGuide/media/adlsuri1.PNG?raw=true) **adl://__********__.azuredatalakestore.net**. We suggest you record this in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt) downloaded earlier.

You will need this URI to connect Power BI to the data in your Data Lake Store. 

### Move resources to Data Lake Store
- In your Data Lake Store's overview pane, click the "Data Explorer" button along the top.
- In the Data Explorer blade, click on "New Folder". Enter **forphmdeploymentbyadf** when prompted for the folder name. This folder will contain all the scripts, models and files needed for deployment that will be used by Data Factory.
- We will move resources to this folder in Data Lake Store using AdlCopy:
    - Download and install AdlCopy from [here](https://www.microsoft.com/en-us/download/details.aspx?id=50358).
    - Open Command Prompt by typing `cmd` in the Windows search field.
    - Navigate to the folder where AdlCopy was [installed](../ManualDeploymentGuide/media/adlcopy1.PNG?raw=true), e.g.
    ```cd C:\Users\\\<username>\Documents\AdlCopy```
    - Type `AdlCopy` and press Enter. Confirm from the output that the program is [available](../ManualDeploymentGuide/media/adlcopy2.PNG?raw=true).
    - On the command prompt, enter [this](../ManualDeploymentGuide/scripts/datafactory/adlcopy_command_forphmdeploymentbyadf_blobtoadls.txt) command.
         - Replace `EnterYourStorageAccountkeyhere` with your storage account key, `<storageaccountname>` with your storage account name and `<adlsaccountname>` with your Data Lake Store name in the command before executing. 
    - If prompted with "Do you wish to continue?", type "Y".

In ~5 minutes (depending on the bandwidth) the files will be transferred to your folder `forphmdeploymentbyadf` in your Data Lake Store. These files must be in place before the Azure Data Factory pipelines (described below) can be run.

[..](#dsteps)
##   Start the Data Generator now 
With the [input data for the generator](../ManualDeploymentGuide/rawevents/files_datagenerator) uploaded to your storage account, the Event hub set up and the Data Lake Store created, we are ready to start the data generator. Once the generator is turned on, the Event Hub will start collecting the data. We will set up Stream Analytics job in the next steps that will process events from the Azure Event Hub and store in Data Lake Store and also push the incoming data to Power BI for visualization. If the generator is not running, you will not see streaming data coming in.

<a name="gen"></a>
### Download and configure the data generator  
- On your Windows machine, download the file ***healthcaregenerator.zip*** from the [datagenerator folder](../ManualDeploymentGuide/datagenerator) of this repository. The folder choice will keep the path length short, avoiding the 255 character limit on folder names.
- Navigate to the folder `C:\healthcaregenerator` where all the extracted files are found.
- Open the file **HealthCareGenerator.exe.config** in Notepad and modify the [following](../ManualDeploymentGuide/media/configfile.PNG?raw=true) AppSettings. (**NOTE:** If you do not see the .config file, in your Explorer window, click on View and check "File name extensions".)
    - EventHubName : Enter the name used to create the Azure Event Hub (not the Event Hub Namespace).  
    - EventHubConnectionString : Enter the value of *CONNECTION STRING -PRIMARY KEY* (not the PRIMARY KEY value) that was [collected](../ManualDeploymentGuide/media/eventhub2.PNG?raw=true) after creating the Azure Event Hub namespace.
    - StorageAccountName: Enter the value of *STORAGE ACCOUNT NAME* that was [collected](../ManualDeploymentGuide/media/storageaccountcredentials.PNG?raw=true) after creating the Azure Storage account.
    - StorageAccountKey: Enter the value of *PRIMARY ACCESS KEY* that was [collected](../ManualDeploymentGuide/media/storageaccountcredentials.PNG?raw=true) after creating the Azure Storage account.  
    - Save and close **HealthCareGenerator.exe.config** 

Next we will **test that that data generator is working correctly** by running it locally, before attempting to run it as a Web Job.
- Double-click the file **HealthCareGenerator.exe** to start data generation. This should open a console and show messages as data are streamed from the local computer into the event hub **healthcareeh**.  
- If you see messages on your console that look like   
   ```
   EVENTHUB: Starting Raw Upload  
   EVENTHUB: Upload 600 Records Complete  
   EVENTHUB: Starting Raw Upload  
   ```
   then your data generator was configured correctly and we can shut it down.
- **Shut down the generator** now by simply closing the console.
- Zip the contents of the folder `healthcaregenerator` by selecting all the files in this folder, then right-clickling and selecting "Send To Compressed (zipped) folder".

Look for the zipped file in the folder and rename it if you like. This zipped file will be uploaded to Azure Portal for the Web Job.

[..](#dsteps)
<a name="webjob"></a>
## Create an Azure WebJob
We will use an Azure [App Service](https://docs.microsoft.com/en-us/azure/app-service/app-service-value-prop-what-is) to create a Web App to run Data Generator Web Job which will simulate streaming data from hospitals. [Azure WebJobs](https://docs.microsoft.com/en-us/azure/app-service-web/websites-webjobs-resources) provide an easy way to run scripts or programs as background processes. We can upload and run an executable file such as cmd, bat, exe (.NET), ps1, sh, php, py, js, and jar. These programs run as WebJobs and can be configured to run on a schedule, on demand or continuously. Below we show how to use Azure Portal to create a Web App with a new App Service Plan (S1 standard) and then create a WebJob. We will upload the zip file (created above after modifying the settings in .config file) and set the Web Job as continuous and single instance.
  
- Log into the [Azure Portal](https://ms.portal.azure.com/) and press the "+ New" button at the upper left portion of the screen.
- Type "Web App" into the search box and then press Enter.
- Click on the "Web App" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
- In the "Web App" pane that appears:
    - Enter `healthcarewebapp` in the "App name" field (e.g. Mary Jane would enter healthcaremj01webapp).
    - Select the appropriate subscription and resource group.
    - Next we will select an App Service Plan:
        - Click on App Service plan/Location to load more options.
        - Click "+ Create New".
        - Enter `healthcarewebappplan` in the "App Service plan" field.
        - Choose your desired location and pricing tier (our recommended option "S1 Standard").
        - Click "OK".
    - Click "Create".
- Wait for your Web App deployment to complete (will take a few seconds).
- Navigate back to the Resource group and select the App Service just created.
- In the App Service blade on the left, click on *WebJobs* under Settings. (You may need to scroll down or use the search feature.)
- In the WebJobs blade, click ***+ Add***.
    - Enter `healthcarewebjob` in the "Name" field (e.g. Mary Jane would enter healthcaremj01webjob).
    - Upload the zipped file created above.
    - Select ***Continuous*** from drop-down menu for the "Type" field.
    - Select ***Single Instance*** from drop-down menu for the "Scale" field.
    - Click "OK".
- The WebJob will appear in the WebJobs list in a few seconds. Once the STATUS field says Running, data should start pumping in your Event Hub.
- To monitor your WebJob, select the WebJob and click on Logs at the top of the screen. You should [see](../ManualDeploymentGuide/media/webjob2.PNG?raw=true) similar messages to what you saw in the console when you tested the generator locally:   
    ```
    EVENTHUB: Upload 600 Records Complete   
    EVENTHUB: Starting Raw Upload    
    EVENTHUB: Upload 600 Records Complete    
    ```

Once the data generator is running, you should [see](../ManualDeploymentGuide/media/datageneratorstarted.PNG?raw=true) incoming data in your Event Hub within a few minutes. ***NOTE:*** The PowerBI Dashboards (see HotPath) will only be dynamically updated when the WebJob is running.  

[..](#dsteps)
<a name="azurestra"></a>
## Create Azure Stream Analytics Job - Cold and Hot Paths
  [Azure Stream Analytics](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-introduction) facilitates setting up real-time analytic computations on streaming data. Azure Stream Analytics job can be authored by specifying the input source of the streaming data, the output sink for the results of your job, and a data transformation expressed in a SQL-like language. In this solution, for the incoming streaming data, we will have two different output sinks - Data Lake Store (the *Cold Path*) and Power BI (the *Hot Path*). Below we will outline the steps to set up the cold path stream and the hot path stream. 

## Cold Path Stream
  For the cold path stream, the Azure Stream Analytics job will process events from the Azure Event Hub and store them into the Azure Data Lake Store. We will name this Steam Analytics Job **healthcareColdPath**. 

- Log into the [Azure Management Portal](https://ms.portal.azure.com) and click on *Resource groups* in the left-hand menu.
- Click on the resource group you created for this project, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click __+Add__.
- In the *Search Everything* search box, enter `Stream Analytics job`.
- Choose *Stream Analytics job* from the results, then click ***Create***.
- Enter `healthcareColdPath` as the Job name (e.g. Mary Jane would enter healthcaremj01ColdPath).
- Correctly set the subscription, resource group, and location.
- Click ***Create***.

The deployment step may take several minutes.  When deployment has finished, we are ready to add the *Inputs*, *Outputs* and *Query* for the Stream Analytics job:
- Return to the resource group blade and click on the ***healthcareColdPath*** resource to open the Stream Analytics job's blade.
- In the Stream Analytics job blade, click *Inputs*.
- At the top of the *Inputs* page, click ***+ Add***. Then enter the following settings:
    - Enter `InputHub` as the input alias.
    - Select *Data Stream* as the source type.
    - Select *Event hub* as the source.
    - Select *Use event hub from current subscription* as the import option.
    - Select *healthcareeehns* (or whatever you have chosen for the Event Hub namespace previously) as the service bus namespace.
    - Select *healthcareehub* (or whatever you have chosen for the Event Hub previously) as the event hub name.
    - Enter coldpathcg for Event hub consumer group.
    - Leave the event hub policy name unchanged on the *RootManageSharedAccessKey* setting.
    - Leave the event hub consumer group field empty.
    - Select *CSV* (**not** JSON) as the event serialization format.
    - Leave the delimiter set to *comma(,)*.
    - Leave the encoding set to *UTF-8*.
    - Finally, click the **Create** button.  
- Navigate back to the Stream Analytics job blade, and click *Outputs*. 
- At the top of the *Outputs* page, click ***+ Add***. Then enter the following settings to create the first output.
   - Enter `SeverityOutput` as the output alias.
   - Select *Data Lake Store* as the sink, then click the **Authorize** button that appears.
   - Leave the import option field set to *Select Data Lake Store from your subscription*.
   - Ensure the correct subscription has been selected.
   - Select **healthcareadls** (or whatever you have chosen for the ADLS previously) as the account name.
   - Enter `stream/raw/severity/{date}/{time}_severity` as the path prefix pattern.
   - Leave *YYYY/MM/DD* selected as the date format.
   - Leave *HH* selected as the time format.
   - Select *CSV* (**not** JSON) as the event serialization format.
   - Leave the delimiter set to *comma (,)*.
   - Leave the encoding set to *UTF-8*.
   - Click **Create**.
- Repeat the twelve steps used to create the first output in order to generate the second, third, and fourth outputs. You will need to modify the output alias and path prefix pattern for each output:
   - Settings for the second output:
      - Output alias: `ChargesOutput`
      - Path prefix pattern: `stream/raw/charges/{date}/{time}_charges`
   - Settings for the third output:
      - Output alias: `CoreOutput`
      - Path prefix pattern: `stream/raw/core/{date}/{time}_core`
   - Settings for the fourth output:
      - Output alias: `DxprOutput`
      - Path prefix pattern: `stream/raw/dxpr/{date}/{time}_dxpr`
- Navigate back to the Stream Analytics job blade and click *Query*.
- Download the file StreamAnalyticsJobQueryColdPath.txt from the [scripts/streamanalytics folder](../ManualDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window (after removing any text already present).  
- Click ***SAVE*** .
- When all inputs, outputs and the query have been entered, click ***Start*** at the top of the Overview page for the Stream Analytics job.
    - When asked for the desired job output start time, select *now*, then click on ***Start***.

Raw data will start to appear in the Azure Data Lake Store (in `/stream/raw/severity/`, `/stream/raw/core/`, `/stream/raw/charges/` and `/stream/raw/dxpr/` with the directory structure defined by path prefix patterns given above) after approximately 5 minutes.

## Hot Path Stream
  For the hot path, the Azure Stream Analytics job will process events from the Azure Event Hub and push them to Power BI for real time visualisation. We will name this Steam Analytics Job  **healthcareHotPath**.

- Log into the [Azure Management Portal](https://ms.portal.azure.com) and click on *Resource groups* in the left-hand menu.
- Click on the resource group you created for this project, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click __+Add__.
- In the *Search Everything* search box, enter `Stream Analytics job`.
- Choose *Stream Analytics job* from the results, then click ***Create***.
- Enter `healthcareHotPath` as the Job name (e.g. Mary Jane would enter healthcaremj01HotPath).
- Correctly set the subscription, resource group, and location.
- Click ***Create***.

The deployment step may take several minutes.  When deployment has finished, we are ready to add the Inputs, Outputs and Query for the Stream Analytics job:

- Return to the resource group blade and click on the ***healthcareHotPath*** resource to open the Stream Analytics job's blade.
- In the Stream Analytics job blade, click *Inputs*.
- At the top of the *Inputs* page, click ***+ Add***. Then enter the following settings:
    - Enter `HotPathInput` as the input alias.
    - Select *Data Stream* as the source type.
    - Select *Event hub* as the source.
    - Select *Use event hub from current subscription* as the import option.
    - Select *healthcareeehns* (or whatever you have chosen for the Event Hub namespace previously) as the service bus namespace.
    - Select *healthcareehub* (or whatever you have chosen for the Event Hub previously) as the event hub name.
    - Leave the event hub policy name unchanged on the *RootManageSharedAccessKey* setting.
    - Enter `hotpathcg` as the event hub consumer group.
    - Select *CSV* (**not** JSON) as the event serialization format.
    - Leave the delimiter set to *comma(,)*.
    - Leave the encoding set to *UTF-8*.
    - Finally, click the **Create** button. 
- Navigate back to the Stream Analytics job blade, and click *Outputs*. 
- At the top of the *Outputs* page, click ***+ Add***. Then enter the following settings to create the output:
   - Enter `PBIoutputcore` as the output alias.
   - Select *Power BI* as the sink, then click the **Authorize** button that appears.
   - Set the group workspace to *My Workspace*.
   - Enter `hotpathcore` as the dataset name.
   - Enter `hotpathcore` as the table name.
   - Click **Create**.
- Navigate back to the Stream Analytics job blade and click *Query*.
- Download the file StreamAnalyticsJobQueryHotPath.txt from the [scripts/streamanalytics folder](../ManualDeploymentGuide/scripts/streamanalytics) of this repository. Copy and paste the content into the query window (after removing any text already present).  
- Click ***SAVE*** .
- When the input, the output and the query have been entered, click ***Start*** at the top of the Overview page for the Stream Analytics job. 
    - When asked for the desired job output start time, select *now*, then click on ***Start***.

After some time, this new dataset *hotpathcore* will appear in the Datasets section of your Power BI account.
 
[..](#dsteps)
<a name="azuredla"></a>
## Create Azure Data Lake Analytics 
  Azure Data Lake Analytics is an on-demand analytics job service to simplify big data analytics. It is used here to process the raw records and perform other jobs such as feature engineering, scoring etc. You must have a Data Lake Analytics account before you can run any jobs. A job in ADLA is submitted using a [USQL](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-usql-activity) script. The USQL script for various jobs (joining, scoring etc.) can be found at [scripts/datafactory/scripts_blob/](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/) folder of this repository and was uploaded to storage in a previous step using azcopy, from whence Azure Data Factory will access them to automatically submit the various jobs. The USQL scripts will deploy various resources (viz. R scripts, trained models, CSV files with historic and metadata etc.) from the folder `forphmdeploymentbyadf` in your Data Lake Store. We created this folder in the step above when we created the Data Lake Store and uploaded the contents to this folder using [adlcopy](../ManualDeploymentGuide/scripts/datafactory/adlcopy_command_forphmdeploymentbyadf_blobtoadls.txt). One additional **important step** is to install U-SQL Extensions in your account. R Extensions for U-SQL enable developers to perform massively parallel execution of R code for end-to-end data science scenarios covering: merging various data files, feature engineering, partitioned data model building and, post-deployment, massively parallel FE and scoring.

- Log into the [Azure Management Portal](https://ms.portal.azure.com) and click on *Resource groups* in the left-hand menu.
- Locate the resource group you created for this project and click on it, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click ***+Add***.
- In the *Search Everything* search box, enter `Data Lake Analytics`.
- Choose *Data Lake Analytics* from the results, then click ***Create***.
- Enter `healthcareadla` as the name (e.g. Mary Jane would enter healthcaremj01adla).
- Correctly set the subscription and resource group.
- Choose the location closest to the one chosen for the resource group.
- Click on *Data Lake Store* and choose the Azure Data Lake Store created in the previous step (*healthcareadls*).
- Click ***Create***. The deployment step may take several minutes.
- When deployment has finished, navigate back to the resource group blade and click on the *healthcareadla* Data Lake Analytics resource.
- In the data lake analytics blade, locate and click on *Sample Scripts* under the *GETTING STARTED* section in the left-hand menu. (You may need to scroll down or use the search feature.)
- In the Sample Scripts [blade](../ManualDeploymentGuide/media/adla_install.PNG?raw=true), click on ***Install U-SQL Extensions*** to install U-SQL Extensions to your account.
  - This step will enable R (and Python) extensions to work with ADLA.
  - This step may take several minutes to complete.
  - Record the name of the Data Lake Analytics account just created in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt)

[..](#dsteps)
<a name="azuredf"></a>
## Create Azure Data Factory
  Azure Data Factory is a cloud-based data integration service that automates the movement and transformation of data and other steps necessary to convert raw stream data to useful insights. Using Azure Data Factory, you can create and schedule data-driven workflows called "pipelines." A pipeline is a logical grouping of activities that together perform a task. The activities in a pipeline define actions to perform on your data. In this data factory, we will have only one pipeline with four different activities. The compute service we will be using for data transformation in this Data Factory is Data Lake Analytics.

### Getting started with Azure Data Factory

- Log into the [Azure Management Portal](https://ms.portal.azure.com) and click on ***Resource groups*** in the left-hand menu.
- Locate the resource group you created for this project and click on it, displaying the resources associated with the group in the resource group blade.
- At the top of the Resource Group blade, click ***+Add***.
- In the *Search Everything* search box, enter `Data Factory`.
- Choose *Data Factory* from the results, then click ***Create***.
- Enter `healthcareadf` as the name (e.g. Mary Jane would enter healthcaremj01adf). 
- Correctly set the subscription and resource group.
- Choose the location closest to the one chosen for the resource group.
- Click ***Create***.

The deployment step may take several minutes. Wait until deployment has finished before continuing with the steps below.

### Azure Data Factory Linked Services
  In order for the data factory to link to the data locations, we will need to create *[Linked Services](https://docs.microsoft.com/en-us/rest/api/datafactory/data-factory-linked-service)*, which define the connection information needed for Data Factory to connect to external resources (much like connection strings). We will create a Linked Service for the Azure Storage account which contains the USQL scripts, another Linked Service for the Azure Data Lake Store where the data resides, and finally a Linked Service for the Azure Data Lake Analytics instance. We will set up these Linked Services first before we define the Datasets.

#### Azure Storage Linked Service
- Navigate back to the resource group blade and click on the *healthcareadf* data factory.
- Under *Actions*, click *Author and deploy*.
- At the top of the blade, choose *New data store* and select *Azure Storage* from the list. You will be presented with a draft.
- Replace `<accountname>` with the name of your storage account  you recorded earlier in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt).
- Replace `<accountkey>` with the storage account key you recorded earlier.
- At the top of the blade, click *Deploy*.

#### Azure Data Lake Store Linked Service
- Navigate back to the resource group blade and click on the *healthcareadf* data factory.
- Under *Actions*, click *Author and deploy*.
- At the top of the blade choose *New data store* and select *Azure Data Lake Store* from the list. You will be presented with a draft.
- For the *dataLakeStoreUri* setting, copy in the *ADL URI* value saved during the creation of the Azure Data Lake Store and recorded in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt). 
- Remove the properties marked as [Optional]. (These would be *accountName*, *resourceGroupName*, and *subscriptionId*.)
- At the top of the page, click ***Authorize***. You will notice some fields will get auto-filled after authorization. 
- At the top of the blade, click ***Deploy***.

#### Azure Data Lake Analytics Linked Service Compute Service
- Navigate back to the resource group blade and click on the *healthcareadf* data factory.
- Under *Actions*, click *Author and deploy*.
- At the top of the blade, click on ***...More***. Select *New compute* from the drop-down list, then choose *Azure Data Lake Analytics*. You will be presented with a draft.
- For the *accountName* setting, enter the Azure Data Lake Analytics resource name saved during the creation of the Azure Data Lake Analytics account and recorded in [deployment_notepad.txt](../ManualDeploymentGuide/deployment_notepad.txt)..
- You **must** remove the properties marked as [Optional]. (These would be *resourceGroupName* and *subscriptionId*.)
- At the top of the page, click ***Authorize***. You will notice some fields will get auto filled after authorization. 
- At the top of the blade, click ***Deploy***.

### Azure Data Factory Datasets
  Now that we have the Linked Services out of the way, we need to set up [Datasets](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-create-datasets), which will act as inputs and outputs for each of the activities in the Data Factory pipeline. In Azure Data Factory, these are defined in JSON format. The input dataset for the first activity in the pipeline will have the external flag set to true, as it is not explicitly produced by a data factory pipeline (this is the streaming data that is being collected in Data Lake Store through a Stream Analytics job). This flag is set to false otherwise. The processing window is defined by availability and is set to 15 minutes which means a data slice will be produced every 15 minutes.
 
- Navigate back to the resource group blade and select the *healthcareadf* data factory.
- Under *Actions*, click *Author and deploy*.
- At the top of the blade, click on *... More*. Choose *New dataset* from the drop-down list, then click on *Azure Data Lake Store*.
- Download the file [*inputdataset.json*](../ManualDeploymentGuide/scripts/datafactoryobjects/inputdataset.json) from the [scripts/datafactoryobjects](../ManualDeploymentGuide/scripts/datafactoryobjects) folder of this repository.
- Replace the content in the editor with the content of the downloaded file. 
- At the top of the blade, click ***Deploy***. You should see `01StreamedData` appear under *Datasets*.
- Repeat the steps above to generate four more datasets:
    - All four datasets will use the JSON template from the file [*outputdataset.json*](../ManualDeploymentGuide/scripts/datafactoryobjects/outputdataset.json) in the [scripts/datafactoryobjects](../ManualDeploymentGuide/scripts/datafactoryobjects) folder of this repository.
    - Before deploying each dataset, you will need to substitute `<replace name with instructions>` with one of the four names below:
        - `02JoinedData`
        - `03ScoredData`
        - `04ProcessedForPBIData`
        - `05AppendedToHistoricData`

When finished, you will have a total of five datasets.
  
### Azure Data Factory Pipeline
  With the services and datasets in place, it is time to set up a pipeline that will process the data.

- Navigate back to the resource group blade and select the *healthcareadf* data factory.
- Under *Actions* select *Author and deploy*.
- Right-click on *Pipelines* and choose *New pipeline*.
- The template contains an empty pipeline. Download the file [*pipeline.json*](../ManualDeploymentGuide/scripts/datafactoryobjects/pipeline.json) from the [scripts/datafactoryobjects](../ManualDeploymentGuide/scripts/datafactoryobjects)
  folder.
- Replace the content in the editor with the content of the downloaded file. 
- **DO NOT** click  *Deploy* yet!

Let's look closely at these activities and what they are doing. 

#### Joining

  This activity executes a [USQL script](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamjoin.usql) located in the Azure Storage account and accepts three parameters -- *queryTime*, *queryLength* and *outputFile*. You can learn more about the parameters and the exact work going on internally by reading the USQL query, but the effect is to join the 4 data streams (severity, charges, core, and dxpr) according to an id field and a time. The result is a single output file with the results for the 15 minute window this activity should cover. 

  The output of this activity is used as the input of the *Scoring* activity, which will not execute until this activity is complete. 
  
#### Scoring

  This activity executes a [USQL script](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamscore.usql) located in the Azure Storage account and accepts two parameters -- *inputFile* and *outputFile*. You can learn more about the parameters and the exact work going on internally by reading the USQL query, but the effect is to perform feature engineering, score the data, and output the results of that work to a single output file with the scoring results for the 15 minute window this activity should cover.

  The output of this activity is used as the input of the *Process for PBI* activity, which will not execute until this activity is complete.  

#### Processing for PBI

  This activity executes a [USQL script](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamforpbi.usql) located in the Azure Storage account and accepts two parameters - *inputFile* and *outputFile*. You can learn more about the parameters and the exact work going on internally by reading the USQL query, but the effect is to create data for visualization, and output the results of that work to a single output file for the 15 minute window this activity should cover.

#### Appending

  This activity executes a [USQL script](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamappend.usql) located in the Azure Storage account and does not accept any input parameters. This activity in effect appends the data created for visualization above to the historic visualization data, and output the latest records to a single output file. 

#### Activity Period

  Every pipeline has an activity period associated with it. This is the period in time in which the pipeline should be actively processing data. Those time stamps are in the properties *start* and *end* located at the bottom of the pipeline editor. These times are in UTC. In the pipeline JSON template provided [here](../ManualDeploymentGuide/scripts/datafactoryobjects/pipeline.json) the start and end are listed as such:
  ```
  "start": "yyyy-mm-ddT00:00:00Z",      
  "end": "yyyy-mm-ddT19:51:55Z",
  ```
  *The yyyy, mm and dd in these strings need to be replaced by the four-digit year and two-digit month and day.* Set the *start* property to the time right now, and set the *end* property to 1 week from now. e.g. If you were starting the Data Factory on August 18, 2017, the start and end could be entered as:
  ```
  "start": "2017-08-18T00:00:00Z",      
  "end": "2017-08-24T19:51:55Z",
  ```
  This will ensure that your data factory will not be producing data over too long a period of time. We do that only because the [data generator](#gen) (which you set up earlier and should be running) will not run infinitely. 

  Once you have updated the *start* and *end* properties, *click the **Deploy** button at the top of the blade*.

  Now that Azure Data Factory has been deployed, joined results will start to appear in the Azure Data Lake Store in `stream/joined` followed by scored results in `stream/scoring` etc. For more on how to monitor the pipeline, read [here](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-monitor-manage-pipelines). 

[..](#dsteps)
<a name="vis"></a>
## Visualization

  Congratulations! You have successfully deployed a Cortana Intelligence Solution. The hot path stream created above is pushing data to Power BI for real-time visualization. Our Power BI dashboard will also connect to the streaming data and predictions being stored in the Data Lake Store (cold path) along with historic data for visualization. A picture is worth a thousand words. Let's head over to the [visualization](../ManualDeploymentGuide/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data. 
 
  



