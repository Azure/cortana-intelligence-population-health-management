#############################################################################################
# Purpose: In this R script we push the streaming data through a function for scoring
#          The function doLOSPrediction() accepts the transformed data that can be fed to the models for prediction.
#          It also accepts as input the model location. It returns 2 cols - KEY and LOS_pred
#          Before passing this output to usql we will change the data types to string.
#############################################################################################

#############################################################################################
#                 Function doLOSPrediction()
#############################################################################################

# define function doLOSPrediction
doLOSPrediction = function(dat_str, modelsLocation){
  
  selected_hosp = c('hosp_1','hosp_2','hosp_3','hosp_4','hosp_5','hosp_6','hosp_7','hosp_8','hosp_9','hosp_10')
  
  #number of hospitals in the streaming data
  allstr_hosp = unique(dat_str$DSHOSPID)
  #do these belong to selected_hosp
  individ  = allstr_hosp[allstr_hosp %in% selected_hosp]   # use individual models
  allother = allstr_hosp[!allstr_hosp %in% selected_hosp] #use 'allotherhosp_LOSmodel'
  
  #create a df to store raw and predictions
  dat_str_wpred = dat_str[1,]
  dat_str_wpred$LOS_pred = NA
  dat_str_wpred = dat_str_wpred[-1,]   #25 cols
  
  
  for (m in 1:(length(individ)+1)){
    #check which hospital the data is from to invoke the correct model
    
    
    if(m == (length(individ)+1)){
      cat('allother',allother,'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% allother)
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name = paste('allotherhosp','_LOSmodel.rds',sep='')
      model_name = paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load model to R
      model_lm = readRDS(model_name)
      
    } else {
      cat('individ[m]',individ[m],'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% individ[m])
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name = paste(unique(as.character(sub_dat_str$DSHOSPID)),'_LOSmodel.rds',sep='')
      model_name = paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load  model to R 
      model_lm = readRDS(model_name)
    }
    
    
    #the model is loaded, prepare the data to pass to the model for prediction
    
    
    sub_dat_str = sub_dat_str[complete.cases(sub_dat_str),] 
    sub_dat_str = sub_dat_str[!apply(sub_dat_str == "", 1, all),]  #remove empty rows
    
    
    #make these columns categorical
    cat_cols = c('DSHOSPID','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN','MEDINCSTQ','PSTATE','PAY1','DXCCS1','DXMCCS1','ZIP3')
    
    makecatg = sapply(sub_dat_str[,cat_cols],FUN=function(x){as.factor(x)})
    makecatg = as.data.frame(makecatg)
    sub_dat_str[,cat_cols] = makecatg
    
    #make these columns numeric
    cat_num  = c('AGE', 'LOS', 'NDX', 'NCHRONIC', 'num_DXPOA', 'num_E_POA', 'num_uCHRONB', 'num_PAY', 'num_CM')
    makenum  = sapply(sub_dat_str[,cat_num],FUN=function(x){as.numeric(x)})
    makenum  = as.data.frame(makenum)
    sub_dat_str[,cat_num] = makenum
    
    torm     = c("KEY" ,"VisitLink", "DSHOSPID","LOS")
    
    sub_dat_str2pred = sub_dat_str[,names(sub_dat_str)[!names(sub_dat_str) %in% torm]]
    
    #the model is loaded, prepare the data to pass to the model for prediction
    sub_dat_str2pred = sub_dat_str2pred[complete.cases(sub_dat_str2pred),]     
    
    # use the model loaded above to get the predictions for on streaming data, store the raw data and predictions
    y_pred = predict(model_lm, sub_dat_str2pred)
        
    sub_dat_str$LOS_pred = y_pred
    
    dat_str_wpred = rbind(dat_str_wpred,sub_dat_str)
    
  }
  
  
  # only keep 2 columns - KEY and LOS_pred
  predictions = data.frame(KEY=dat_str_wpred$KEY, LOS_pred=dat_str_wpred$LOS_pred)
  
  predictions$LOS_pred[predictions$LOS_pred >= 1.5] = round(predictions$LOS_pred)
  predictions$LOS_pred[predictions$LOS_pred < 1.5]  = 1
  
  return(predictions)
  
}

#####################################################################
#           End of function
#####################################################################


# inputFromUSQL and outputToUSQL are dedicated named data frames respectively to pass data between USQL and R. 
# Input and output DataFrame identifier names are fixed 
# (i.e. users cannot change these predefined names of input and output DataFrame identifiers).

my_inputFromUSQL  = inputFromUSQL[,-1]   # dropping the first column with usql partition info

# From usql received the input in the following order
# c('id','visitlink','dshospid','age','female','race','atype','amonth','pointoforiginub04','tran_in','medincstq','pstate','pay1','los','ndx','nchronic','dxccs1','dxmccs1','num_DXPOA','num_e_poa','num_uCHRONB','num_pay','num_CM','zip3')

FEcolnames = c("KEY" , "VisitLink" ,"DSHOSPID" ,"AGE" ,"FEMALE" , "RACE" ,"ATYPE" , "AMONTH" ,"PointOfOriginUB04", "TRAN_IN"  ,"MEDINCSTQ" ,"PSTATE" ,"PAY1","LOS" , "NDX" ,"NCHRONIC" ,"DXCCS1" , "DXMCCS1"  ,"num_DXPOA" , "num_E_POA"    ,"num_uCHRONB" ,"num_PAY" ,"num_CM" ,"ZIP3")
names(my_inputFromUSQL) = FEcolnames



#===========================================================
# Prepare data to be passed to the model
#===================================================

dataforscoring = my_inputFromUSQL[grep('[0-9]',as.character(my_inputFromUSQL$DXCCS1)),]

dataforscoring = dataforscoring[grep('[0-9]',as.character(dataforscoring$DXMCCS1)),]

dataforscoring = dataforscoring[(nchar(dataforscoring$ZIP3) == 3) , ]

dataforscoring = my_inputFromUSQL[complete.cases(my_inputFromUSQL),] 

#========================================================

modelsLocation = "" 
scoredData     = doLOSPrediction(dataforscoring, modelsLocation)  # will return 2 columns - KEY and LOS_pred

scoredData     = merge(my_inputFromUSQL,scoredData,by='KEY',all.x=T) # recover the original number of rows

names(scoredData)[names(scoredData)=='KEY'] = 'id'  # recover original col name

# drop everything except id and LOS_pred. It is more efficient to do processing/merging in usql
scoredData     = scoredData[,c("id", "LOS_pred")]

# also make all cols lowercase
colnames(scoredData) = tolower(colnames(scoredData))  # c("id","los_pred")

#-------------------------------------
#for all cols to be of type string for output
scoredData = data.frame(lapply(scoredData,as.character))

# #------------------------------------
outputToUSQL <- scoredData

