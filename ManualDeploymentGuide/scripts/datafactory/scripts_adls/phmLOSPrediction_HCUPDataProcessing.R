# Purpose: Four functions are being declared below. 
#          These will be called by phm_score_streamed.R
#           
# Author:  Shaheen Gauher   gshaheen@microsoft.com

#====================================================================================


#####################################################
#         function doFeatureEngineering ()
#####################################################

doFeatureEngineering <- function(dat) {
  # e.g. dat -> hccostadls__stream_results_2017_03_22_12_00.csv with header
  #-------------------------------------------
  
  
  #select columns below
  #Logic used: only use information available when the patient is 'just' admitted
  cols1 = c('KEY','VisitLink','DSHOSPID','AGE','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN',
            'MEDINCSTQ','PSTATE','ZIP','HOSPST','PAY1','PAY2','PAY3','LOS') 
  cols2 = grep('DXPOA',names(dat),value=T)
  cols3 = grep('E_POA',names(dat),value=T)
  
  cols4 = grep('^CHRON[0-9]',names(dat),value=T)
  cols5 = grep('^CHRONB',names(dat),value=T)
  cols6 = grep('^CM_',names(dat),value=T)
  cols7 = c('NDX','NCHRONIC','DX1','DXCCS1','DXMCCS1')
  
  allcols = c(cols1,cols2,cols3,cols4,cols5,cols6,cols7)
  length(allcols) #135
  
  othercols = names(dat)[!names(dat) %in% allcols]
  #length(othercols)
  
  #length(allcols) + length(othercols)
  #ncol(dat)
  
  #------------------------
  
  dat4los = dat[,allcols]
  #dim(dat4los) #1103172     135
  #names(dat4los)
  
  #------------------------
  #DXPOA1 - DXPOA25  cols2
  indDXPOA = grep('DXPOA',names(dat4los))
  #convert all  'Y' to 1 for DXPOA columns
  dat4los[,indDXPOA]=apply(dat4los[,indDXPOA],2,FUN=function(x){ifelse(x=='Y',1,x)}) 
  #now convert rest to 0 for DXPOA columns
  dat4los[,indDXPOA]=apply(dat4los[,indDXPOA],2,FUN=function(x){ifelse(x==1,x,0)})
  
  #create a column num_DXPOA
  #for these 25 columns , loop over all rows..for each row give me count of number of 1s ..(valid values will be 0 to 25)
  dat4los$num_DXPOA = apply(dat4los[,indDXPOA],1,FUN=function(x){length(x[x=='1'])})
  
  dat4los = dat4los[,-indDXPOA]  #delete all DXPOA cols
  
  #-------------------------------
  #E_POA1 to E_POA8  cols3
  #convert all non 'Y' to 0 for E_PAO
  indE_POA = grep('E_POA',names(dat4los))
  dat4los[,indE_POA]=apply(dat4los[,indE_POA],2,FUN=function(x){ifelse(x=='Y',1,x)}) #NO Y in simulated data
  dat4los[,indE_POA]=apply(dat4los[,indE_POA],2,FUN=function(x){ifelse(x==1,x,0)})
  
  #create a column num_E_POA
  dat4los$num_E_POA = apply(dat4los[,indE_POA],1,FUN=function(x){length(x[x=='1'])})
  
  dat4los = dat4los[,-indE_POA]  #delete all E_POA cols
  
  #-------------------------------------
  #CHRON1 - CHRON25 cols4 
  indCHRON = grep('^CHRON[0-9]',names(dat4los))
  #create a column num_CHRON..SAME AS NCHRONIC in the data actually
  #dat4los$num_CHRON = apply(dat4los[,cols4],1,FUN=function(x){length(x[x==1])})
  
  dat4los = dat4los[,-indCHRON]  #delete all CHRON cols..only keeping their count
  
  #------------------------------------------
  #CHRONB1 - CHRONB25  cols5
  indchronB = grep('^CHRONB[0-9]',names(dat4los))
  
  #create a column num_uCHRONB get number of unique CHRONB
  dat4los$num_uCHRONB =  apply(dat4los[indchronB],1,FUN=function(x){length(unique(x[!is.na(x)]))})
  
  dat4los = dat4los[,-indchronB]  # deleting all CHRONB cols..only keeping their count
  
  #--------------------------------------
  #PAY2 and PAY3 have a lot of -9 so removing these cols and creating num_PAY
  indPAY = grep('PAY',names(dat4los),value=T)
  dat4los$num_PAY = apply(dat4los[,grep('PAY',names(dat4los),value=T)],1,FUN=function(x){length(x[!is.na(x)])})
  
  if(unique(dat4los$num_PAY)==1){
    #artificially including some non 1 in num_PAY as in simulated data only 1
    set.seed(1)
    non1 = sample(c(1:nrow(dat4los)),size=1000,replace=F)
    dat4los$num_PAY[non1]=2
    #table(dat4los$num_PAY)
  }
  
  #remove PAY2 and PAY3 now
  dat4los$PAY2 = NULL
  dat4los$PAY3 = NULL
  
  #---------------------------------------
  #CM_AIDS,.. cols6
  indCM = grep('CM_',names(dat4los))
  dat4los$num_CM = apply(dat4los[,indCM],1,FUN=function(x){(length(x[x==1]))})
  
  dat4los = dat4los[,-indCM]  # deleting all CM cols
  
  #----------------------------
  #PointOfOriginUB04 has a wierd " " in HCUP data but not in simulated data
  # table(dat4los$PointOfOriginUB04,useNA = 'always')
  # indgood = grep('[0-9A-Za-z]',dat4los$PointOfOriginUB04)
  # dat4los = dat4los[indgood,] #removing all invalid values
  
  
  
  # #removing HOSPST as there is only one value in it 'FL' in simulated data
  # dat4los = dat4los[,grep('HOSPST',names(dat4los))]
  #remove HOSPST as there is only one value in it 'FL' in simulated data
  dat4los = dat4los[,!names(dat4los) %in% c('HOSPST')]
  
  #removing DX1. Will use a higher level diagnosis info in DXCCS1 instead
  dat4los = dat4los[,!names(dat4los) %in% c('DX1')]
  
  dat4los$ZIP3 = substr(dat4los$ZIP,1,3)
  dat4los$ZIP = NULL
  
  
  return(dat4los)
}

#####################################################
#         function doLOSPrediction()
#####################################################

doLOSPrediction <-function(dat_str, modelsLocation){
  
  selected_hosp = c('hosp_1','hosp_2','hosp_3','hosp_4','hosp_5','hosp_6','hosp_7','hosp_8','hosp_9','hosp_10')
  
  #number of hospitals in the streaming data
  
  allstr_hosp = unique(dat_str$DSHOSPID)
  #do these belong to selected_hosp
  individ = allstr_hosp[allstr_hosp %in% selected_hosp]   # use individual models
  allother = allstr_hosp[!allstr_hosp %in% selected_hosp] #use 'allotherhosp_LOSmodel'
  
  #create a df to store raw and predictions
  dat_str_wpred = dat_str[1,]
  dat_str_wpred$LOS_pred = NA
  dat_str_wpred = dat_str_wpred[-1,]   #25 cols
  
  #for (m in 1:1){
  for (m in 1:(length(individ)+1)){
    #chek which hospital the data is from to invoke the correct model
    
    cat('m=',m,'\n')
    if(m==(length(individ)+1)){
      cat('allother',allother,'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% allother)
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name = paste('allotherhosp','_LOSmodel.rds',sep='')
      model_name <- paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load model to R
      model_lm = readRDS(model_name)
      
    } else {
      cat('individ[m]',individ[m],'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% individ[m])
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name = paste(unique(as.character(sub_dat_str$DSHOSPID)),'_LOSmodel.rds',sep='')
      model_name <- paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load  model to R 
      model_lm = readRDS(model_name)
    }
    dim(sub_dat_str)
    
    #the model is loaded, prepare the data to pass to the model for prediction
    sub_dat_str = sub_dat_str[complete.cases(sub_dat_str),] 
    
    dim(sub_dat_str)
    #make these columns categorical
    cat_cols = c('DSHOSPID','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN','MEDINCSTQ','PSTATE','PAY1','DXCCS1','DXMCCS1','ZIP3')
    
    makecatg = sapply(sub_dat_str[,cat_cols],FUN=function(x){as.factor(x)})
    makecatg = as.data.frame(makecatg)
    sub_dat_str[,cat_cols] = makecatg
    
    torm = c("KEY" ,"VisitLink", "DSHOSPID","LOS")
    
    sub_dat_str2pred = sub_dat_str[,names(sub_dat_str)[!names(sub_dat_str) %in% torm]]
    
    # use the model loaded above to get the predictions for on streaming data, store the raw data and predictions
    y_pred <- predict(model_lm, sub_dat_str2pred)
    length(y_pred)
    
    sub_dat_str$LOS_pred = y_pred
    #dim(sub_dat_str)
    dat_str_wpred = rbind(dat_str_wpred,sub_dat_str)
    
  }
  
  #dat_str_wpred
  #only keep 2 columns - KEY and LOS_pred
  predictions = data.frame(KEY=dat_str_wpred$KEY, LOS_pred=dat_str_wpred$LOS_pred)
  
  return(predictions)
  
}

#####################################################
#         function addPredCol2Raw()
#####################################################

addPredCol2Raw <- function(inputFromUSQL,scoredData){
  #scoredData has 2 cols
  
  rawdatapluspredcol = merge(inputFromUSQL,scoredData,by='KEY',all.x=T)
  
  
  return(rawdatapluspredcol)
} 

#####################################################
#         function doMLTraining()
#####################################################

doMLTraining<-function(dat, modelsLocation){
  cat('to add here \n')
  #dat is historicdata with schema
  require(caret)
  dat4los = doFeatureEngineering(dat)
  dim(dat4los)  #1103172 24
  
  #-------------------------
  #make these columns categorical
  cat_cols = c('DSHOSPID','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN','MEDINCSTQ','PSTATE','PAY1','DXCCS1','DXMCCS1','ZIP3')
  
  makecatg = sapply(dat4los[,cat_cols],FUN=function(x){as.factor(x)})
  makecatg = as.data.frame(makecatg)
  dat4los[,cat_cols] = makecatg
  
  #numeric columns are 
  #num_cols = names(dat4los)[!(names(dat4los) %in% cat_cols)]
  
  data_mod = dat4los
  #--------------------------
  dat4los$LOS = round(dat4los$LOS)  # will remove this once fix the historic data
  #--------------------------
  ###########################################################
  #    Linear Regression
  ############################################################
  
  ###########################################################
  # select a few hospitals to build individual models for
  ###########################################################
  #paste(sort(unique(data_mod$DSHOSPID)),collapse="','")
  selected_hosp = c('hosp_1','hosp_2','hosp_3','hosp_4','hosp_5','hosp_6','hosp_7','hosp_8','hosp_9','hosp_10')
  allotherhosp = unique(data_mod$DSHOSPID)[!unique(data_mod$DSHOSPID) %in% selected_hosp]
  allotherhosp = as.character(allotherhosp)  #"hosp_17" "hosp_13" "hosp_11" "hosp_22" "hosp_14" "hosp_23" "hosp_16" "hosp_12" "hosp_18" "hosp_15" "hosp_19" "hosp_21" "hosp_20"
  
  
  
  require(caret)
  
  for (h in 1:(length(selected_hosp)+1)){
    #for (h in 1:1){
    #
    cat('h=',h,'\n')
    if(h==(length(selected_hosp)+1)){
      cat('allotherhosp',allotherhosp,'\n')
      sub_data_mod = subset(data_mod,data_mod$DSHOSPID %in% allotherhosp)
      cat(unique(as.character(sub_data_mod$DSHOSPID)),'\n')
      model_name = paste('allotherhosp','_LOSmodel',sep='')
      model_name <- paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
    } else {
      cat('selected_hosp[h]',selected_hosp[h],'\n')
      sub_data_mod = subset(data_mod,data_mod$DSHOSPID %in% selected_hosp[h])
      cat(unique(as.character(sub_data_mod$DSHOSPID)),'\n')
      model_name = paste(unique(as.character(sub_data_mod$DSHOSPID)),'_LOSmodel',sep='')
      model_name <- paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
    }
    
    
    #Got the data (sub_data_mod), build model for this data now and save the model with name model_name
    sub_data_mod = sub_data_mod[complete.cases(sub_data_mod),] #ensure all rows are complete
    
    
    #create a temporary column myrownum
    data_mod$myrownum = seq(1:nrow(data_mod))
    sub_data_mod$myrownum = seq(1:nrow(sub_data_mod))
    
    
    train.index <- createDataPartition(sub_data_mod$DXCCS1 , p = .6, list = FALSE)
    train <- sub_data_mod[ train.index,]
    test  <- sub_data_mod[-train.index,]
    #
    length(train.index); nrow(sub_data_mod); nrow(train); nrow(test) ;nrow(train)+ nrow(test)
    #==================================================================
    #ensuring training data contains all categories
    #==================================================================
    
    indcc = which(names(sub_data_mod) %in% cat_cols)
    toaddtotrain = test[1,]
    toaddtotrain = toaddtotrain[-1,]  #empty data frame now
    
    for (cc in 1:length(indcc)){
      toaddtotrain4cc = test[!duplicated(test[,indcc[cc]]),]  # same as unique
      toaddtotrain = rbind(toaddtotrain,toaddtotrain4cc)
    }
    
    #in toaddtotrain there will be duplicate rows, remove duplicate rows
    #then append this to train and remove these rows from test
    
    
    toaddtotrain = toaddtotrain[!duplicated(toaddtotrain$myrownum),]
    rm(train_2,test_2)
    train_2 = rbind(train,toaddtotrain)
    #remove rows from test
    test_2 = test[-which(test$myrownum %in% toaddtotrain$myrownum),]
    
    #==================================================================
    #ensuring unique patients in train and test
    #==================================================================
    
    
    
    vk = unique(test_2$VisitLink)[unique(test_2$VisitLink) %in% unique(train_2$VisitLink)]
    vk1 = vk[1:round(length(vk)/2)]
    vk2 = vk[(round(length(vk)/2)+1) : length(vk)]
    
    
    torm4mtest = which(test_2$VisitLink %in% vk1)
    
    #add this to train
    train_2 = rbind(train_2,test_2[torm4mtest,])
    #remove this from test
    test_2 = test_2[-torm4mtest,]
    
    
    torm4mtrain = which(train_2$VisitLink %in% vk2)
    
    #add this to test
    test_2 = rbind(test_2,train_2[torm4mtrain,])
    #remove this from train
    train_2 = train_2[-torm4mtrain,]
    
    
    #-----------------------------------------
    #-----------------------------------------
    #remove myrownum now from both train_2 and test_2
    train_2$myrownum = NULL
    test_2$myrownum = NULL
    
    train_2$KEY = NULL
    test_2$KEY = NULL
    
    train_2$VisitLink = NULL
    test_2$VisitLink = NULL
    
    train_2$DSHOSPID = NULL
    test_2$DSHOSPID = NULL
    #
    #now have the data split into training and testing ~60% training and ~40% testing
    
    #Tune and Run the model
    mytarget     = 'LOS'
    mypredictors = names(train_2)[!names(train_2) %in% mytarget]
    myformulastr = paste(mytarget, paste(mypredictors, collapse=" + "), sep=" ~ ")
    cat('myformulastr ',myformulastr,'\n')
    
    rm(model_lm)
    model_lm = lm(as.formula(myformulastr), data=train_2)
    
    # # save model 
    
    model_name_rds <- paste0(model_name,'.rds')
    cat('saving model_name =',model_name_rds,'\n')
    saveRDS(model_lm, model_name_rds)
    
    
    
  }
  
  
  
}
