# Purpose: Three functions are being declared below. 
#          These will be called by 'phm_score_streamed.R'
# Author:  Shaheen Gauher   gshaheen@microsoft.com

#====================================================================================


#####################################################
#         function doFeatureEngineering ()
#####################################################

doFeatureEngineering = function(dat) {

  # select columns below
  # Logic used: only use information available when the patient is 'just' admitted
  cols1   = c('KEY','VisitLink','DSHOSPID','AGE','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN',
            'MEDINCSTQ','PSTATE','ZIP','HOSPST','PAY1','PAY2','PAY3','LOS') 
  cols2   = grep('DXPOA',names(dat),value=T)
  cols3   = grep('E_POA',names(dat),value=T)
  
  cols4   = grep('^CHRON[0-9]',names(dat),value=T)
  cols5   = grep('^CHRONB',names(dat),value=T)
  cols6   = grep('^CM_',names(dat),value=T)
  cols7   = c('NDX','NCHRONIC','DX1','DXCCS1','DXMCCS1')
  
  allcols = c(cols1,cols2,cols3,cols4,cols5,cols6,cols7)

  #------------------------
  
  dat4los = dat[,allcols]
  
  #------------------------
  # DXPOA1 - DXPOA25  cols2
  indDXPOA           = grep('DXPOA',names(dat4los))
  # convert all  'Y' to 1 for DXPOA columns
  dat4los[,indDXPOA] = apply(dat4los[,indDXPOA],2,FUN=function(x){ifelse(x=='Y',1,x)}) 
  # now convert rest to 0 for DXPOA columns
  dat4los[,indDXPOA] = apply(dat4los[,indDXPOA],2,FUN=function(x){ifelse(x==1,x,0)})
  
  # create a column num_DXPOA
  # for these 25 columns , loop over all rows..for each row get count of number of 1s ..(valid values will be 0 to 25)
  dat4los$num_DXPOA = apply(dat4los[,indDXPOA],1,FUN=function(x){length(x[x=='1'])})
  
  dat4los           = dat4los[,-indDXPOA]  #delete all DXPOA cols
  
  #-------------------------------
  # E_POA1 to E_POA8  cols3
  # convert all non 'Y' to 0 for E_PAO
  indE_POA           = grep('E_POA',names(dat4los))
  dat4los[,indE_POA] = apply(dat4los[,indE_POA],2,FUN=function(x){ifelse(x=='Y',1,x)}) #NO Y in simulated data
  dat4los[,indE_POA] = apply(dat4los[,indE_POA],2,FUN=function(x){ifelse(x==1,x,0)})
  
  # create a column num_E_POA
  dat4los$num_E_POA  = apply(dat4los[,indE_POA],1,FUN=function(x){length(x[x=='1'])})
  
  dat4los            = dat4los[,-indE_POA]  #delete all E_POA cols
  
  #-------------------------------------
  # CHRON1 - CHRON25  
  indCHRON = grep('^CHRON[0-9]',names(dat4los))
  # create a column num_CHRON..if the data has NCHRONIC skip it - in the data 
  # dat4los$num_CHRON = apply(dat4los[,cols4],1,FUN=function(x){length(x[x==1])})
  
  dat4los  = dat4los[,-indCHRON]  #delete all CHRON cols..only keeping their count
  
  #------------------------------------------
  # CHRONB1 - CHRONB25  
  indchronB = grep('^CHRONB[0-9]',names(dat4los))
  
  # create a column num_uCHRONB get number of unique CHRONB
  dat4los$num_uCHRONB =  apply(dat4los[indchronB],1,FUN=function(x){length(unique(x[!is.na(x)]))})
  
  dat4los  = dat4los[,-indchronB]  # deleting all CHRONB cols..only keeping their count
  
  #--------------------------------------
  # PAY2 and PAY3 have a lot of missing values so removing these cols and creating num_PAY
  indPAY          = grep('PAY',names(dat4los),value=T)
  dat4los$num_PAY = apply(dat4los[,grep('PAY',names(dat4los),value=T)],1,FUN=function(x){length(x[!is.na(x)])})
  
  # remove PAY2 and PAY3 now
  dat4los$PAY2    = NULL
  dat4los$PAY3    = NULL
  
  #---------------------------------------
  # CM_AIDS,.. cols6
  indCM          = grep('CM_',names(dat4los))
  dat4los$num_CM = apply(dat4los[,indCM],1,FUN=function(x){(length(x[x==1]))})
  
  dat4los        = dat4los[,-indCM]  # deleting all CM cols
  
  #----------------------------
  # removing HOSPST as there is only one value in it 'FL' in simulated data, in real data will have more than one value
  dat4los        = dat4los[,!names(dat4los) %in% c('HOSPST')]
  
  # removing DX1. Will use a higher level diagnosis info in DXCCS1 instead
  dat4los        = dat4los[,!names(dat4los) %in% c('DX1')]
  
  # creating ZIP3 containing the first three numbers in zip code
  dat4los$ZIP3  = substr(dat4los$ZIP,1,3)
  dat4los$ZIP   = NULL
  
  
  return(dat4los)
}

################ *** End of function *** ############

#####################################################
#         function doLOSPrediction()
#####################################################

doLOSPrediction <-function(dat_str, modelsLocation){
  
  # LOS models were built for these hospitals. If the data is from any other hospital, will be scored using the model 'allotherhosp_LOSmodel'
  selected_hosp = c('hosp_1','hosp_2','hosp_3','hosp_4','hosp_5','hosp_6','hosp_7','hosp_8','hosp_9','hosp_10')
  
  # number of hospitals the streaming data is coming from
  allstr_hosp   = unique(dat_str$DSHOSPID)
  
  # check if these belong to selected_hosp
  individ  = allstr_hosp[allstr_hosp %in% selected_hosp]   # use individual models
  allother = allstr_hosp[!allstr_hosp %in% selected_hosp]  # use 'allotherhosp_LOSmodel' for data from allother hospitals
  
  # create a df to store raw and predictions
  dat_str_wpred          = dat_str[1,]
  dat_str_wpred$LOS_pred = NA
  dat_str_wpred          = dat_str_wpred[-1,]   # empty data frame
  
  # loop over all hospitals
  for (m in 1:(length(individ)+1)){
    # chek which hospital the data is from to invoke the correct model
    
    cat('m=',m,'\n')
    if(m == (length(individ) + 1)){
      cat('allother',allother,'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% allother)
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name  = paste('allotherhosp','_LOSmodel.rds',sep='')
      model_name  = paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load model to R
      model_lm    = readRDS(model_name)
      
    } else {
      cat('individ[m]',individ[m],'\n')
      sub_dat_str = subset(dat_str,dat_str$DSHOSPID %in% individ[m])
      cat(unique(as.character(sub_dat_str$DSHOSPID)),'\n')
      model_name  = paste(unique(as.character(sub_dat_str$DSHOSPID)),'_LOSmodel.rds',sep='')
      model_name  = paste0(modelsLocation, model_name)
      cat('model_name=',model_name,'\n')
      # load  model to R 
      model_lm    = readRDS(model_name)
    }
    dim(sub_dat_str)
    
    # the model is loaded, prepare the data to pass to the model for prediction
    sub_dat_str = sub_dat_str[complete.cases(sub_dat_str),] #get rid of rows with missing data
    
    dim(sub_dat_str)
    # make these columns categorical
    cat_cols = c('DSHOSPID','FEMALE','RACE','ATYPE','AMONTH','PointOfOriginUB04','TRAN_IN','MEDINCSTQ','PSTATE','PAY1','DXCCS1','DXMCCS1','ZIP3')
    
    makecatg = sapply(sub_dat_str[,cat_cols],FUN=function(x){as.factor(x)})
    makecatg = as.data.frame(makecatg)
    sub_dat_str[,cat_cols] = makecatg
    
    torm     = c("KEY" ,"VisitLink", "DSHOSPID","LOS")
    # remove these cols, LOS is the target
    sub_dat_str2pred = sub_dat_str[,names(sub_dat_str)[!names(sub_dat_str) %in% torm]]
    
    # use the model loaded above to get the predictions, store the unique KEY and predictions
    y_pred = predict(model_lm, sub_dat_str2pred)
    
    
    sub_dat_str$LOS_pred = y_pred
    
    dat_str_wpred        = rbind(dat_str_wpred,sub_dat_str)
    
  }

  # only keep 2 columns - KEY and LOS_pred
  predictions = data.frame(KEY=dat_str_wpred$KEY, LOS_pred=dat_str_wpred$LOS_pred)
  
  return(predictions)
  
}
################ *** End of function *** ############

#####################################################
#         function addPredCol2Raw()
#####################################################

addPredCol2Raw <- function(inputFromUSQL,scoredData){
  #scoredData has 2 cols
  rawdatapluspredcol = merge(inputFromUSQL,scoredData,by='KEY',all.x=T)
  return(rawdatapluspredcol)
} 
################ *** End of function *** ############


