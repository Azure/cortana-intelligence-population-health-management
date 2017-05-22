# Purpose: Read scored data and create curated data for visualisation. 
#          Input is scored data plus some additional columns for visualization
#          Requires:
#          - 'Single_LevelCCS_Diagnoses_csv.csv' , 'Single_LevelCCS_Procedures_csv.csv' for mapping
#          We will do the following tasks:
#          - Select subset of columns that are needed for visualization
#          - Rename the levels in some columns.. for e.g. for PAY1=1 replace 1 with 'Medicare' etc.
#          - Create readmitted columns etc.
#          The output will be curated data. The PBI will connect to this file for visualisation.        
#====================================================================================


#####################################################################
#   Function fun_addcols()
#####################################################################

fun_addcols = function(dat){
  
  #===========================================================
  dat$myrownum = seq(1:nrow(dat)) 
  #===========================================================
  # Relabelling DXCCS1 -- #create a column DXCCS_name
  # Reading mapping data
  DXCCSlistall        = read.csv('Single_LevelCCS_Diagnoses_csv.csv',header=T ,stringsAsFactors = F)
  names(DXCCSlistall) = c("CCS_Diag","Label")
  
  gindex              = grep('[0-9]',as.character(dat$DXCCS1))
  bindex              = !dat$rownumber %in% gindex
  dat$DXCCS1[bindex]  = NA
  DXCCSlistnow        = data.frame(CCS_Diag=unique(dat$DXCCS1[!is.na(dat$DXCCS1)]))
  DXCCSlist           = merge(DXCCSlistnow,DXCCSlistall,by='CCS_Diag',all.x=T)
  
  DXCCSlist$Label     = as.character(DXCCSlist$Label)
  #DXCCSlist$Label[DXCCSlist$CCS_Diag < 0] = 'None' 
  #
  # create a column DXCCS_name
  dat$DXCCS_name      = dat$DXCCS1
  dat$DXCCS_name      = as.factor(dat$DXCCS_name)
  levels(dat$DXCCS_name) = DXCCSlist$Label #levels(dat$DXCCS1) should be same as DXCCSlist$CCS_Diag
  
  #===========================================================
  # Relabelling PRCCS1 -#create a column PRCCS_name
  # Reading mapping data
  PRCCSlistall        = read.csv('Single_LevelCCS_Procedures_csv.csv',header=T, stringsAsFactors = F)
  names(PRCCSlistall) = c("CCS_Proc","Label")
  
  gindex              = grep('[0-9]',as.character(dat$PRCCS1))
  bindex              = !dat$rownumber %in% gindex
  dat$PRCCS1[bindex]  = NA
  PRCCSlistnow        = data.frame(CCS_Proc=unique(dat$PRCCS1[!is.na(dat$PRCCS1)])) #there is NA, 
  
  PRCCSlist = merge(PRCCSlistnow,PRCCSlistall,by='CCS_Proc',all.x=T)
  PRCCSlist$Label    = as.character(PRCCSlist$Label)
  #PRCCSlist$Label[PRCCSlist$CCS_Proc <0] = 'None'
  #
  # create a column PRCCS_name
  dat$PRCCS_name = dat$PRCCS1
  dat$PRCCS_name = as.factor(dat$PRCCS_name)
  
  # Rename levels
  levels(dat$PRCCS_name) = PRCCSlist$Label #PRCCSlist$CCS_Proc
  #===========================================================
  # create a column PRMCCS_name from PRMCCS1
  # creating mapping data
  prmccs        = c('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16')
  prmccs_16cat  = c('Op_nervous_sys','Op_endocrine_syst','Op_eye','Op_ear','Op_nose_mouth_pharynx','Op_respiratory_sys','Op_cardiovascular_sys','Op_hemic_lymphatic_sys','Op_digestive_sys','Op_urinary_sys','Op_male_genital_sys','Op_female_genital_sys','Op_Obstetrical_procedures','Op_musculoskeletal_sys','Op_integumentary_sys','Op_miscdiag_therproc')
  PRMCCSlistall = data.frame(MCCS_Proc=prmccs, Label = prmccs_16cat, stringsAsFactors = F)
  
  gindex              = grep('[0-9]',as.character(dat$PRMCCS1))
  bindex              = !dat$rownumber %in% gindex
  dat$PRMCCS1[bindex] = NA
  PRMCCSlistnow       = data.frame(MCCS_Proc=unique(dat$PRMCCS1[!is.na(dat$PRMCCS1)]))
  
  PRMCCSlist       = merge(PRMCCSlistnow,PRMCCSlistall,by='MCCS_Proc',all.x=T)
  PRMCCSlist$Label = as.character(PRMCCSlist$Label)
  #PRMCCSlist$Label[PRMCCSlist$MCCS_Proc <0] = 'None'
  
  # create a column PRMCCS_name
  dat$PRMCCS_name = dat$PRMCCS1
  dat$PRMCCS_name = as.factor(dat$PRMCCS_name)
  # Rename levels
  levels(dat$PRMCCS_name) = PRMCCSlist$Label
  #===========================================================
  # create a column DXMCCS_name from DXMCCS1
  
  # creating mapping data
  dxmccs        = c('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18')
  dxmccs_18cat  = c('InfectiousAndParasiticDisease','Neoplasms','EndocrineNutritionalMetabolicDiseasesImmunityDisorders','DiseasesBloodABloodFormingOrgans','MentalDisorders','DiseasesOfNervousSystemAndSenseOrgans','DiseasesOfCirculatorySystem','DiseasesOfRespiratorySystem','DiseasesOfDigestiveSystem','DiseasesOfGenitourinarySystem','ComplicationsOfPregnancyChildbirthPuerperium','DiseasesOfSkinSubcutaneousTissue','DiseasesOfMusculoskeletalSystem','CongenitalAnomalies','ConditionsOriginatingInPerinatalPeriod','SymptomsSignsIllDefinedConditions','InjuryAndPoisoning','FactorsInfluencingHealthStatusAndContactWithHealthServices')
  DXMCCSlistall = data.frame(MCCS_Diag=dxmccs, Label = dxmccs_18cat, stringsAsFactors = F)
  DXMCCSlistall$MCCS_Diag = as.numeric(DXMCCSlistall$MCCS_Diag)
  
  gindex              = grep('[0-9]',as.character(dat$DXMCCS1))
  bindex              = !dat$rownumber %in% gindex
  dat$DXMCCS1[bindex] = NA
  DXMCCSlistnow = data.frame(MCCS_Diag=unique(dat$DXMCCS1[!is.na(dat$DXMCCS1)])) #has NA
  DXMCCSlistnow = DXMCCSlistnow[!is.na(DXMCCSlistnow$MCCS_Diag),,drop=F]
  DXMCCSlist    = merge(DXMCCSlistnow,DXMCCSlistall,by='MCCS_Diag',all.x=T)
  
  DXMCCSlist$Label = as.character(DXMCCSlist$Label)
  #DXMCCSlist$Label[DXMCCSlist$MCCS_Diag<0] = 'None' 
  
  # create a column DXCCS_name
  dat$DXMCCS_name  = dat$DXMCCS1
  dat$DXMCCS_name  = as.factor(dat$DXMCCS_name)
  levels(dat$DXMCCS_name) = DXMCCSlist$Label #levels(dat$DXMCCS1) should be same as DXMCCSlist$MCCS_Diag
  
  
  #===========================================================
  # Not creating a new column - renaming levels
  # 1	Emergency
  # 2	Urgent
  # 3	Elective
  # 4	Newborn
  # 5	Delivery (coded in 1988-1997 data only)
  # 5	Trauma Center (beginning in 2003)
  # 6	Other

  # dat$ATYPE = gsub('ATYPE_','',dat$ATYPE)
  # creating mapping data
  atypeall  = data.frame(V1=c(1,2,3,4,5,6),V2=c('Emergency','Urgent','Elective','Newborn','Trauma Center','Other'))
  
  gindex            = grep('[0-9]',as.character(dat$ATYPE))
  bindex            = !dat$rownumber %in% gindex
  dat$ATYPE[bindex] = NA
  atypenow  = data.frame(V1=unique(dat$ATYPE[!is.na(dat$ATYPE)]))
  atype     = merge(atypenow,atypeall,by='V1',all.x=T)
  atype$V2  = as.character(atype$V2)
  
  dat$ATYPE = as.factor(dat$ATYPE)
  # Rename Levels
  levels(dat$ATYPE) = atype$V2 #atype$V1 shd be same as levels(dat$ATYPE)
  #===========================================================
  # Not creating a new column
  # creating mapping data
  V2            = c('Non-health care facility point of origin','Clinic','Transfer from a hospital (different facility)','Transfer from a SNF or ICF for ATYPE ne 4 | Born inside this hospital for ATYPE = 4','Transfer from another health care facility for ATYPE ne 4| Born outside of this hospital for ATYPE = 4','Emergency room ','Court/law enforcement','Transfer from another Home Health Agency','Readmission to Same Home Health Agency ','Transfer from one distinct unit of the hospital to another distinct unit of the same hospital','Transfer from ambulatory surgery center','Transfer from hospice')
  PointOfOrigin = data.frame(V1=c('1','2','4','5','6','7','8','B','C','D','E','F'), V2=V2)
  
  gindex        = grep('[0-9A-Za-z]',as.character(dat$PointOfOriginUB04))
  bindex        = !dat$rownumber %in% gindex
  dat$PointOfOriginUB04[bindex] = NA
  poi_now       = data.frame(V1=unique(dat$PointOfOriginUB04[!is.na(dat$PointOfOriginUB04)]))
  poi2          = merge(poi_now,PointOfOrigin,by='V1',all.x=T)
  poi2$V2       = as.character(poi2$V2)
  
  dat$PointOfOriginUB04 = as.factor(as.character(dat$PointOfOriginUB04))
  levels(dat$PointOfOriginUB04) = poi2$V2  #levels(dat$PointOfOriginUB04 should be same as poi2$V1
  #===========================================================
  # Not creating a new column but renaming
  # creating mapping data
  # 0	Not transferred in
  # 1	Transferred in from a different acute care hospital
  # 2	Transferred in from another type of health facility
  V2             = c('Not transferred in','Transferred in from a different acute care hospital','Transferred in from another type of health facility')
  TRANSFER_INall = data.frame(V1=c(0,1,2),V2=V2)
  
  
  gindex         = grep('[0-9]',as.character(dat$TRAN_IN))
  bindex         = !dat$rownumber %in% gindex
  dat$TRAN_IN[bindex] = NA
  TRAN_IN_now    = data.frame(V1=unique(dat$TRAN_IN[!is.na(dat$TRAN_IN)]))
  
  TRAN_IN2       = merge(TRAN_IN_now,TRANSFER_INall,by='V1',all.x=T)
  TRAN_IN2$V2    = as.character(TRAN_IN2$V2)
  
  dat$TRANSFER_IN = as.factor(as.character(dat$TRAN_IN))  #creating TRANSFER_IN
  dat$TRAN_IN     = NULL
  levels(dat$TRANSFER_IN) = TRAN_IN2$V2  #TRANSFER_IN$V2
  #===========================================================
  # Not creating a new column but renaming
  dat$GENDER = as.factor(dat$FEMALE)
  
  dat$FEMALE = NULL
  #===========================================================
  # Not creating a new column 
  # creating mapping data
  RACEall  = data.frame(V1=c(-9,1,2,3,4,5,6),V2=c('Missing','White','Black','Hispanic','Asian_PacificIslander','NativeAmerican','Other'))
  
  gindex   = grep('[0-9]',as.character(dat$RACE))
  bindex   = !dat$rownumber %in% gindex
  dat$RACE[bindex] = NA
  RACEnow  = data.frame(V1=unique(as.character(dat$RACE[!is.na(dat$RACE)])))
  RACE     = merge(RACEnow,RACEall,by='V1',all.x=T)
  RACE$V2  = as.character(RACE$V2)
  #
  dat$RACE = as.factor(dat$RACE)
  # Rename Levels
  levels(dat$RACE) = RACE$V2 #RACE$V1 shd be same as RACE$
  
  #===========================================================
  # Not creating a new column
  #rename PAY1
  payerall   = data.frame(V1=c(1,2,3,4,5,6),V2=c('Medicare','Medicaid','Private-Insurance','Self-pay','No-charge','Other'))
  
  gindex     = grep('[0-9]',as.character(dat$PAY1))
  bindex     = !dat$rownumber %in% gindex
  dat$PAY1[bindex] = NA
  payernow   = data.frame(V1=unique(dat$PAY1[!is.na(dat$PAY1)]))
  payer      = merge(payernow,payerall,by='V1',all.x=T)
  payer$V2   = as.character(payer$V2)
  
  dat$PAYER1 = as.factor(dat$PAY1)
  # Rename Levels
  levels(dat$PAYER1) = payer$V2 #payer$V1 shd be same as levels(dat$PAYER1)
  dat$PAY1   = NULL
  #===========================================================
  #create a column MDC_name from MDC 
  #creating mapping data
  V2 = c('Pre-MDC','Diseases and Disorders of the Nervous System','Diseases and Disorders of the Eye','Diseases and Disorders of the Ear Nose Mouth And Throat','Diseases and Disorders of the Respiratory System',
         'Diseases and Disorders of the Circulatory System','Diseases and Disorders of the Digestive System','Diseases and Disorders of the Hepatobiliary System And Pancreas','Diseases and Disorders of the Musculoskeletal System And Connective Tissue','Diseases and Disorders of the Skin Subcutaneous Tissue And Breast','Diseases and Disorders of the Endocrine Nutritional And Metabolic System','Diseases and Disorders of the Kidney And Urinary Tract','Diseases and Disorders of the Male Reproductive System','Diseases and Disorders of the Female Reproductive System','Pregnancy Childbirth And Puerperium','Newborn And Other Neonates (Perinatal Period)','Diseases and Disorders of the Blood and Blood Forming Organs and Immunological Disorders',
         'Myeloproliferative DDs (Poorly Differentiated Neoplasms)','Infectious and Parasitic DDs (Systemic or unspecified sites)','Mental Diseases and Disorders','Alcohol/Drug Use or Induced Mental Disorders','Injuries Poison And Toxic Effect of Drugs',
         'Burns','Factors Influencing Health Status and Other Contacts with Health Services','Multiple Significant Trauma','Human Immunodeficiency Virus Infection')
  mdc26 = data.frame(V1=c('0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'),V2=V2)
  
  gindex          = grep('[0-9]',as.character(dat$MDC))
  bindex          = !dat$rownumber %in% gindex
  dat$MDC[bindex] = NA
  mdcnow          = data.frame(V1=unique(dat$MDC[!is.na(dat$MDC)]))
  mdc             = merge(mdcnow,mdc26,by='V1',all.x=T)
  mdc$V2          = as.character(mdc$V2)
  
  dat$MDC_name    = as.factor(dat$MDC)
  levels(dat$MDC_name) = mdc$V2
  #===========================================================
  
  #create a column TOTCHG_bin from TOTCHG
  mybreaks = seq(0,100000,10000)
  mybreaks = c(mybreaks,250000,500000,7000000)
  
  mylabels = as.character(mybreaks)
  mylabels = mylabels[2:length(mylabels)]
  mylabels = paste(mylabels,'k',sep='')
  
  dat$TOTCHG_bin = cut(as.numeric(dat$TOTCHG),breaks=mybreaks, labels=mylabels )
  
  #===========================================================
  # create a column LOS_bin from LOS 
  
  dat['LOS_bin'] = NA
  
  mybreaks       = c(0,2,4,6,10,20,365)
  mylabels       = c('vshort','short','medium','long','vlong','extreme')
  dat$LOS_bin    = cut(as.numeric(dat$LOS),breaks=mybreaks, labels=mylabels )
  
  #===========================================================
  # create a column chfperday from charge and los 
  dat$CHGperday  = as.numeric(dat$TOTCHG)/as.numeric(dat$LOS)
  #===========================================================
  # create a column age group  'AGE_bin'
  mybreaks     = c(-1,1,18,29,49,64,200)
  mylabels     = c('0-1yrs','1-18yrs','19-29yrs','30-49yrs','50-64yrs','>=65 yrs')
  dat$AGE_bin  = cut(as.numeric(dat$AGE),breaks=mybreaks, labels=mylabels )
  
  #create a column age group  'AGE_bin2'
  mybreaks     = c(-1,26,64,200)
  mylabels     = c('<=26yrs','26-64yrs','>=65 yrs')
  dat$AGE_bin2 = cut(as.numeric(dat$AGE),breaks=mybreaks, labels=mylabels )
  
  #===========================================================
  
  
  # Chronic conditions analysis cols
  # want to look at some chronic conditions
  # create a column CHRONIC_conditions and fill it with 'Diabetes,'COPD',..etc.
  
  dat$CHRONIC_conditions <- 'Rest'
  
  d = subset(dat,dat$DXCCS1==49 | dat$DXCCS1==50)
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'Diabetes'
  
  d = subset(dat,dat$DXCCS1==101 | dat$DXCCS1==100 | dat$DXCCS1 == 108)
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'CoronaryHeartDisease'
  
  d = subset(dat,dat$DXCCS1==98 | dat$DXCCS1==99 )
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'Hypertension'
  
  d = subset(dat,dat$DXMCCS1==5 )
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'Mental_Illness'
  
  d = subset(dat,dat$DXMCCS1==2 )
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'Cancer (Neoplasms)'
  
  d = subset(dat,dat$DXCCS1==241 | dat$DXCCS1==242 | dat$DXCCS1==243)
  
  dat$CHRONIC_conditions[as.numeric(row.names(d))] = 'Opioid Poisoning'
  
  rm(d)
  #===========================================================
  # Readmission conditions analysis cols
  # want to look at some chronic conditions
  # create a column Readmittance_conditions and fill it with COPD',..etc.
  
  dat$Readmittance_conditions = 'Rest'
  
  # For medicare
  # 10 conditions with the most all-cause, 30-day readmissions for Medicare patients aged 65 years and older
  DXCCS_medicare = c('Congestive heart failure; nonhypertensive','Septicemia (except in labor)','Pneumonia (except that caused by tuberculosis or sexually transmitted disease)',
                     'Chronic obstructive pulmonary disease and bronchiectasis','Cardiac dysrhythmias','Urinary tract infections','Acute and unspecified renal failure',
                     'Acute myocardial infarction','Complication of device; implant or graft','Acute cerebrovascular disease')

  
  
  # For Medicaid
  # Ten conditions with the most all-cause, 30-day readmissions for Medicaid patients (aged 18-64 years),
  DXCCS_medicaid = c('Mood disorders','Schizophrenia and other psychotic disorders','Diabetes mellitus with complications','Other complications of pregnancy',
                     'Alcohol-related disorders','Early or threatened labor','Congestive heart failure; nonhypertensive','Septicemia (except in labor)',
                     'Chronic obstructive pulmonary disease and bronchiectasis','Substance-related disorders')

  # Private Insurance
  # Ten conditions with the most all-cause, 30-day readmissions for privately insured patients (aged 18-64 years)
  DXCCS_private = c('Maintenance chemotherapy; radiotherapy','Mood disorders','Complications of surgical procedures or medical care',
                    'Complication of device; implant or graft','Septicemia (except in labor)','Diabetes mellitus with complications',
                    'Secondary malignancies','Early or threatened labor','Pancreatic disorders (not diabetes)','Coronary atherosclerosis and other heart disease')

  # Uninsured - Uninsured: includes an insurance status of "self-pay" and "no charge."
  # Ten conditions with the most all-cause, 30-day readmissions for uninsured patients (aged 18-64 years)
  DXCCS_unins = c('Mood disorders','Alcohol-related disorders','Diabetes mellitus with complications','Pancreatic disorders (not diabetes)',
                  'Skin and subcutaneous tissue infections','Nonspecific chest pain','Schizophrenia and other psychotic disorders',
                  'Congestive heart failure; nonhypertensive','Substance-related disorders','Acute myocardial infarction')

  DXCCS_readmit = c(DXCCS_medicare,DXCCS_medicaid,DXCCS_private,DXCCS_unins)

  DXCCS_readmit = unique(DXCCS_readmit)
  
  for (r in 1:length(DXCCS_readmit)){
    #
    dat$Readmittance_conditions[dat$DXCCS_name %in% DXCCS_readmit[r]] = DXCCS_readmit[r]  # else its filled with 'Rest'
  }
  
  # dat$Readmittance_conditions is a subset of dat$DXCCS_name. These conditions are more readmission prone and we want to monitor them.
  
  #===========================================================
  # Create column Readmitted - need to identify readmit patients
  # In HCUP schema, ADATE col is empty unfortunately.
  # Assumption used-if patient comes back the same month or month after label as readmitted, coding accordingly to label as readmit
  re           = data.frame(table(dat$VisitLink))
  names(re)    = c('VisitLink','Freq')
  re           = subset(re,re$Freq>1)
  re$VisitLink = as.character(re$VisitLink)
  indre        = dat$VisitLink %in% re$VisitLink 
  
  dat['Readmitted'] = NA
  if(length(dat$Readmitted[indre]) > 0){
    dat$Readmitted[indre] = replicate(length(dat$Readmitted[indre]),'yes')
  }
  
  dat$Readmitted[is.na(dat$Readmitted)] = 'no'
  
  #===========================================================
  # create dat$Readmitted_num with 1 for yes and 0 for no
  dat$Readmitted_num = ifelse(dat$Readmitted=='yes',1,0)
  
  #===========================================================
  # create a column HOSPZIP
  zz              =  data.frame(table(dat$DSHOSPID,dat$ZIP))
  names(zz)       = c('DSHOSPID','ZIP','numpatbyzip')
  zz              = zz[order(zz$DSHOSPID,-zz$numpatbyzip),]
  ZIP_maxpatient1 = zz[match(unique(zz$DSHOSPID), zz$DSHOSPID),] #match returns indices of the first match in the compared vectors
  
  ZIP_maxpatient1$numpatbyzip = NULL  # same number of rows as number of hospitals
  names(ZIP_maxpatient1)[names(ZIP_maxpatient1)=='ZIP'] = 'HOSPZIP'  #"DSHOSPID" "HOSPZIP" 
  
  dat = merge(dat,ZIP_maxpatient1,by='DSHOSPID',all.x=T)
  #===========================================================
  # add 10 extra columns
  # creating 10 extra cols for adding more cols for vis if needed
  dat$ecol1  = -99
  dat$ecol1  = dat$LOS_pred
  dat$LOS_pred = NULL
  dat$ecol2  = -99
  dat$ecol3  = -99
  dat$ecol4  = -99
  dat$ecol5  = -99
  dat$ecol6  = -99
  dat$ecol7  = -99
  dat$ecol8  = -99
  dat$ecol9  = -99
  dat$ecol10 = -99
  
  dat$myrownum = NA
  
  dat$LOS = as.numeric(dat$LOS)
  dat$LOS = round(dat$LOS)
  dat$LOS[dat$LOS < 1] = 1
  
  return(dat)
  
}

#####################################################################
#   End of function
#####################################################################

# inputFromUSQL and outputToUSQL are dedicated named data frames respectively to pass data between USQL and R. 
# Input and output DataFrame identifier names are fixed 
# (i.e. users cannot change these predefined names of input and output DataFrame identifiers).

my_inputFromUSQL = inputFromUSQL[,-1] #drop the Par column

colsforvis  = c('KEY','AGE','FEMALE','RACE','Homeless','PSTATE','MEDINCSTQ','ZIP','DSHOSPID','VisitLink','HOSPST','PAY1','TRAN_IN','AYEAR','AMONTH','ATYPE','PointOfOriginUB04','DISPUB04','LOS','MDC','DRG','DX1','DXCCS1','DXMCCS1','PR1','PRCCS1','PRMCCS1','TOTCHG','LOS_pred')

names(my_inputFromUSQL) = colsforvis

# renaming a few columns to as they appear in HCUP data
names(my_inputFromUSQL)[names(my_inputFromUSQL)=='VISITLINK']         = 'VisitLink'
names(my_inputFromUSQL)[names(my_inputFromUSQL)=='POINTOFORIGINUB04'] = 'PointOfOriginUB04'
names(my_inputFromUSQL)[names(my_inputFromUSQL)=='HOMELESS']          = 'Homeless'
 

#######################################################################
my_inputFromUSQL$ATYPE = gsub('ATYPE_','',my_inputFromUSQL$ATYPE)  # setting the values of ATYPE to original values

#######################################################################
#  calling function fun_addcols()
dat = fun_addcols(my_inputFromUSQL)

#######################################################################
# reorder to make it consistent with the schema for data4visualization_hist.csv 
schema_pbi = c('DSHOSPID','KEY','AGE','AMONTH','ATYPE','DISPUB04','DRG','DX1','DXCCS1','HOSPST','Homeless','LOS','MDC','MEDINCSTQ','PR1','PRCCS1','PSTATE','PointOfOriginUB04','RACE','TOTCHG','VisitLink','ZIP','AYEAR','DXMCCS1','PRMCCS1','Readmitted','DXCCS_name','PRCCS_name','PRMCCS_name','DXMCCS_name','TRANSFER_IN','MDC_name','TOTCHG_bin','LOS_bin','CHGperday','AGE_bin','AGE_bin2','PAYER1','GENDER','HOSPZIP','Readmitted_num','myrownum','ecol1','ecol2','ecol3','ecol4','ecol5','ecol6','ecol7','CHRONIC_conditions','ecol8','ecol9','ecol10','Readmittance_conditions')
dat_out    = dat[,schema_pbi]


#===========================================================

# for all to be string for output
dat_out = data.frame(lapply(dat_out,as.character))

#######################################################################
# rename the colnames for usql..make then V1 V2...
names(dat_out)   = paste('V',1:ncol(dat_out),sep='')

#######################################################################
outputToUSQL =  dat_out



