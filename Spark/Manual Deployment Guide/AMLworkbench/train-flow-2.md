## Data Simulation and Model Training


We show two work flows: [train-flow-1](../HDInsight%20Spark/train-flow-1.md) and train-[flow-2](train-flow-2.md) to achieve this task. You must choose to follow one of them to proceed. Each work flow includes two Jupyter notebook files for preparing the training data, and for training the model, respectively. 

This document shows the train-work-flow-2. Comparing to train-flow-1, this scenario shows how to use Azure ML Workbench to scale out tuning of hyperparameters of machine learning algorithms. We show how to configure and use remote docker and Spark cluster as an execution backend for tuning hyperparameters. Please follow Section [Hands on Instructions](#steps) for step-by-step instructions.


Specifically, following tasks are performed sequentially in file 1\_Data\_Preparation\_AML.ipynb from `AMLworkbench` folder. 

1. Download the source data ([diabetes dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes)) and save it in the provisioned Azure storage account.
2. In addition to existing features, generate glucose readings as a new feature.  
3. Preprocess data, including handing missing data, handing categorical features,  and generating labels.
4. Generate new patients and streaming glucose level readings as scoring data, and save into the Blob Storage. The purpose is to demonstrate how the trained model can be applied to incoming patient data in the scoring pipeline.

Following tasks are performed in file 2\_ Model\_Training\_AML.ipynb `AMLworkbench` folder. 

1. Split the preprocessed data into 80% training data and 20% testing data.
2. Train the model using the training data with RandomForest algorithm. We choose the best model by performing hyper-parameter tuning combined with cross validation. 
3. Save the trained model into Azure storage account. This trained model is going to be used for scoring new patients in the scoring pipeline.
4. Produce model evaluation results using the testing data.
 

<a name="steps"></a>
## Hands on Instructions

1. An installed copy of [Azure ML Workbench](https://docs.microsoft.com/en-us/azure/machine-learning/preview/overview-what-is-azure-ml) following the [quick start installation guide](https://docs.microsoft.com/en-us/azure/machine-learning/preview/quickstart-installation) to install the program and create a workspace.
1. Launch Azure ML Workbench
1. Create a new project. We call this newly created Azure ML Workbench project folder as `your project` folder.
1. Copy two notebook files: 1\_Data\_Preparation\_AML.ipynb and 2\_ Model\_Training\_AML.ipynb from `AMLworkbench` folder into `your project` folder.
1. Within Azure ML workbench GUI, click *File* and then click *Open Command Prompt*. In the appearing CLI console run following command. When the command is executed successfully, two files *myspark.compute* and *myspark.runconfig* will be generated in the `aml_config` folder of `your project` folder.
    
        az ml computetarget attach --name myspark --address <cluster name>-ssh.azurehdinsight.net  --username sshuser --password <password> --type cluster

	> In above command, *myspark* indicates the name created by the user for this remote spark cluster compute environment. The user also need to replace <cluster name\> as the the name of the provisioned spark cluster. For example, when the spark cluster name is readmitguideyz, the correpsondig parameter is "readmitguideyz-ssh.azurehdinsight.net". *sshuser* indicates the cluster's SSH user name. The default value of SSH user name is `sshuser`, unless you changed it during provisioning of the cluster. Please also replace <password\> with the SSH password.  

1. In the Azure ML workbench GUI, locate and open file myspark.compute in the *aml_config *folder of `your project` folder. 
1. Set property "yarnDeployMode" to "client". The purpose is to enable create a Docker container in the Spark cluster. 

		yarnDeployMode: client
1. In previously opened CLI console, run following command. It will take a couple minutes to finish. The command only need to be executed once for setting up the Docker container in the spark cluster. 
       
   		az ml experiment prepare -c myspark

1. Launch Jupyter notebook server from CLI console by executing following command. A browser page *HOME* will show up and it lists files within the project folder. Both 1\_Data\_Preparation\_AML.ipynb and 2\_ Model\_Training\_AML.ipynb are listed.
  
        	az ml notebook start

1. Repeat following steps for notebooks 1\_Data\_Preparation\_AML.ipynb and 2\_ Model\_Training\_AML.ipynb.	

	1.  In the browser page *HOME*, click the notebook to run and it will be opened in a new browser tab. Make sure to set <your\_project\_name *myspark*> as the kernel.
		
		> The kernel will be busy (the circle on top right of the notebook page is filled with dark gray) for a while. Meanwhile the job in the Jobs pane within Azure ML workbench (click `>>` sign on the top right corner if Jobs pane is not showing) shows "starting...". When the kernel is idle (the circle on top right of the notebook page is filled with white), the job in the Job pane in the workbench shows "running...". By now it is ready to run the scripts in the notebook.

	1. Fill in the `account_name` and `account_key` information of the provisioned Azure Storage account in the first cell, if any.
	1. Click Cell -> Run All to execute all the code cells within the notebook.
	1. After execution completes, close and halt the notebook. To halt the notebook, check the running notebook in the browser page *HOME*, and click shutdown. 
		
		> **Note:** After the execution gets completed, close and halt the notebook. Leaving two notebooks open and running will prevent your ADF prediction pipeline from executing, because no new SparkContext can be formed when both head nodes are busy. Momentarily the job in the Jobs pane within Azure ML workbench shows "Completed".


### Monitoring the Job Status

After successfully executing 1\_Data\_Preparation\_AML.ipynb,  you should now find some dataset and preparation pipeline information that have been added into your blob storage account's `model` container, where they can be loaded for model training and scoring on a newly-acquired dataset. Specifically, a container `preprocess`  with file diabetic\_date.csv in it will be created. In the container `model`, *si_pipe_model*, *oh_pipe_model*, *si_label*, and *trainingdata* folders/files will be created. Finally, a container `patientrecords` with new patient records in it will be created.

After successfully executing 2\_ Model\_Training\_AML.ipynb, the folder/file `model` will be created within container `model` in the Blob storage account.


Under the circumstance when the Jupiter notebook kernel being busy for very long time (e.g. more then half an hour), you are advised to check the job running status in the spark cluster. When the job in Azure ML workbench shows "running", correspondingly you will be able to see a job with name *Azure ML Experiment* showing in the *running application* page of the HDI hadoop cluster's page. 

1. In Azure portal, open the overview page of provisioned the HDInsight spark cluster
1. Click *Cluster dashboard* and then click "HDInsight cluster dashboard", then a new web page will show up.
2. Log in the page.
	> If you see an "Missing authentication token" error showing up, follow this link [Ambari Login Error - Missing authentication token](https://social.msdn.microsoft.com/Forums/en-US/015e19c2-54f7-4286-8ce2-071b5f6b0d36/ambari-login-erro-missing-authentication-token?forum=hdinsight) to resolve the problem.







