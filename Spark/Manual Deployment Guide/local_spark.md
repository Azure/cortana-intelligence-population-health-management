# Technical Deployment Guide for Patient Readmission Prediction for Health Care (Local Spark Context Version)

## Outline

- [Prerequisites](#prereqs)
- [Provision Azure Resources](#provision)
   - [Choose a Unique String](#unique)
   - [Create a Resource Group](#rg)
   - [Create an Event Hub](#eventhub)
   - [Create a Storage Account](#storage)
   - [Create a Stream Analytics job](#asa)
   - [Create an Azure WebJob](#webjob)
   - [Create a Data Factory](#adf)
   - [Create an Azure SQL Database](#sql)
- [Train a Machine Learning Model with a Training Dataset](#train)
   - [Prepare the Training Dataset](#dataprep)
   - [Train and Evaluate the Model](#model)
- [Apply the Trained Model to Generate Predictions](#predict)
- [Visualize the Predictions with Power BI](#powerbi)

<a name="prereqs"></a>
## Prerequisites

Note: this version of the Technical Deployment Guide assumes that you already have the ability to run PySpark Jupyter notebooks locally in Python 2.7. If you prefer to run your notebooks on a preconfigured HDInsight Spark cluster, please see the [original version of this guide](./README.md).

Before beginning, you will need:

- An Azure subscription ([click here](https://azure.microsoft.com/en-us/free/) to start a free trial)
- A [PowerBI Account](https://powerbi.microsoft.com/en-us/get-started/)
- An installed copy of [PowerBI Desktop](https://powerbi.microsoft.com/en-us/desktop/)
- An installed copy of [Microsoft SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
   - You may use another client to connect to your SQL Server if you prefer, but instructions will specifically mention SSMS.
- A cloned, or downloaded and extracted, copy of [this git repository](https://github.com/Azure/cortana-intelligence-readmissionprediction)
- A local Jupyter Notebooks server with Python 2.7 and PySpark kernel

<a name="provision"></a>
## Provision Azure Resources

<a name="unique"></a>
### Choose a Unique String

To help track the Azure resources you create in this tutorial, we suggest that you select a unique string that will be incorporated into the name of each Azure resource you create. This string should include only lowercase letters and numbers, and be less than ten characters in length. To ensure that your string has not been chosen by another Azure user, we recommend including your initials as well as randomly-chosen number.

<a name="rg"></a>
### Create a Resource Group

We recommend creating all of the Azure resources needed for this tutorial under the same, temporary resource group: you can then easily delete all resources at once when you are finished with this guide. You will be asked to choose a location for your resource group: we recommend choosing a location in which your Azure subscription has at least 24 cores available for the creation of an HDInsight cluster. (There is typically no limit on the creation of the other types of Azure resources used in this tutorial.)

To create the resource group:
1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left of the screen.
1. Type "Resource group" into the search box and press Enter.
1. Click on the "Resource group" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the new pane:
    1. Enter your **unique string** for the "Resource group name".
    1. Select the appropriate subscription and resource group location.
    1. Check the "Pin to dashboard" checkbox.
    1. Press "Create".
    
You will be taken to the resource group's overview page when its deployment is complete. In the future, you can navigate to the resource group's overview page from your [Azure Portal](https://ms.portal.azure.com/) dashboard.

<a name="eventhub"></a>
### Create an Event Hub

To create the Event Hub namespace that will coordinate the ingress of streaming data:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left of the screen.
1. Type "Event Hubs" into the search box and press Enter.
1. Click on the "Event Hubs" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the "Create namespace" pane that appears:
    1. Enter your **unique string** in the "Name" field.
    1. Ensure that the "Standard" pricing tier is selected.
    1. Select the appropriate subscription, resource group, and location.
    1. Press "Create".
    
You can track deployment progress under the "Notifications" list accessible by clicking the bell-shaped icon at the upper-right of the portal. Deployment may take several minutes. 

When deployment is complete, follow the instructions below to create an event hub within your new Event Hub namespace:
1. In your resource group's overview pane, click on the resource of type "Event Hub." (You may need to refresh the list if deployment recently finished.)
1. In the overview pane that appears, click on "+ Event Hub" along the top bar.
1. In the "Create event hub" pane that appears:
   1. Enter `glucoseeventhub` in the "Name" field.
   1. Leave all other settings on their default values.
   1. Click "Create".
1. Navigate back to the overview pane and click the "Shared access policies" link at left.
1. Click on the "RootManageSharedAccessKey" entry.
1. Press the "Click to copy" button to the right of the "Primary Key", and paste the key into a memo file where you can easily access it later.

<a name="storage"></a>a>
### Create a Storage Account

If you chose not to create an HDInsight cluster, you will need to create a storage account as follows:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left of the screen.
1. Type "Storage account" into the search box and press Enter.
1. Click on the "Storage account - blob, file, table, queue" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the "Basics" pane that appears:
    1. Enter your **unique string** in the "Name" field.
    1. Choose the appropriate subscription, resource group, and location.
    1. Click "Create."

You will need the primary key for your storage account (which should be deployed momentarily) to proceed with creating the Stream Analytics job. To find the storage account's key:
1. Navigate to the resource group's overview pane.
1. Click on the resource of type "Storage account" once it has deployed. (You may need to refresh the list.)
1. In the storage account overview pane that appears, click on the "Access keys" link in the left-hand list.
1. Press the "Click to copy" button next to "key1" to copy it to your clipboard. Save this key in a memo file where you can easily access it as you continue through this guide.

You will also need to create a container inside of the storage account to storage glucose level readings for later processing:
1. Navigate to the storage account's overview pane and click "Blobs".
1. Click the "+ Container" button at upper left in the "Blob service" pane that appears.
1. Create a container named `glucoselevelsaggs` with "Private" access type.
1. Create another container named `model` with "Container" access type.

<a name="asa"></a>
### Create a Stream Analytics job

Follow the steps below to create a Stream Analytics job which will copy incoming streaming data to your blob storage account for later processing:

1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left of the screen.
1. Type "Stream Analytics job" into the search box and press Enter.
1. Click on the "Stream Analytics job" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the "New Stream Analytics Job" pane that appears:
    1. Enter your **unique string** in the "Job name" field.
    1. Select the appropriate subscription, resource group, and location.
    1. Click "Create".
    
Your Stream Analytics job's deployment should complete within a few minutes. Once it has been created, continue setup as follows:

1. Navigate to the resource group's overview pane.
1. Click on the resource of type "Stream Analytics job". (You may need to refresh the list.)
1. On the job's overview pane, click on the "Inputs" box. Click "Add".
   1. Choose "glucoseeventhub" for the "Input alias".
   1. Ensure the source type is set to "Data stream".
   1. Ensure the source is set to "Event hub".
   1. Under "Import option", choose "Use event hub from current subscription".
   1. Select your **unique string** from the "Service bus namespace" drop-down menu.
   1. Ensure that "RootManageSharedAccessKey" is automatically selected for the "Event hub policy name".
   1. Ensure that "JSON" is chosen as the serialization format, and that the encoding type is set to "UTF-8".
   1. Click "Create".
1. Navigate back to the job's overview pane and click on the "Outputs" box. Click "Add".
   1. Choose "blobstorage" for the "Output alias".
   1. Choose "Blob storage" from the "Sink" drop-down menu.
   1. Select your storage account and provide the access key you recorded earlier.
   1. Enter `glucoselevelsaggs` as the "Container".
   1. Under "Path pattern", type "{date}" (without the quotation marks).
   1. Set the "Event serialization format" to "CSV".
   1. Leaving other fields at their default values, click "Create".
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
    TumblingWindow(second, 10)
   ```
   1. Press the "Save" button at upper-left.
1. Navigate back to the job's overview pane and click the "Start" button along the top of the window. Confirm that you wish the stream analytics job to start now.

<a name="webjob"></a>
### Create an Azure WebJob
We will use the Azure WebJob to schedule the generation of streaming glucose readings for imagined patients. Follow the instructions below to create the WebJob:
1. Log into the [Azure Portal](https://ms.portal.azure.com/).
1. Press the "+ New" button at the upper left of the screen.
1. Type "Web App" into the search box and press Enter.
1. Click on the "Web App" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the "SQL Database" pane that appears:
    1. Enter your **unique string** in the "App name" field.
    1. Select the appropriate subscription and resource group.
    2. Click on App Service plan/Location to load more options.
       1. Click "+ Create New".
       2. Enter your **unique string** in the "App Service plan" field.
       3. Choose your desired location and pricing tier (we recommend "S1 Standard").
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
   2. Select the "glucose_value_generator.zip" file from the "Technical Deployment Guide/WebJob" folder of this repo as the "File Upload".
   3. Set "Type" to "Triggered".
   4. Under the "Triggers" drop-down menu, select "Scheduled."
   5. For the `cron` expression, enter "0 */5 * * * *" (without the quotation marks).
   5. Click "OK".
1. Once the WebJob appears in the WebJobs list, click on its name, then click "Run". The status will change from "Ready" to "Running".

After a moment, the WebJob's status should change to "Completed Just now". The WebJob will run again every five minutes. Note that your WebJob will not begin to produce output until later in this tutorial (after you complete the "Prepare the training dataset" section).

<a name="sql"></a>a>
## Create an Azure SQL database

Readmission predictions will be stored in an Azure SQL database to facilitate their display in Power BI. Follow these steps to create the Azure SQL database:

1. Log into the Azure Portal.
1. Press the "+ New" button at the upper left of the screen.
1. Type "SQL Database" into the search box and press Enter.
1. Click on the "SQL Database" option published by Microsoft in the search results. Click the blue "Create" button that appears at right.
1. In the "SQL Database" pane that appears:
      1. Enter your unique string in the "Database name" field.
      1. Select the appropriate subscription and resource group.
      1. Click "Server" to configure required settings:
      1. Click "+ Create a new server".
         1. Enter your unique string for the server name.
         1. Enter a username and password of your choosing.
         1. Select the location of your choice.
         1. Click "Select".
      1. Click "Create".


<a name="train"></a>
## Train a Machine Learning Model with a Training Dataset

### Prepare to run the PySpark notebooks locally

You will need to complete the following steps to prepare your local Spark and Python environments to run the PySpark code in this guid:
 - [Follow these steps](https://blogs.msdn.microsoft.com/arsen/2016/07/13/accessing-azure-storage-blobs-from-spark-1-6-that-is-running-locally/) to configure your Spark environment to access your Azure storage account. Recall that your storage account name is your **unique string** and the storage account key was recorded shortly after deployment.
 - If you have not done so already, install the `azure-storage`, `pandas`, and `numpy` packages in your Python 2.7 environment.
   ```
   pip install azure-storage
   pip install numpy
   pip install pandas
   ```

<a name="dataprep"></a>
### Prepare the Training Dataset
For model training and validation, this tutorial uses a [diabetes dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes) originally produced for the 1994 AAI Spring Symposium on Artificial Intelligence in Medicine, now generously shared by Dr. Michael Kahn on the [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/).

To obtain this dataset and prepare it for model training, run the included Jupyter notebook as follows:
1. Find the notebook in your Jupyter notebooks listing and click the notebook's name to launch it. You may need to choose the appropriate kernel for a local PySpark context with Python 2.7.
1. Enter your storage account name and key in the empty string variables near the top of the notebook file.
1. Click Cell -> Run All to execute all code cells in the notebook.
1. After execution completes, close and halt the notebook.

You should now find dataset info and preparation pipeline information have been added to your blob storage account's `models` container, where they can be loaded for model training and application to newly-acquired data.

<a name="model"></a>
### Train and Evaluate the Model

To train a machine learning model to predict patient readmission and evaluate its accuracy, repeat the steps above to load and run the "2_Model_Training.py" notebook. After entering your storage account name and running all cells in the notebook, you should find that the trained model's description has been added to your blob storage account's `models` container.

After execution completes, close and halt the notebook. Note that leaving two notebooks open and running will prevent your prediction script from running. (No new SparkContext can be formed when both head nodes will be busy.)

<a name="predict"></a>
## Apply the Trained Model to Generate Predictions

To apply your trained model to the randomly-generated patient records and streaming data, run the `predict.py` script in the "Technical Deployment Guide/HDInsight Spark" folder of this git repository from your Python prompt:

```
<path_to_PySpark_2.7_binaries>/python <path_to_script>/predict.py <your unique string> <storage account key>
```

Once the run is complete, you should find predictions have been generated in the `predictions` container of your storage account. If you like, you can schedule runs of `predict.py` or manually re-run it on subsequent days to create multiple days' worth of data for visualization in Power BI.

<a name="powerbi"></a>
## Visualize the Predictions with Power BI

Once the first predictions have appeared in the `predictions` container of your storage account, follow the steps below to visualize the results in a Power BI Dashboard:

1. Use Power BI Desktop to open the `Patient Readmission Prediction Dashboard` file in the "Technical Deployment Guide/Power BI" subfolder of this repository.
1. From the Home tab, click on "Edit Queries."
1. Update the `glucoselevelsaggs`, `patientrecords`, and `predictions` queries in the "Other Queries" folder.
   1. Select all three queries and click on "Data Source Settings".
   1. In the "Data source settings" dialog box, click on "Change source".
      1. Enter your **unique string** in the "Account name or URL" field.
      1. Click "OK".
   1. In the "Data source settings" dialog box, click on "Edit Permissions".
      1. Under "Credentials", click "Edit".
      1. Paste your storage account key into the "Account key" field.
      1. Click "OK".
   1. Click "Close".
1. Click "Refresh Preview". The queries should update with the prediction information from your blob storage account.
1. Click "Close & Apply" to return to the dashboard.

You may now use the dashboard to visualize the expected savings per patient from participation in the intervention program. The expected savings is largest for patients who are very likely to undergo readmission without the intervention; the expected savings may be small or negative for patients at low risk of readmission.