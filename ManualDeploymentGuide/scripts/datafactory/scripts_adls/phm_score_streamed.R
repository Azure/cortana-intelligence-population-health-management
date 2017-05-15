############################################################
# Summary: Performs ADLA specific jobs to obtain the prediction of patients' Length of Stay (LOS) in hospitals using simulated data that is similar to 
#          publicly available data(https://www.hcup-us.ahrq.gov/databases.jsp) from the  Healthcare Cost and Utilization Project
#          ([HCUP](https://www.hcup-us.ahrq.gov/)). 
#	   
#          ADLA specific operations performed here:
#          - schema (name and data type) enforcing
#          - USQL input and output management (using variables 'inputFromUSQL' and 'outputToUSQL', whose names are reserved through USQL R UDO extension definition)
#          - R code for feature engineering and Scoring is applied at scale though ADLA.
#         
#          LOS prediction is done by applying HCUP specific Feature Engineering and scoring operations to 
#          input 'streamed data' (about 3e3 records per 5 minutes) consisting of simulated patient data with schema identical to HCUP data.
#          HCUP data specific operations are defined in sourced phmLOSPrediction_HCUPDataProcessing.R script functions.
#          
# Author:  George Iordanescu ghiordan@microsoft.com
############################################################

############################################################
#    function setColumnNamesAndTypes()
#    In big data scenarios, data proper is separated from schema. We use USQL as a mere vehicle for scoring at scale, and all processing is done in R.
#    This is accomplished by distributing data in USQL using generic string type, and depoying schema info to each worker and enforcing it in R. 
############################################################

setColumnNamesAndTypes <- function(dfWithoutColumnNames, colClassFilename) {
  # colClasses info in colClassFilename comes in 2 col format, so we reshape it to a df with names and values
  # Values are class type, e.g. character, integer, logical
  colClasses           <- read.csv(colClassFilename)
  colClasses           <- as.data.frame(t(colClasses))
  colnames(colClasses) <- as.character(unlist(colClasses[c("colname"), ]))
  colClasses           <- colClasses[c("data_type"), ]# drop 2nd row with columns names
  
  # set df col names
  colnames(dfWithoutColumnNames) <- colnames(colClasses)
  
  #set df col class/types
  colClasses <- unlist(colClasses)
    for (crtColumnIndex in seq_len(dim(dfWithoutColumnNames)[2])) {
      crtClass <- as.character(colClasses[crtColumnIndex])
      crtFun <- match.fun(paste("as", crtClass, sep = "."))
      dfWithoutColumnNames[[(colnames(dfWithoutColumnNames))[crtColumnIndex]]] <-
        crtFun(dfWithoutColumnNames[[(colnames(dfWithoutColumnNames))[crtColumnIndex]]])
    }
  
  dfWithoutColumnNames
}

############################################################
#      End of function
############################################################

# in ADLA, partitioned data comes through inputFromUSQL, everything else is deployed by USQL script, and loaded in R here on local worker.
# Original data in associated USQL script is partioned and partition info is added as first column in inputFromUSQL. 
# We do not use partition info, so we will drop it.
inputFromUSQL <- inputFromUSQL[, -1]

# ADLA data is (usually) distributed hence headerless. Schema needs to be defined separately and deployed to each worker in USQL, and then enforced here in R.
crtSchemaFile                   <- "R_schema_with_data_type_phm_data.csv"

# The auxiliary code (phmLOSPrediction_HCUPDataProcessing.R) has been deployed to each worker in USQL, and is available in this script's current directory.
hcupDataProcessingFunctionsFile <- "phmLOSPrediction_HCUPDataProcessing.R"

# function setColumnNamesAndTypes()  will assign the colnames and data type to each of the columns
inputFromUSQL <- setColumnNamesAndTypes(inputFromUSQL, crtSchemaFile)

#streaming data has identical schema with historical data, plus one extra column for time
inputFromUSQL <- inputFromUSQL[, -1]

# HCUP data specifics, most columns can be upper case, except the ones below
colnames(inputFromUSQL) <- toupper(colnames(inputFromUSQL))

#Rename columns to match the names in HCUP schema
names(inputFromUSQL)[names(inputFromUSQL) == 'ID']                <- 'KEY'
names(inputFromUSQL)[names(inputFromUSQL) == 'VISITLINK']         <- 'VisitLink'
names(inputFromUSQL)[names(inputFromUSQL) == 'POINTOFORIGINUB04'] <- 'PointOfOriginUB04'

#  functions are defined in script 'phmLOSPrediction_HCUPDataProcessing.R' and follow basic ML pipeline steps
#  source() will load functions doFeatureEngineering(), doLOSPrediction(), addPredCol2Raw() used below
source(hcupDataProcessingFunctionsFile, echo = TRUE)

# feature engineering - transform the data to be passed to the model for preditions
processedData  <- doFeatureEngineering(inputFromUSQL)

# Get the predictions. Everything is in the local parent directory, the path info (modelsLocation) is empty.
modelsLocation <- ""
processedData  <- doLOSPrediction(processedData, modelsLocation)

# Merge with original raw data. Not all rows will have a prediction due to misssing values, but all rows will have LOS_pred column
processedData  <- addPredCol2Raw(processedData, inputFromUSQL)

# recover original col name
names(processedData)[names(processedData) == 'KEY'] <- 'id'

# Drop everything except id and LOS_pred. 
# Will return only 2 columns back to usql. (It is more efficient to do processing/merging in usql)
processedData  <- processedData[, c("id", "LOS_pred")]

# Will make all data types string to avoid schema processing in ADLA
for (crtColumnIndex in seq_len(dim(processedData)[2])) {
  processedData[[crtColumnIndex]] <- as.character(processedData[[crtColumnIndex]])
}

# also make all cols lowercase
colnames(processedData) <- tolower(colnames(processedData))

# pass results back to usql
outputToUSQL <- processedData