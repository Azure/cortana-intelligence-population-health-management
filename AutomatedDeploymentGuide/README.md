# Population Health Management - Automated Deployment Guide  

To see the entire Population Health Management for Health care using Cortana Intelligence Suit in action without having to spin up and connect all the components manually, there is a one click deployment option available [here](https://gallery.cortanaintelligence.com/). This folder contains the post-deployment instructions for the automatic deployable Population Health Management for Health care in the Cortana Intelligence Gallery. The one-click deployment of this solution will provision a number of Azure Services in your subscription. You can view the list of services provisioned by visiting [Azure portal](https://portal.azure.com). You can also look at the architecture diagram below that shows various Azure services that will be deployed by Population Health Management for Health care Solution using Cortana Intelligence Solutions, and how they are connected to each other in the end to end solution.


## Architecture
![Solution Diagram Picture](https://cloud.githubusercontent.com/assets/16708375/24055289/5e69ddca-0b37-11e7-953e-b2e0d7758cb4.png)

All the resources listed above besides Power BI are already deployed in your subscription. The following instructions will guide you on how to monitor things that you have deployed and create visualizations in Power BI.


## Monitor Progress
Once the solution is deployed to the subscription, you can see the services deployed by clicking the resource group name on the final deployment screen in the CIS.

This will show all the resources under this resource groups on [Azure management portal](https://portal.azure.com/).

After successful deployment, the entire solution is automatically started on cloud. You can monitor the progress from the following resources.

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. A picture is worth a thousand words. Lets head over to the [visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to connect to a Real-time dataset to build reports and dashboards using your data!