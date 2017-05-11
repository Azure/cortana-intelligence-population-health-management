############################################################
# Purpose: This script will accept the joined  data and return the raw data plus predictions
#          Requires:
#          "R_schema_with_data_type_phm_data.csv" and 
#          "phmLOSPrediction_HCUPDataProcessing.R"
#          We will source phmLOSPrediction_HCUPDataProcessing.R which will load four functions in the workspace
#          

############################################################

############################################################
#    function setColumnNamesAndTypes()
############################################################

setColumnNamesAndTypes <- function(dfWithoutColumnNames, colClassFilename) {
    # colClasses info in colClassFilename comes in 2 col format, so we reshape it to a df with names and values
    # Values are class type, e.g. character, integer, logical
    colClasses <- read.csv(colClassFilename)
    colClasses <- as.data.frame(t(colClasses))
    colnames(colClasses) <-
      as.character(unlist(colClasses[c("colname"), ]))
    colClasses <-
      colClasses[c("data_type"), ]# drop 2nd row with columns names
    
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

# inputFromUSQL and outputToUSQL are dedicated named data frames respectively to pass data between USQL and R. 
# Input and output DataFrame identifier names are fixed 
# (i.e. users cannot change these predefined names of input and output DataFrame identifiers).

# dropping the first column with usql partition info
inputFromUSQL <- inputFromUSQL[, -1]

crtSchemaFile <- "R_schema_with_data_type_phm_data.csv"
hcupDataProcessingFunctionsFile <- "phmLOSPrediction_HCUPDataProcessing.R"

# function setColumnNamesAndTypes()  will assign the colnames and data type to each of the columns
inputFromUSQL <- setColumnNamesAndTypes(inputFromUSQL, crtSchemaFile)

#streaming data has identical schema with historical data (different order though), plus one extra column for time
inputFromUSQL <- inputFromUSQL[, -1]

# HCUP data specifics, most columns can be upper case, except the ones below
colnames(inputFromUSQL) <- toupper(colnames(inputFromUSQL))
names(inputFromUSQL)[names(inputFromUSQL) == 'ID'] = 'KEY'
names(inputFromUSQL)[names(inputFromUSQL) == 'VISITLINK'] = 'VisitLink'
names(inputFromUSQL)[names(inputFromUSQL) == 'POINTOFORIGINUB04'] = 'PointOfOriginUB04'

#  functions are defined in file phmLOSPrediction_HCUPDataProcessing.R and follow basic ML pipeline steps
#  feature engineering, scoring.
source(hcupDataProcessingFunctionsFile, echo = TRUE)
# feature engineering - transform the data to be passed to the model for preditions
processedData <- doFeatureEngineering(inputFromUSQL)

# Get the predictions
modelsLocation <- ""
processedData <- doLOSPrediction(processedData, modelsLocation)

# Merge with original raw data. Not all rows will have a prediction due to misssing values, but all rows will have LOS_pred column
processedData = addPredCol2Raw(processedData, inputFromUSQL)

# recover original col name
names(processedData)[names(processedData) == 'KEY'] = 'id'

# Drop everything except id and LOS_pred. It is more efficient to do processing/merging in usql
processedData <- processedData[, c("id", "LOS_pred")]

# Will make everyting string to avoid schema processing in ADLA
for (crtColumnIndex in seq_len(dim(processedData)[2])) {
  processedData[[crtColumnIndex]] <- as.character(processedData[[crtColumnIndex]])
}

# also make all cols lowercase
colnames(processedData) <- tolower(colnames(processedData))

outputToUSQL <- processedData



