# Patient-Specific Readmission Prediction and Intervention for Health Care

## Outline

- [Prerequisites](#prereqs)
- [Provision Azure Resources](#provision)
   - [Choose a Unique String](#unique)
   - [Create a Resource Group](#rg)
   - [Create an Event Hub](#eventhub)
   - [Create an HDInsight Spark cluster](#hdinsight)
   - [Create a Stream Analytics job](#asa)
   - [Create an Azure WebJob](#webjob)
   - [Create a Data Factory](#adf)
   - [Create an Azure SQL Database](#sql)
- [Train a Machine Learning Model with a Training Dataset](#train)
- [Apply the Trained Model to Generate Predictions](#predict)
- [Visualize the Predictions with Power BI](#powerbi)

<a name="prereqs"></a>
## Prerequisites

Before you begin, ensure that you have the following:

- An Azure subscription ([click here](https://azure.microsoft.com/en-us/free/) to start a free trial)
- An installed copy of [Microsoft SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
   - You may use any another client to connect to your SQL Server if you prefer, but instructions in this deployment guide will specifically be for SSMS (Microsoft SQL Server Managament Studio)
- A cloned, or downloaded and extracted, copy of [this git repository](https://github.com/Azure/cortana-intelligence-population-health-management)
- An installed copy of [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/) for creating the offline visualizations
- A [Power BI Online Account](https://powerbi.microsoft.com/en-us/get-started/) for report sharing and for creating real-time visualizations


Note that this guide will direct you to deploy a HDInsight Spark cluster with Python 2.7 for running the PySpark code included in the deployment guide. If you already have an instance of Spark with Python 2.7 installed locally, you may prefer to follow the [local Spark version](./local_spark.md) of this guide, which will not require you to deploy a HDInsight cluster.

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
    > **NOTE:** The resource availability in different regions depends on your subscription. When deploying your own resources, make sure all data storage and compute resources are created in the same region to avoid inter-region data movement. Azure Resource Group and Azure Data Factory do not have to be in the same region as the other resources. Azure Resource Group is a virtual group that groups all the resources into one solution. Azure Data Factory is a cloud-based data integration service that automates the movement and transformation of data. Data factory essentially orchestrates the activities of the other services. All the above mentioned resources should be deployed using the same subscription.
    
You will be taken to the resource group's overview page when the deployment is complete. In the future, you can navigate to the resource group's overview page from your [Azure Portal](https://ms.portal.azure.com/) dashboard.

<a name="eventhub"></a>
### Create an Event Hub

To create the Event Hub namespace that will coordinate the ingress of streaming data:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "Event Hubs" into the search box and then press Enter.
1. Click on the "Event Hubs" option published by Microsoft from the search results. Click on the blue "Create" button that appears on the  right pane.
1. In the "Create namespace" pane that appears:
    1. Enter your **unique string** in the "Name" field (this is the namespace name).
    1. Ensure that the "Standard" pricing tier is selected.
    1. Select the appropriate subscription, resource group, and location.
    1. Press "Create".
    
You can track the deployment progress under the "Notifications" list that is accessible by clicking the bell-shaped icon at the upper-right portion of the portal. The deployment may take several minutes. 

When the deployment is complete, follow the instructions listed below to create an event hub within your new Event Hub namespace:
1. In your resource group's overview pane, click on the resource of type "Event Hub." (You may need to refresh the list of deployments recently finished to view it).
1. In the overview pane that appears, click on "+ Event Hub" from the top bar.
1. In the "Create event hub" pane that appears:
   1. Enter `glucoseeventhub` in the "Name" field.
   1. Leave all the other settings with their default values.
   1. Click "Create".
1. Navigate back to the overview pane and then click on the "Shared access policies" link located at the left pane. (Note that the overview pane is for the  Event Hub namespace, not for the just created `glucoseeventhub` event hub.)
1. Click on the "RootManageSharedAccessKey" entry.
1. Press the "Click to copy" button to the right of the "Primary Key", and paste the key into an external memo file where you can easily access it for later reference.

<a name="hdinsight"></a>
### Create a HDInsight Spark cluster
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
    1. Under "Select a storage account", click the "Create new" link. Enter your **unique string** as the storage account name.
    1. Leaving all other fields at their default values, then click "Next".
1. In the "Summary" pane that appears:
    1. Click on the "Edit" link next to "Cluster size".
    1. Ensure that the number of worker nodes is set to "4". (Select the option 'View all' if you do not see this option by default).
    1. Set the "Worker node size" and "Head node size" to "D12 v2". (Select the option 'View all' if you do not see this option by default).
    1. Click "Next".
1. Click "Next" at the bottom of the "Advanced settings" pane that appears.
1. Click "Create" at the bottom of the "Summary" pane that appears.

	> **Note:** The cluster deployment may take around twenty minutes to complete. As you wait for the cluster deployment, you can finish the storage account setup and create the other Azure resources (Stream Analytics job, Azure WebJob, SQL database, Data Factory). You cannot see any data show up in these servcies yet until you finishing the "Prepare the training dataset" section at a later step.

#### Finish storage account setup

You will need the primary key for your storage account (which should be deployed momentarily) to proceed with creating the Stream Analytics job. To find the storage account's key:
1. Navigate to the resource group's overview pane.
1. Click on the resource of type "Storage account" once it has deployed. (You may need to refresh the list).
1. In the storage account overview pane that appears, click on the "Access keys" link on the left-hand list.
1. Press the "Click to copy" button next to "key1" to copy the primary key to your clipboard. Save this key in a memo file where you can easily access it as you continue through this guide.

	> **Note:** You may expect to wait for up to 10 minutes before you see the "Access keys" link in the storage account's overview pane.

You will also need to create a container inside the storage account to store glucose level readings for later:
1. Navigate to the storage account's overview pane and click "Blobs".
1. Click the "+ Container" button at the upper left in the "Blob service" pane that appears.
1. Create a container named `glucoselevelsaggs` with "Private" access type.
1. Create another container named `model` with "Container" access type.
1. Upload the supporting file to the `model` container:
   1. Click on the container named `model` in the "Blob service" pane. Click "Upload".
   1. Select the file `predict.py` from the "Manual Deployment Guide/HDInsight Spark" folder in your local copy of the git repository.
   1. Click "Upload."

<a name="asa"></a>
### Create a Stream Analytics job
Follow the steps below to create a Stream Analytics job which will copy incoming streaming data to your blob storage account for later processing:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "Stream Analytics job" into the search box and then press Enter.
1. Click on the "Stream Analytics job" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
1. In the "New Stream Analytics Job" pane that appears:
    1. Enter your **unique string** in the "Job name" field.
    1. Select the appropriate subscription, resource group, and location.
    1. Click "Create".
    
Your Stream Analytics job's deployment should complete within a few minutes. Once it has been created, continue the setup as follows:

1. Navigate to the resource group's overview pane.
1. Click on the resource of type "Stream Analytics job". (You may need to refresh the list).
1. On the job's overview pane, click on the "Inputs" box. Then click "Add".
   1. Type "glucoseeventhub" as the "Input alias".
   1. Ensure the source type is set to "Data stream".
   1. Ensure the source is set to "Event hub".
   1. Under "Import option", choose "Use event hub from current subscription".
   1. Select your **unique string** from the "Service bus namespace" drop-down menu.
   1. Ensure that "RootManageSharedAccessKey" is automatically selected for the "Event hub policy name".
   1. Ensure that "JSON" is chosen as the serialization format, and that the encoding type is set to "UTF-8".
   1. Click "Create".
1. Navigate back to the job's overview pane and click on the "Outputs" box. Then click "Add".
   1. Type "blobstorage" as the "Output alias".
   1. Choose "Blob storage" from the "Sink" drop-down menu.
   1. Select your storage account and provide the access key you recorded earlier. (If the "Storage account" drop-down menu shows any failure message, set "Import option" as "Provide blob storage settings manually" and enter storage account name and key accordingly).
   1. Enter `glucoselevelsaggs` as the "Container".
   1. Under "Path pattern", type "{date}" (without the quotation marks).
   1. Set the "Event serialization format" to "CSV".
   1. Leave the other fields with their default values, then click "Create".
1. Navigate back to the job's overview pane and click on the "Query" box.
   1. Replace the current contents of the Query box with the following:
   ```
    SELECT
         patient_nbr as patient_nbr,
         min(glucoseLevel) as mingl,
         max(glucoseLevel) as maxgl,
         avg(glucoseLevel) as meangl,
         var(glucoseLevel) as vargl,
         System.TimeStamp AS TimeStamp
    INTO
        blobstorage
    FROM
        glucoseeventhub
    group by 
    patient_nbr,
    TumblingWindow(second, 10);
   ```
   1. Now press the "Save" button located at the upper-left to save the query.

If you have a Power BI Online account, you can follow the instructions listed below to add a second output in this Stream Analytics job. 

1.  Navigate back to the job's overview pane and click on the "Outputs" box. Then click "Add".
   1. Type "vitalsignsmonitor" as the "Output alias".
   1. Choose "Power BI" from the "Sink" drop-down menu.
   1. Click the "Authorize" button and follow instructions to enter your Power BI credentials. (You may need to refresh your browser or switch to use Internet Explorer if you encounter problems).
   1. After the Power BI account is authorized, type "vitalsignsmonitor" as both Dateset Name Table Name.
   1. Leave the other fields with their default values, then click "Create".
   
1. Navigate back to the job's overview pane and click on the "Query" box.
   1. At the end of current contents of the Query box add with the following query:
	```
	 SELECT 	
		patient_nbr as Patient_ID,
    	glucoseLevel as Sensor_glucose,
    	System.TimeStamp AS TimeStamp,    
   		SUBSTRING ( cast(  System.TimeStamp as nvarchar(max)) ,0 ,11 )  as Reading_date
	INTO 
    	vitalsignsmonitor 
	FROM 
		glucoseeventhub; 

	```
	2. Now press the "Save" button located at upper-left to save the query.

Navigate back to the job's overview pane and click on the "Start" button located at the top of the window. Choose to start the stream analytics job now.

<a name="webjob"></a>
### Create an Azure WebJob
We will use the Azure WebJob to schedule the generation of streaming glucose readings for hypothetical patients. Follow the instructions below to create the WebJob:
1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "Web App" into the search box and then press Enter.
1. Click on the "Web App" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
1. In the "Web App" pane that appears:
    1. Enter your **unique string** in the "App name" field.
    1. Select the appropriate subscription and resource group.
    2. Click on App Service plan/Location to load more options.
       1. Click "+ Create New".
       2. Enter your **unique string** in the "App Service plan" field.
       3. Choose your desired location and pricing tier (select '+new' to select our recommended option "S1 Standard").
       4. Click "OK".
1. Click "Create".

When Web App deployment completes, follow the steps below to set up your WebJob's Python environment:
1. Navigate to your resource group's overview pane and click on the "App Service" resource.
2. Click on "Application settings" in the left-hand list of options, and modify the settings as follows:
   1. Set the Python version to "3.4".
   2. Set "Always On" to "On".
   3. Scroll down to the "App settings" section and enter the following key-value pairs:
      1. Key: `storage_name`, Value: your **unique string**
      2. Key: `storage_key`, Value: the Azure storage account key you recorded earlier.
      3. Key: `eh_namespace`, Value: your **unique string**.
      4. Key: `eh_key`, Value: the Event Hub key you recoded earlier.
   4. Press the "Save" icon along the top of the screen.
3. Click on "Webjobs" in the left-hand list of options.
4. Click "+ Add" to add a WebJob:
   1. Enter `glucosevaluegenerator` as the webjob name.
   2. Select the "glucose_value_generator.zip" file from the "Manual Deployment Guide/WebJob" folder of this repo to upload using "File Upload".
   3. Set "Type" to "Triggered".
   4. Under the "Triggers" drop-down menu, select "Scheduled."
   5. For the `cron` expression, enter "0 */5 * * * *" (without the quotation marks).
   5. Click "OK".
1. Once the WebJob appears in the WebJobs list, click on its name, then click "Run". The status will change from "Ready" to "Running".

After a few minutes, the WebJob's status should change to "Completed Just now". The WebJob will run again every five minutes. Note that your WebJob will not begin to produce output until later in this tutorial (after you have completed the "Prepare the training dataset" section).

<a name="adf"></a>
### Create a Data Factory

An Azure Data Factory is used to schedule periodic predictions via HDInsight. Follow these steps to create the data factory:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left portion of the screen.
1. Type "Data Factory" into the search box and then press Enter.
1. Click on the "Data Factory" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
1. In the "New data factory" pane that appears:
    1. Enter your **unique string** in the "Name" field.
    1. Select the appropriate subscription, resource group, and location. (Note that you may need to create your data factory in a different location than your other resources based on region availability; this should not affect performance.)    
    1. Click "Create".

We will return to configure the Data Factory later in this deployment guide once a trained model and input data has been created.

<a name="sql"></a>
## Create an Azure SQL database

Readmission predictions will be stored in an Azure SQL database to facilitate their display in Power BI. Follow these steps to create the Azure SQL database:

1. Log into the Azure Portal.
1. Press the "+ New" button at the upper left part of the screen.
1. Type "SQL Database" into the search box and press Enter.
1. Click on the "SQL Database" option published by Microsoft from the search results. Click the blue "Create" button that appears on the right pane.
1. In the "SQL Database" pane that appears:
      1. Enter your **unique string** in the "Database name" field.
      1. Select the appropriate subscription and resource group.
      1. Click "Server" to configure required settings:
      1. Click "+ Create a new server".
         1. Enter your **unique string** for the server name.
         1. Enter a username and password of your choice.
         1. Select the location of your choice.
         1. Click "Select".
      1. Click "Create".

Follow the steps below to create the necessary tables in your SQL database:
1. Navigate to your resource group's overview pane and click on the "SQL Server" resource.
1. Click on "Firewall" option located in the left-hand list of options, copy "Client IP address" shown on the screen and add it into the firewall rule list.
1. Open Microsoft SQL Server Management Studio.
1. In the connection dialog box:
   1. Enter `<your unique string>.database.windows.net,1433` for the server name (entering your **unique string** in place of the brackets in the expression)
   1. Ensure that the Authentication Type is set to "SQL Server Authentication".
   1. Enter the username and password you selected during deployment.
   1. Click "Connect".
1. After login, expand the "Databases" list available on the left to reveal the database you created (which should be named your **unique string**).1. Right-click on your database and select "New Query".
1. Run the included SQL query to generate the tables:
   1. Open the `create_tables.sql` file in the "Manual Deployment Guide/SQL Database" folder of this repository and copy its contents into the New Query window.
   1. Click "Execute".

<a name="train"></a>
## Train a Machine Learning Model with a Training Dataset

For model training and validation, this tutorial uses a [diabetes dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes) originally produced for the 1994 AAI Spring Symposium on Artificial Intelligence in Medicine, now generously shared by Dr. Michael Kahn on the [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/).

We show two work flows: [train-flow-1](./HDInsight%20Spark/train-flow-1.md) and [train-flow-2](./AMLworkbench/train-flow-2.md) to achieve this task. You must choose to follow one of them to proceed. Each work flow includes two Jupyter notebook files for preparing the training data, and for training the model, respectively. 

Specifically, train-flow-1 requires to upload the Jupyter notebook files into the provisioned HDI Spark cluster and to execute the files directly on the cluster. In this flow, we train the model using RandomForest algorithm with default parameter settings. On the other hand, train-flow-2 is performed through [Azure ML Workbench](https://docs.microsoft.com/en-us/azure/machine-learning/preview/overview-what-is-azure-ml). The benefit lies in that Azure ML Workbench provides strong support for model management. It enables data scientists to tune the models, to choose the best set of model parameters, and to select the best performed algorithms to use. It takes 10 minutes to follow through train-flow-1, or 20 minutes to follow through train-flow-2 if you already have an installed copy of Azure ML Workbench.


After finishing the model training, you should be able to see the Azure WebJob starts to generate data, which is then ingested into Event Hub. You should also see the activity starts to show up in Stream Analytics. When you open Power BI online account, a dataset "vitalsignsmonitor" will appear in the *DATASETS* section in the corresponding workspace. Since this dataset is the output directly from Stream Analtyics, real-time visuals can be created based on this dataset. Please follow this document on creating [real-time analytics dashboard for streaming data](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-power-bi-dashboard) in Power BI.

<a name="predict"></a>
## Apply the Trained Model to Generate Predictions

### Define Linked Services in Data Factory

We will use Azure Data Factory to schedule daily readmission probability predictions using the HDInsight Spark cluster and to schedule data transfers from blob storage to our SQL database. To define scheduled activities in Data Factory, we must first create definitions for the linked services involved in these activities -- in this case, the storage account, HDInsight cluster, and SQL database.

1. Navigate to your resource group's overview pane and click on the Data Factory resource.
2. Click on the "Author and deploy" button under "Actions".
3. On your local computer, navigate to the "Manual Deployment Guide/Data Factory/Linked Services" folder of your copy of this git repository, where you will find three JSON files for defining these services.
4. Repeat the set of instructions below for each of the three files (separately):
   1. Open the file in a text editor and search for the `<` character within the file. Replace the expressions in brackets that you find as indicated below:
      1. Replace `<your unique string>` (including the brackets) with your **unique string**.
      1. Replace `<storage account key>` with your storage account key.
      1. Replace `<HDInsight cluster user name>` with your HDInsight cluster user name. (The default user name is "admin".)
      1. Replace `<HDInsight cluster password>` with your HDInsight cluster password.
      1. Replace `<SQL server user name>` with your SQL server user name.
      1. Replace `<SQL server password>` with your SQL server password.
   1. Select all text in the modified file and copy it to your clipboard.
   1. Return to the "Author and deploy" Data Factory view in your browser and click "New data store", selecting any option on the drop-down list.
   1. Highlight and delete all the text that gets automatically generated in the window on the right pane. Now paste in the text you copied from your file into the empty pane.
   1. Click "Deploy".
1. Leave the "Author and deploy" Data Factory view open in your browser for the next step.

### Define Datasets in Data Factory

Some linked services contain multiple datasets: for example, your SQL database contains multiple tables, each of which will be involved in a separate copy operation. The steps below will define the necessary datasets for you.

1. On your local computer, navigate to the "Manual Deployment Guide/Data Factory/Datasets" folder of your copy of this git repository, where you will find seven JSON files for defining the datasets.
1. Repeat the set of instructions below for each file in the folder (separately):
   1. Open the file in a text editor and copy all of the text within to your clipboard. (No modifications are necessary.)
   1. Return to the "Author and deploy" Data Factory view in your browser and click "New data store", selecting any option on the drop-down list.
   1. Highlight and delete all text that gets automatically generated in the window at right. Now paste in the text you copied from your file into the empty pane.
   1. Click "Deploy".

### Define Pipelines in Data Factory

Now that the datasets have been defined, we can deploy the pipelines that schedule predictions and copy data from blob storage containers to the corresponding SQL tables.

1. On your local computer, navigate to the "Manual Deployment Guide/Data Factory/Datasets" folder of your copy of this git repository, where you will find four JSON files for defining the pipelines.
1. Repeat the set of instructions below for each file in the folder (separately):
   1. Open the file in a text editor.
   1. Edit the "start" and "end" fields to span your time range of interest (i.e. from slightly before you started the guide through some time after which no new data will be generated). Note that the time values should be given in UTC time. The time values in `predictionscopy.json` should have a lag than the time values in `sparkpipeline.json` to make sure the copy occurs after the prediction results are generated in the Blob.
   1. Search for the `<` character within the file. Replace any expressions in brackets that you find as indicated below:
      1. Replace `<your unique string>` with your **unique string (storage account name)**.
      1. Replace `<storage account key>` with the storage account key you recorded earlier.
   1. Highlight all of the text in the file and copy it to your clipboard.
   1. Return to the "Author and deploy" Data Factory view in your browser and click "New data store", selecting any option on the drop-down list.
   1. Highlight and delete all text that gets automatically generated in the window at right. Now paste in the text you copied from your file into the empty pane.
   1. Click "Deploy".

### Monitor progress

You can monitor the copy and compute progress for your pipelines as follows:

 1. Return to the overview pane for your data factory and click the "Datasets" button under "Contents". (You may need to scroll down to view this option).
 1. Click on one of the output datasets (`OutputDataset`, `PredictionsSQL`).
 1. Under the "Monitoring" section of the dataset's overview pane, you should see one or more slices generated.
 1. When output has been produced for each slice, its status should change to "Ready".
 1. You can also check for successful runs by looking for output predictions in the `predictions` container of your storage account and by confirming the addition of new rows into your SQL tables.

<a name="powerbi"></a>
## Visualize the Predictions with Power BI

The data source of this Power BI visualization is the previously created SQL database. Seeded data is pre-loaded in the SQL database when executing `create_tables.sql` in a previous step. Therefore, the visualizations can be created right after executing this file. However, in order to make the real time predictions show up in the visuals, the prediction results have to appear in the `predictions` container of your storage account and the ADF pipeline has to finish the copy from storage account to SQL database . 

Please follow the steps listed below to visualize the results in the Power BI Dashboard, and refresh the report once the real time data is available. 

1. Use Power BI Desktop to open the `PatientReadmissionDecisionReport.pbix` file in the "Technical Deployment Guide/Power BI" sub-folder of this repository.
1. From the Home tab, click on "Edit Queries."
1. Update the `predictions`, `intervension_programs`, and `readmission_cost` queries.
   1. Select all three queries and click on "Data Source Settings".
   1. In the "Data source settings" dialog box, click on "Change source".
      1. Enter `<your unique string>.database.windows.net` in the "Sever" field.
      2. Enter your **unique string** in the "Database" filed
      1. Click "OK".
   1. In the "Data source settings" dialog box, click on "Edit Permissions".
      1. Under "Credentials", click "Edit".
      1. In "Database" table, enter enter "User name" and "Password" fields.
      1. Click "OK".
   1. Click "Close".
1. Click "Refresh Preview". The queries should update with the prediction information from your Azure SQL database.
1. Click "Close & Apply" to return to the dashboard.

You may now use the dashboard to visualize the expected savings per patient from participation in the intervention program. The expected savings is largest for patients who are very likely to undergo readmission without the intervention; the expected savings may be small or negative for patients at low risk of readmission.
