# Population Health Report with Power BI

At the end of deployment (whether manual or automatic), we want to visualize the insights from the data and the results of the predictions. Below you will find instructions on how to connect your Power BI to the data in your Data Lake Store and also to your real time stream through Azure Stream Analytics. We have provided a power BI file with an example Population Health report and will guide you though creating some visuals and publishing a dashboard.

## - [Visualize Data from Data Lake Store](#cold)
## - [Visualize Data From Real-time Data Stream](#hot) 

# Data
For this solution we have used simulated data based on State Inpatient Data ([SID](https://www.hcup-us.ahrq.gov/sidoverview.jsp)) from Healthcare Cost and Utilization Project ([HCUP](http://www.hcup-us.ahrq.gov/)). The [schema](https://www.hcup-us.ahrq.gov/db/state/siddist/siddistvarnote2013.jsp) of the data used for this solution follows the HCUP schema. The data contains clinical and nonclinical information on all patients. It includes the socio-economic demographic information such as age, gender, income, zip code, payer type, information on admission and discharge, various diagnosis, procedures, charges etc., a total of about six hundred  and ten columns. For this solution we simulated one hundred and thirty five of these columns but retained the remaining columns for completeness and to facilitate ease of transporting the codes to [real HCUP data!](https://www.hcup-us.ahrq.gov/tech_assist/centdist.jsp) The data is simulated for 23 hospitals with about a million encounter level records. We also provide another data file called 'ReadmittanceTarget' which contains metrics to be followed by a hospital to track Readmission Rate.

### ***About HCUP and SID***

The Healthcare Cost and Utilization Project (HCUP) is a group of healthcare databases that contain the the largest collection of longitudinal hospital care data in the United States. It is a national information resource for encounter-level health care data. It captures information extracted from administrative data (patients' billing records) after a patient is discharged from the hospital. The State Inpatient Databases (SID) are part of this family of databases and contain inpatient care records from community hospitals in that State. With forty-eight States participating in the SID, it now encompass about 97 percent of all U.S. community hospital discharges. The SID files contain a core set of clinical and nonclinical information on all patients, regardless of payer, providing a unique view of inpatient care over time. 

# [Population Health Report](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization/PopulationHealthReport)
A population health report lets the health care providers get an insight into the population they server and get actionable intelligence. In this solution we have created some reports for you based on data described above. Some of the reports created with a brief description of insights can be found [here](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization/PopulationHealthReport).

<a name="cold"></a>
# Visualize Data from Data Lake Store

> Note:  1) In this step, the prerequisite is to download and install the free software [Power BI desktop](https://powerbi.microsoft.com/desktop). 2) We recommend you start this process 2-3 hours after you deploy the solution so that you have more data points to visualize.

Once data is flowing into you Data Lake Store, [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop) can be used to build visualizations. Power BI can directly connect to an Azure Data Lake Store as its data source, where the historical data as well as the prediction results are stored.  The goal is to visualize the historic data and length of stay predictions in near real time as new patients get admitted to the hospital. The provided PBI file needs to connect to two data files in Data Lake store: data4visualization_latest.csv and ReadmittanceTarget.csv. In the steps below we will change the source of the Power BI file from local to the csv files in Data  Lake Store.

#### 1) Get the credentials.

  - Through Azure portal, navigate to your Data Lake Store and copy the **ADL URI**. The uri looks [like](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adlsuri1.PNG?token=AKE1nUk2pot2YgxNXQ_GjDSeOIdQx_xDks5ZLy1awA%3D%3D) adl://************.adlsdefault.azuredatalakestore.net/. 

#### 2)	Get the query connection strings

  -  We will get the connection query by connecting a new Power BI desktop file to our two csv files in Data Lake store. Open  a **new** Power BI desktop file and click on Get Data -> Azure -> Azure Data Lake Store -> Connect. You will be prompted to enter Azure Data Lake Store URL. Enter the **ADL URI** collected in step 1. You will be prompted to sign in. Enter your credentials and click Connect. More on connecting PowerBI to Data Lake Store [here](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-power-bi).
  -	You will see a list of all the folders in your Data Lake store. Click **Load**. 
  -	After the data has been successfully loaded into Power BI, you will see under Fields tab on the right, a table (data source) Query1 appear with fields [like](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbiconnect1.PNG?token=AKE1nfCbzixVTKDoP29lxwewzo3O1tPBks5ZL8fewA%3D%3D) Content, Date accessed, Date Created etc.
  -	From the Home ribbon, click Edit Queries. In the Query Editor, you will see the first column as Content and second column as Name.
  -	Under Content column *click on Table* in the *row with pbidataforPHM* in the Name column.
  -	In the next screen under Content Column *click on Binary*. (You will see data4visualization_latest.csv under Name column)
  -	In the next screen you will see the actual data.  
  -	From the Home ribbon, click Close and Apply. Once the query is updated, the Fields tab the table Query1 will show the new fields available for visualization. These will be the columns from data4visualization_latest.csv file.
  -	Your data is now available in a format that you can use to create visualizations. 
  -	Next we will will connect to the second data source 'ReadmittanceTarget.csv' in our Data Lake Store
  -	Click on Get Data -> ..More -> Azure -> Azure Data Lake Store -> Connect	
  -	You will be prompted to enter Azure Data Lake Store URL. Enter the **ADL URI** collected in step 1. 
  -	In the next screen you will again see a list of all the folders in your Data Lake store. Click Load.
  -	After the data has been successfully loaded into Power BI, you will see under Fields tab on the right, a second table (data source) Query2 appear with fields like Content, Date accessed, Date Created etc. 
  -	Click on Edit Queries
  -	Select Query2 
  -	Under Content column click on *Table* in the *row with Name forphmdeploymentbyadf*.
  -	In the next screen under Content Column click on Binary in the *row with Name ReadmittanceTarget.csv* in the Name columns.
  -	In the next screen you will see the actual data.  
  -	From the Home ribbon, click Close and Apply. Once the query is updated, the Fields tab the table Query2 will show the new fields available for visualization. These will be the columns from ReadmittanceTarget.csv file.
  -	Your data is now available in a format that you can use to create visualizations. 
  -	Now that the Power BI is connected to the two data files in Data Lake Store, click on *Edit Queries*, select Query1 and then click on *Advanced Editor* in the Home Ribbon. An editor will pop out with the connection query. It should look similar to [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/connectionquery1.txt?token=AKE1nUWIPrvacgdulv1rXjv7rYGbon62ks5ZL8K5wA%3D%3D). Copy the contents of the editor in a notepad. We will use it to replace the contents of the Advanced Editor in the provided .pbix file in order to change the data source form a local csv to the csv file in ADLS.
  -	Close the advanced editor and select Query2 this time and then click on *Advanced Editor* in the Home Ribbon. An editor will pop out with the connection query for the second table (similar to [this](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/connectionquery2.txt?token=AKE1nS1DjXoLYeXzO7MXMgZCjX7d8hQBks5ZL8NewA%3D%3D)). Copy the contents of the editor in a notepad.
  -	With the two connection queries collected in a notepad, we can close this Power BI file now.
  
#### 3)	Update the data source of the Power BI file

  -  Download the example pbix file 'PopulationHealthManagement.pbix' from [here](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization) and open it. **Note:** If you see an error massage, please make sure you have installed the latest version of [Power BI Desktop](https://powerbi.microsoft.com/desktop). 
  -	Click on *Edit Queries*.
  -	Select 'data4PBI_simulated' and click on Advanced Editor
  -	Replace the content in the editor with what you copied in your notepad earlier for data4visualization_latest.csv
  -	Close the editor.
  -	Next select 'ReadmittanceTarget' and click *Edit Queries*.
  -	Replace the content in the editor with what you copied in your notepad earlier for ReadmittanceTarget.csv.
  -	Close the editor and click *Close & Apply* in the Home Ribbon.
  -	The data sources will update and point to the files in your Data Lake Store.
  -	To confirm click on Edit Queries, select data4PBI_simulated and click on Data source settings in the Home Ribbon.
  - You should see the ADL URI you collected in Step 1.
  - Do the same check for Readmittance Target
  - Now the PBI file is connected to data sources in Data Lake Store.
  - In the backend, model is scheduled to be refreshed every 1 hour. You can click **'Refresh'** button on the top to get the latest visualization as time moving forward.

#### 4) Publish the dashboard to [Power BIonline](http://www.powerbi.com/)
  Note that this step needs a Power BI account (or Office 365 account).

  - Click **"Publish"** on the top panel. You will be prompted to sign into your Power BI account. Sign in with your work or school account. Next you will be prompted to select a destination. Choose **'My Workspace'**. It will take about a minute to publish at the end of which you will see a  "Success!" message with a link to open your published report in Power BI. More on how to publish [here](https://powerbi.microsoft.com/en-us/documentation/powerbi-desktop-upload-desktop-files/).

  - Click this link to view your Power BI desktop file in a browser. You will be prompted to enter your Power BI online credentials. Once you successfully log in you will be able to see all the reports from your Power BI desktop file in the browser.  

  - Next we want to pin individual visualizations from some of our reports into a dashboard. Select a visualization from a report that you want in your dashboard and click on the thumbtack symbol at the top left that says 'Pin Visual' on hover. You will be prompted to select an existing dashboard or create a new one. Lets create a new dashboard. You will need to enter a name for your dashboard, we will call it "PHM demo". When you press enter you will see a notification that your visualization has been pinned to your dashboard with a link to go to dashboard. Click on the link to go to your dashboard. More on dashboards [here](https://powerbi.microsoft.com/en-us/guided-learning/powerbi-learning-4-2-create-configure-dashboards/).
 

  - Power BI Q&A enables users to ask natural language questions and get answer in the form of visuals or reports automatically created with the data that best answers their question.

<a name="hot"></a>
# Visualize Data From Real-time Data Stream

> Note: A [Power BI online](http://www.powerbi.com/) account is required to perform the following steps. If you don't have an account, you can [create one here](https://powerbi.microsoft.com/pricing).

The essential goal of this part is to get real time overview of the population being admitted to different hospitals. To carry out the steps below you must have successfully completed the 'Hot Path' steps (for both manual and automated deployment) to connect Power BI to your real-time data stream through Azure Stream Analytics.  


#### 1) Login on [Power BI online](http://www.powerbi.com) 

  - On the left panel Datasets section in My Workspace, you should be able to see a new dataset *hotpathcore* showing on the left panel of Power BI. This is the streaming data you pushed from Azure Stream Analytics.
  - Make sure the ***Visualizations*** pane is open and is shown on the right side of the screen.

  

#### 2) Create a visualization on PowerBI online
With Power BI, you are enabled to create many kinds of visualizations for your business needs. We will use this example to show you how to create a visual for the "total patients admitted  by admit type" 

  -	Click dataset **hotpathcore** on the left panel Datasets section.

  -	Click **"Stacked Column Chart"** icon.

  -	Click **“ATYPE”** and make sure it shows under "Axis". Click **“VisitLink”** and make sure it shows under "Values". Select 'Count' and Show value as 'Percent pf grand total'

  -	Click **'Save'** on the top and name the report as “PHMreport”. The report named “PHMreport” will be shown in Reports section in the Navigator pane on left.

  -	Click **“Pin Visual”** icon on top right corner of this line chart, a "Pin to Dashboard" window may show up for you to choose a dashboard. Please select the dashboard "PHM demo" that we created earlier, then click "Pin".

  - Once the visualization is pinned to dashboard, it will automatically refresh when Power BI receives new data from stream analytics job.





