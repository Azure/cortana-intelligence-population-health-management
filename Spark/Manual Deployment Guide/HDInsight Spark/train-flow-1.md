## Data Simulation and Model Training


Two Jupyter notebook files need to be executed to finish the task. We show two work flows: [train-flow-1](train-flow-1.md) and [train-flow-2](../AMLworkbench/train-flow-2.md) to achieve it. You must choose to follow one of them to proceed. This document shows the work flow 1.

Specifically, following tasks are performed sequentially in file 1\_ Data\_Preparation.ipynb. Please follow Section [Prepare the Training Dataset](#dataprep) for step-by-step instructions.

1. Download the source data ([diabetes dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes)) and save it in the provisioned Azure storage account.
2. In addition to existing features, generate glucose readings as a new feature.  
3. Proprocess data, including handing missing data, handing categorical features,  and generating labels.
4. Generate new patients and streaming glucose level readings as scoring data, and save into the Blob Storage. The purpose is to demonstrate how the trained model can be applied to incoming patient data in the scoring pipeline.

In Section [Train and Evaluate the Model](#model), we show step-by-step instructions for tasks performed in file 2\_ Model\_Training.ipynb. 

1. Split the preprocessed data into 80% training data and 20% testing data.
2. Train the model using the training data with RandomForest algorithm (default parameter setting).
3. Save the trained model into Azure storage account. This trained model is going to be used for scoring new patients in the scoring pipeline.
4. Produce model evaluation results using the testing data.
 


<a name="dataprep"></a>
### Prepare the Training Dataset
For model training and validation, this tutorial uses a [diabetes dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes) originally produced for the 1994 AAI Spring Symposium on Artificial Intelligence in Medicine, now generously shared by Dr. Michael Kahn on the [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/).

To obtain this dataset and prepare it for training a model, first load and run the included Jupyter notebook by following the instructions listed below:

1. Upload the notebook to your HDInsight cluster.
   1. Once the HDInsight cluster deployment completes, navigate to your resource group's overview pane and click on the HDInsight resource.
   2. In the HDInsight overview pane that appears, click on "Cluster dashboard".
   3. Click on "Jupyter Notebook". You will be prompted for the HDInsight login credentials you selected during the initial deployment.
   4. Click the "Upload" button at upper-right, and select the "1_Data_Preparation.ipynb" notebook from the "Manual Deployment Guide/HDInsight Spark" directory of your local copy of this git repository.
   5. Click the blue Upload button in the Jupyter notebooks window.
1. Find the notebook in your Jupyter notebooks listing and click the notebook's name to launch it. If prompted, choose the "PySpark" (Python 2.7) kernel.
1. Enter your storage account name and key in the empty string variables in the first editable cell of the notebook file.
1. Click Cell -> Run All to execute all the code cells within the notebook.
1. After execution completes, close and halt the notebook.

You should now find some dataset and preparation pipeline information that have been added into your blob storage account's `model` container, where they can be loaded for model training and scoring on a newly-acquired dataset.

<a name="model"></a>
### Train and Evaluate the Model

To train a machine learning model to predict patient readmission and evaluate its accuracy, repeat the steps listed above to upload and run the "2_Model_Training.ipynb" notebook. After entering your storage account name and running all the cells in the notebook, you should find that the trained model's description have been added to your blob storage account's `model` container.



> **Note:** After the execution gets completed, close and halt the notebook. 
Leaving two notebooks open and running will prevent your ADF prediction pipeline from executing, because no new SparkContext can be formed when both head nodes are busy.