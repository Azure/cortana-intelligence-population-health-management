# Population Health Report with Power BI

At the end of deployment (whether manual or automatic), we want to visualize the insights from the data and the results of the predictions. Below you will find instructions on how to connect your Power BI to the data in your Data Lake Store and also to your real time stream through Azure Stream Analytics. We have provided a power BI file with an example Population Health report and will guide you though creating some visuals and publishing a dashboard.

# Visualize Data from Data Lake Store

> Note:  1) In this step, the prerequisite is to download and install the free software [Power BI desktop](https://powerbi.microsoft.com/desktop). 2) We recommend you start this process 2-3 hours after you deploy the solution so that you have more data points to visualize.

Once data is flowing into you Data Lake Store, [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop) can be used to build visualizations from the historical data. Power BI can directly connect to an Azure Data Lake Store as its data source, where the prediction results are stored.  The goal is to visualize the length of stay predictions in near real time as the patients get admitted to the hospital .

#### 1) Get the credentials.

  You can get your database credentials to connect to your ADLS

#### 2)	Update the data source of the Power BI file

  -  Make sure you have installed the latest version of [Power BI desktop](https://powerbi.microsoft.com/desktop).

  -	Download the example pbix file from here and open it. **Note:** If you see an error massage, please make sure you have installed the latest version of Power BI Desktop.

  - On the top of the file, click **‘Edit Queries’** drop down menu. Then choose **'Data Source Settings'**.
  ![](Figures/PowerBI-7.png)

  - In the pop out window, click **'Change Source'**, then replace the **"Server"** and **"Database"** with	your own server and database names and click **"OK"**. For server
	name, make sure you specify the port 1433 in the end of your server string
	(**YourSolutionName.database.windows.net, 1433**). After you finish editing, close the 'Data Source Settings' window.

  - When you are asked to enter the user name and password, make sure you choose **'Database'** option, then enter the username and password that you choose when you setting up the SQL database.

  - On the top of the screen, you will see a message. Click **'Apply Changes'** and now the dashboard is updated to connect to your database. In the backend, model is scheduled to be refreshed every 1 hour. You can click **'Refresh'** button on the top to get the latest visualization as time moving forward.

#### 3) [Optional] Publish the dashboard to [Power BIonline](http://www.powerbi.com/)
  Note that this step needs a Power BI account (or Office 365 account).
  - Click **"Publish"** on the top panel. Choose **'My Workspace'** and few seconds later a window appears displaying "Publishing succeeded".

  - Click the link on the screen to open it in a browser. On the left panel, go to the **Dataset** section, right click the dataset *'EnergyDemandForecastSolution'*, choose **Dataset Settings**. In the pop out window, click **Enter credentials** and enter your database credentials by following the instructions. To find detailed instructions, please see [Publish from Power BI Desktop](https://support.powerbi.com/knowledgebase/articles/461278-publish-from-power-bi-desktop).

  - Now you can see new items showing under 'Reports' and 'Datasets'. To create a new dashboard: click the **'+'** sign next to the
    **Dashboards** section on the left pane. Enter the name "Energy Demand Forecasting Demo" for this new dashboard.

  - Once you open the report, click   ![Pin](Figures/PowerBI-4.png) to pin all the visualizations to your dashboard. To find detailed instructions, see [Pin a tile to a Power BI dashboard from a report](https://support.powerbi.com/knowledgebase/articles/430323-pin-a-tile-to-a-power-bi-dashboard-from-a-report). Here is an example of the dashboard.

      ![DashboardExample](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/PHMmainpage.PNG?raw=true)


# Visualize Data From Real-time Data Stream

> Note: A [Power BI online](http://www.powerbi.com/) account is required to perform the following steps. If you don't have an account, you can [create one here](https://powerbi.microsoft.com/pricing).

The essential goal of this part is to get real time overview of the population being admitted. Power BI can connect to a real-time data stream through Azure Stream Analytics.




