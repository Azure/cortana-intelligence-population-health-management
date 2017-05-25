# Instructions for one time copy from Azure Blob to Data Lake store with Azure Data Factory



###  After successfully creating Azure Data Factory in our subscription, we will set up a one time copy activity from Blob to Data Lake Store. We will copy resources to the folder **forphmdeploymentadf** in Data Lake Store from the container **forphmdeploymentadf** in our storage account.
  
  - Navigate back to the resource group blade and select the ***healthcareadf*** data factory.
  - Click on Copy data 
  ![Step 1](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy1.PNG?token=AKE1nbmIVbNWtpC9CbDbemOOOMpJsJ2Oks5ZLi5OwA%3D%3D)
  - Enter a Task name and select *Run once now*
  ![Step 2](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy2.PNG?token=AKE1nZ9ocDGyJ4pSN99KHd30fOj-8rOiks5ZLjB9wA%3D%3D)
  - Select Azure Blob Storage as Data Source
  ![Step 3](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy3.PNG?token=AKE1nRkBRXvoc-znkOhfyZrZa6XayqQHks5ZLjDmwA%3D%3D)
  - Enter a Connection name and select *From Azure subscriptions* in Account selection method. From the drop downs select your subscription name and storage account name 
  ![Step 4](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy4.PNG?token=AKE1nexFApaMMw9pioLvXSf9OBzxD91Cks5ZLjD9wA%3D%3D)
  - In the next step select **forphmdeploymentadf** folder as source. This container was created earlier and populated with files using AzCopy. Click on **Choose**.
  ![Step 5](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy5.PNG?token=AKE1nVvfd5muoQwWjwz4hrpcuBv5OxXTks5ZLjEiwA%3D%3D)
  - Check *Binary copy* in next screen.
  ![Step 6](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy6.PNG?token=AKE1nUxB4SIJ6Vspo8TuGTgvEeUsSSsBks5ZLjE4wA%3D%3D)
  - For destination data source select Azure Data lake Store
  ![Step 7](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy7.PNG?token=AKE1nb8tILMiVtMpZ5Qa6rGnrfWTWDZcks5ZLjFbwA%3D%3D)
  - Specify Data Lake Store connection and choose Authentication Type *OAuth*
   ![Step 8](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy8.PNG?token=AKE1nciIBkMoLohutnOMt7iIQFB_AJCBks5ZLjGwwA%3D%3D)
  - For output folder *select* **forphmdeploymentbyadf** and click Next
   ![Step 9](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy9.PNG?token=AKE1naIjc4JwcE2-YJSv0_AbtKXew039ks5ZLjHnwA%3D%3D)
  - You will be presented a  summary. Before clicking Next, click on *Authorize*
   ![Step 10](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy10.PNG?token=AKE1neZJbfZpSCM-otdoVRWcQ-qKPKG-ks5ZLjHLwA%3D%3D)
  - Enter your credentials
   ![Step 11](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy11.PNG?token=AKE1nYvpFGOGha_GT_odPkret7CdP_Njks5ZLjH9wA%3D%3D)
  - The deployment will take a minute or so to complete.
   ![Step 12](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy12.PNG?token=AKE1nSvl51ZbDHzarbse-h2LWutjPibaks5ZLjITwA%3D%3D)
  - Navigate back to your Data lake Store and select folder *forphmdeploymentadf*. You should see it populated with files from azure storage container.
   ![Step 13](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/adfcopy13.PNG?token=AKE1neNJGRsQcglIG5yQG_NjIdLaESqvks5ZLjcRwA%3D%3D)
  
