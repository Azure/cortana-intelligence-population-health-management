# Population Health Management - Automated Deployment Guide  

To see the entire Population Health Management for Health care using Cortana Intelligence Suit in action without having to spin up and connect all the components manually, there is a one click deployment option available [here](https://gallery.cortanaintelligence.com/). This folder contains the post-deployment instructions for the automated deployable Population Health Management for Health care in the Cortana Intelligence Gallery. You will also see these steps outlined in the last screen at the end of a successful automated deployment along with the list of services provisioned. The architecture diagram below shows the data flow and the end-to-end pipeline.


## Architecture
![Solution Diagram Picture](../ManualDeploymentGuide/media/PHMarchitecture.PNG?raw=true)

All the resources listed above besides Power BI are already deployed in your subscription. The following instructions will guide you on how to monitor things that you have deployed and carry out some post deployment steps.


## Monitor Progress
Once the solution is deployed to the subscription, you can see the services deployed by clicking the resource group name on the final deployment screen in the CIS.

This will show all the resources under this resource groups on [Azure management portal](https://portal.azure.com/).

After successful deployment, the entire solution is automatically started on cloud. You can monitor the progress from the following resources.
 
## Post Deployment Steps
  Data is now streaming into the Azure Event Hub and the HealthCareColdPath Azure Stream Analytics job is pushing data to the gsciqs1w6yadls Azure Data Lake Store account. There are a few manual steps that are required for the whole pipeline to be completed.
 

## Authorize Stream Analytics Outputs for Hot Path

 - Go to the Azure Stream Analytics Hot Path job here 
 - Click on Outputs 
 - For the stream analytics outputs LosDataset1 and LosDataset2
 - Click on the output in the Outputs list
 - Click on Renew authorization
 - Complete authorization
 - Click Save
 - Authorize Stream Analytics Outputs for Cold Path
   
## Authorize Stream Analytics Outputs for Cold Path
  
  - Go to the Azure Stream Analytics Cold Path job here 
  - Click on Outputs
  - For the stream analytics outputs ChargesOutput, CoreOutput, SeverityOutput, and DxprOutput
  - Click on the output in the Outputs list
  - Click on Renew authorization
  - Complete authorization
  - Click Save

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. By authorizing the hot path, streaming data has started flowing into your Power BI. By authorzing the cold path, the PBI can connect to data stored in Data Lake Store for visualization. A picture is worth a thousand words. Lets head over to the [visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data!