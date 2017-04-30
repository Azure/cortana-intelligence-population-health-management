# Population Health Report with Power BI

At the end of deployment (whether manual or automatic), we want to visualize the insights from the data and the results of the predictions. Below you will find instructions on how to connect your Power BI to the data in your Data Lake Store and also to your real time stream through Azure Stream Analytics. We have provided a power BI file with an example Population Health report and will guide you though creating some visuals and publishing a dashboard.

# Data
For this solution we have used data based on Healthcare Cost and Utilization Project ([HCUP](http://www.hcup-us.ahrq.gov/)) state inpatient data ([SID](https://www.hcup-us.ahrq.gov/sidoverview.jsp)). The [schema](https://www.hcup-us.ahrq.gov/db/state/siddist/siddistvarnote2013.jsp) of the data used for this solution follows the HCUP schema. It contains clinical and nonclinical information on all patients regardless of payer. The schema included socio-economic demographic data such as age, gender, income, zip code, payer type, information on admission and discharge, various diagnosis, procedures, charges etc., a total of about six hundred columns. 

### About HCUP

HCUP is a group of related databases that captures information extracted from administrative data (billing records) after a patient is discharged from the hospital. 

# Population Health Report
A population health report lets the health care providers get an insight into the population they server and get actionable intelligence. In this solution we have created some reports for based on data described above. Some of the reports created are below.


# Visualize Data from Data Lake Store

> Note:  1) In this step, the prerequisite is to download and install the free software [Power BI desktop](https://powerbi.microsoft.com/desktop). 2) We recommend you start this process 2-3 hours after you deploy the solution so that you have more data points to visualize.

Once data is flowing into you Data Lake Store, [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop) can be used to build visualizations from the historical data. Power BI can directly connect to an Azure Data Lake Store as its data source, where the prediction results are stored.  The goal is to visualize the historic data and length of stay predictions in near real time as the patients get admitted to the hospital .

#### 1) Get the credentials.

  You can get your database credentials to connect to your ADLS

#### 2)	Update the data source of the Power BI file

  -  Make sure you have installed the latest version of [Power BI desktop](https://powerbi.microsoft.com/desktop).

  -	Download the example pbix file from here and open it. **Note:** If you see an error massage, please make sure you have installed the latest version of Power BI Desktop.

  - On the top of the file, click **‘Edit Queries’** drop down menu. Then choose **'Data Source Settings'**.
  ![](Figures/PowerBI-7.png)

  - In the pop out window,...

  - When you are asked to enter the user name and password, make sure you choose **'Database'** option, then enter the username and password that you choose when you setting up the adls.

  - On the top of the screen, you will see a message. Click **'Apply Changes'** and now the dashboard is updated to connect to your storage. In the backend, model is scheduled to be refreshed every 1 hour. You can click **'Refresh'** button on the top to get the latest visualization as time moving forward.

#### 3) [Optional] Publish the dashboard to [Power BIonline](http://www.powerbi.com/)
  Note that this step needs a Power BI account (or Office 365 account).
  - Click **"Publish"** on the top panel. Choose **'My Workspace'** and few seconds later a window appears displaying "Publishing succeeded".

  - Click the link on the screen to open it in a browser. On the left panel, go to the **Dataset** section, right click the dataset *'xxx'*, choose **Dataset Settings**. In the pop out window, click **Enter credentials** and enter your database credentials by following the instructions. To find detailed instructions, please see [Publish from Power BI Desktop](https://support.powerbi.com/knowledgebase/articles/461278-publish-from-power-bi-desktop).

  - Now you can see new items showing under 'Reports' and 'Datasets'. To create a new dashboard: click the **'+'** sign next to the
    **Dashboards** section on the left pane. Enter the name "PHM Demo" for this new dashboard.

  - Once you open the report, click   ![Pin](Figures/PowerBI-4.png) to pin all the visualizations to your dashboard. To find detailed instructions, see [Pin a tile to a Power BI dashboard from a report](https://support.powerbi.com/knowledgebase/articles/430323-pin-a-tile-to-a-power-bi-dashboard-from-a-report). Here is an example of the dashboard.

      ![DashboardExample](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/PHMmainpage.PNG?raw=true)


# Visualize Data From Real-time Data Stream

> Note: A [Power BI online](http://www.powerbi.com/) account is required to perform the following steps. If you don't have an account, you can [create one here](https://powerbi.microsoft.com/pricing).

The essential goal of this part is to get real time overview of the population being admitted. Power BI can connect to a real-time data stream through Azure Stream Analytics. In this section we will show you how to create a real-time dashboard through connecting Azure Stream Analytics queries to Power BI

Event Hubs collects real time data from hospitals.
Stream Analytics aggregates the streaming data and makes it available for visualization.
Power BI visualizes the real-time population view as well as the predicted LOS results.
The streaming data reached Azure Event Hub
We use Azure Stream Analytics to process the data and provide near real-time analytics on the input stream from the event hub and directly publish to Power BI for visualization.

### Setup Real-time Power BI
#### 1) Login on [Power BI online](http://www.powerbi.com)

-   On the left panel Datasets section in My Workspace, you should be able to see a new dataset showing on the left panel of Power BI. This is the streaming data you pushed from Azure Stream Analytics in the previous step.

-   Make sure the ***Visualizations*** pane is open and is shown on the
    right side of the screen.

#### 2) Create a visualization on PowerBI online
With Power BI, you are enabled to create many kinds of visualizations for your business needs. We will use this example to show you how to create the "patients by payer/age" real-time line chart tile.

-	Click dataset **core dataset** on the left panel Datasets section.

-	Click **"Line Chart"** icon.![LineChart](Figures/PowerBI-3.png)

-	Click CoreStreamData in **Fields** panel.

-	Click **“col1”** and make sure it shows under "Axis". Click **“col2”** and make sure it shows under "Values".

-	Click **'Save'** on the top and name the report as “xxDataReport”. The report named “xxDataReport” will be shown in Reports section in the Navigator pane on left.

-	Click **“Pin Visual”**![](Figures/PowerBI-4.png) icon on top right corner of this line chart, a "Pin to Dashboard" window may show up for you to choose a dashboard. Please select "xxDataReport", then click "Pin".

- Once the visualization is pinned to dashboard, it will automatically refresh when Power BI receive new data from stream analytics job.






