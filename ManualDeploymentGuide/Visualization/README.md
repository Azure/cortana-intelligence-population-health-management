# Visualizing the Population Health Report with Power BI

After deploying the [Population Health Management Solution](https://github.com/Azure/cortana-intelligence-population-health-management), simulated patient data and predictions will begin to accumulate. This README describes the steps necessary to display and glean insights from the data using Power BI. First, you will configure a pre-existing dashboard to visualize the data created from your Azure Stream Analytics "cold path" from [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/). After uploading this dashboard to [Power BI Online](https://powerbi.microsoft.com/en-us/landing/signin/), you will add visualizations based on the real-time Azure Stream Analytics "hot path" data.

## - [Visualize Data from Data Lake Store](#cold)
## - [Visualize Data From Real-time Data Stream](#hot) 

# Data
For this solution, we have used simulated patient hospital visit records based on State Inpatient Data ([SID](https://www.hcup-us.ahrq.gov/sidoverview.jsp)) from the Healthcare Cost and Utilization Project ([HCUP](http://www.hcup-us.ahrq.gov/)). The records we produce match the HCUP [schema](https://www.hcup-us.ahrq.gov/db/state/siddist/siddistvarnote2013.jsp) to facilitate the solution's use with [real HCUP data](https://www.hcup-us.ahrq.gov/tech_assist/centdist.jsp). The solution simulates 610 patient clinical and demographic features, including age, gender, zipcode, diagnoses, procedures, charges, etc. across 23 hospitals. After processing, the solution's cumulative records are aggregated into a file named `data4visualization_latest` in the `/pbidataforPHM` subdirectory of your Azure Data Lake Store.

Because your deployment of this solution may be run only briefly (e.g. hours or days, for demo purposes), the solution does not simulate or track readmission events: instead, we provide another data file called `ReadmittanceTarget`, which contains sample readmission data. During deployment, this file was copied into the `/forphmdeploymentbyadf` subdirectory of your Azure Data Lake Store.

### ***About HCUP and SID***

The Healthcare Cost and Utilization Project (HCUP) is a group of healthcare databases that contain the the largest collection of longitudinal hospital care data in the United States. It is a national information resource for encounter-level health care data that captures information extracted from administrative data (patients' billing records) after a patient is discharged from the hospital. HCUP's State Inpatient Databases (SID) contain inpatient care records from community hospitals in each state. With forty-eight states participating, SID now encompass about 97 percent of all U.S. community hospital discharges. The SID files contain a core set of clinical and demographic information on all patients, providing a unique view of inpatient care over time. 

# [Population Health Report](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization/PopulationHealthReport)
A population health report helps healthcare providers glean insights into the population they serve and get actionable information. In this solution we have created some reports for you based on the data described above. Screenshots and brief descriptions of the reports included can be found [here](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Visualization/PopulationHealthReport).

<a name="cold"></a>
# Visualize Data from Data Lake Store

> Note:  1) Before beginning this section, you must download and install the (free) [Power BI Desktop](https://powerbi.microsoft.com/desktop) program. 2) We recommend that you start this process 2-3 hours after you deploy the solution, so that you have more data points to visualize.

Once data is flowing into you Data Lake Store, [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop) can be used to build visualizations. Power BI can directly connect to an Azure Data Lake Store as its data source, where the historical data as well as the prediction results are stored.  The goal is to visualize the historic data and length of stay predictions in near-real time as new patients get admitted to the hospital. The [provided PBI Dashboard file](https://github.com/Azure/cortana-intelligence-population-health-management/raw/master/ManualDeploymentGuide/Visualization/PopulationHealthManagement.pbix) needs to connect to two data files in Data Lake store: `data4visualization_latest.csv` and `ReadmittanceTarget.csv`. In the steps below, we will change the source of the Power BI file from local files to the csv files in Data Lake Store.

#### 1) Get the connection credentials

To connect to the data in your Azure Data Lake Store, you will need to supply Power BI Desktop with your **ADL URI**, which you can obtain as follows:

- Log into [Azure Portal](https://portal.azure.com/).
- Use the search bar at the top of the screen to search for your resource group by name.
- After clicking on your resource group in the search results, find your Data Lake Store in the resource group pane and click on it.
- In the Data Lake Store's overview pane, copy the **ADL URI**. It will look similar to [this](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/adlsuri1.PNG?raw=true):
    `adl://************.adlsdefault.azuredatalakestore.net/`. 

#### 2)	Get the query connection strings

Before you can update the sample Power BI dashboard we have supplied, you will need to generate two Power BI query connection strings to access the files in your Data Lake Store.

- Load the patient hospital visit record data into a new Power BI dashboard
    - Open the Power BI Desktop application. A new, untitled Power BI dashboard will automatically be created for you.
    - On the opening splash screen, click the "Get data" link at left.
    - In the "Get data" dialog box, select "Azure", then choose "Azure Data Lake Store". Click "Connect".
    - In the next dialog box, enter your **ADL URI** as the URL and click the "OK" button.
    - On the next screen, you will see a summary of your Data Lake Store (consisting of the folders in the root directory). Click the "Load" button at the bottom of the screen.
        After the data has been successfully loaded into Power BI, you will see that the "Fields" menu at right has been populated automatically with a [table named Query1](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbiconnect1.PNG?raw=true) that contains elements like Content, Date accessed, Date Created, etc.
    -	In the ribbon at the top of your screen, ensure that the "Home" tab is selected, then click "Edit Queries".
        In the Query Editor, you will see a table in which the first column is "Content", the second column is "Name", and so forth.
    -	Find the row in this table that contains the value "pbidataforPHM" in the "Name" column (row 3). Click on the "Table" hyperlink in the "Content" column of that row.
    -	In the next screen, click on the "Binary" hyperlink in the single-row table.
        You should now see a table containing the patient hospital visit records.
    -	On the ribbon at the top of the screen, click "Close and Apply".
        You should now see that the "Fields" menu at right contains the fields from the patient hospital visit records, i.e. the columns from `data4visualization_latest.csv` file. We will now repeat the steps above to load the readmission data.
- Load the readmission data into a new Power BI dashboard
    - Open the Power BI Desktop application. A new, untitled Power BI dashboard will automatically be created for you.
    - On the opening splash screen, click the "Get data" link at left.
    - In the "Get data" dialog box, select "Azure", then choose "Azure Data Lake Store". Click "Connect".
    - In the next dialog box, enter your **ADL URI** as the URL and click the "OK" button.
    - On the next screen, you will see a summary of your Data Lake Store (consisting of the folders in the root directory). Click the "Load" button at the bottom of the screen.
        After the data has been successfully loaded into Power BI, you will see that the "Fields" menu at right has been populated automatically with a second table named "Query2".
    -	In the ribbon at the top of your screen, ensure that the "Home" tab is selected, then click "Edit Queries".
    - Click on "Query2" in the list at left. You will again see a summary of the folders in the root directory for your Data Lake Store.
    -	Find the row in this table that contains the value "forphmdeploymentbyadf" in the "Name" column (row 2). Click on the "Table" hyperlink in the "Content" column of that row.
        In the next screen, you will see a table describing the files in the `/forphmdeploymentbyadf` subdirecory of your ADLS. 
    -	Find the row in this table that contains the value "ReadmittanceTarget.csv" in the "Name" column (row 1). Click on the "Binary" hyperlink in the "Content" column of that row.
        You should now see a table containing data relevant to readmission.
    - On the ribbon at the top of the screen, click "Close and Apply".
        You should now see that "Query2" under the "Fields" menu at right contains the readmission fields, i.e. the columns from `ReadmittanceTarget.csv` file.   
- Record the query strings
  -	Under Content column click on *Table* in the *row with Name forphmdeploymentbyadf*.
  -	In the next screen under Content Column click on Binary in the *row with Name ReadmittanceTarget.csv* in the Name columns.
  -	In the next screen you will see the actual data.  
  -	From the Home ribbon, click Close and Apply. Once the query is updated, the Fields tab the table Query2 will show the new fields available for visualization. These will be the columns from ReadmittanceTarget.csv file.
  -	Your data is now available in a format that you can use to create visualizations. 
  -	Now that the Power BI is connected to the two data files in Data Lake Store, click on *Edit Queries*, select Query1 and then click on *Advanced Editor* in the Home Ribbon. An editor will pop out with the connection query. It should look similar to [this](https://github.com/Azure/cortana-intelligence-population-health-management/raw/master/ManualDeploymentGuide/media/connectionquery1.txt). Copy the contents of the editor in a notepad. We will use it to replace the contents of the Advanced Editor in the provided .pbix file in order to change the data source form a local csv to the csv file in ADLS.
  -	Close the advanced editor and select Query2 this time and then click on *Advanced Editor* in the Home Ribbon. An editor will pop out with the connection query for the second table (similar to [this](https://github.com/Azure/cortana-intelligence-population-health-management/raw/master/ManualDeploymentGuide/media/connectionquery2.txt)). Copy the contents of the editor in a notepad.
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

The Power BI Dashboard created above displays statistics on the cumulative set of patient visit records processed using Azure Data Factory. Here, we show how you can display real-time data in Power BI dashboards to monitor very recent trends. This process uses the "Hot Path" Azure Stream Analytics output that you produced during deployment.

- Begin creating a new report in Power BI:
   - Login on [Power BI online](http://www.powerbi.com).
   - After logging in, locate and click "My Workspace" on the left-hand menu.
   - Click the "+ Create" button in the upper-right corner of the screen, and select "Reports" from the drop-down menu.
   - In the "Create Report" dialog box that appears, select the dataset named `hotpathcore` created by your ASA hot path, then click the "Create" button.
- Create a bar chart showing the total number of patients admitted by admission type (`atype`):
   - In the "Visualizations" pane at the right-hand side of the screen, click on the "stacked column chart" button (top row, second from the left) to add a new chart to the report.
   - With this chart selected,
      - Drag `atype` (under "Fields") into the "Drag data fields here" box under the "Axis" setting. 
      - Drag `visitlink` (under "Fields") into the "Drag data fields here" box under the "Value" setting.  
- Create a bar chart showing the number of patients admitted in each time interval:
   - In the "Visualizations" pane at the right-hand side of the screen, click on the "stacked column chart" button (top row, second from the left) to add a new chart to the report.
   - With this chart selected,
      - Drag `recordtime` (under "Fields") into the "Drag data fields here" box under the "Axis" setting. 
      - Drag `visitlink` (under "Fields") into the "Drag data fields here" box under the "Value" setting.
- Publish the report to a dashboard for live updates
   - Click on "File -> Save", and save the report with the name `hotpathreport`.
   - Click the "Pin Live Page" button in the upper-right corner.
   - Pin the report to the dashboard you created in the "Visualize Data from Data Lake Store" section.
   - Refresh while viewing the dashboard to update the visuals with real-time data.
