tempVariability <- function( VarSelection, obfuscation, observations, clinical, demographics, period, absoluteValue ){

  if( VarSelection == "mental"){
    colnames( mentalDisorder )[2] <- "description"
    observations <- observations %>%
      filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0, concept_code %in% mentalDisorder$ICD10) %>%
      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
      select( patient_num, pair, concept_code )
  }else if( VarSelection == "all"){
    observations <- observations %>%
      filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0) %>%
      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
      select( patient_num, pair, concept_code )
  }else if( VarSelection == "phecodes"){
    observations <- observations %>%
      filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0) %>%
      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
      select( patient_num, pair, concept_code )
  }else if( VarSelection == "medication"){
    observations <- observations %>%
      filter( concept_type == 'MED-CLASS', days_since_admission >= 0) %>%
      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
      select( patient_num, pair, concept_code )
  }else if( VarSelection == "category"){
    observations <- observations %>%
      filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0) %>%
      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
      select( patient_num, pair, concept_code )
    observations$concept_code <- ifelse( substr( observations$concept_code,1,1) %in% c("D", "H"), substr( observations$concept_code,1,2), substr( observations$concept_code,1,1))
    observations <- observations[!duplicated( observations), ]
    }
  
  observations$concept_code <- as.character( observations$concept_code)
  
  clinical <- clinical %>%
    mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
    select( patient_num, pair, calendar_date, severe, deceased)
  
  final <- merge( observations, clinical, by="pair") 
  
  final <- final %>%
    mutate(patient_num = patient_num.x) %>%
    select(patient_num, concept_code, calendar_date, severe )
  
  demographics <- unique( demographics %>%
                            select( patient_num, age_group, sex ) )
  
  demographics$subset <- ifelse( demographics$patient_num %in% final$patient_num, "Subset Yes", "Subset No")
  
  ## Create the summary table 1
  tbl1 <- summaryTableOne( df = demographics, obfuscation = obfuscation, stratifyBy = VarSelection)
  
  final <- EHRtemporalVariability::formatDate(
    input         = final,
    dateColumn    = "calendar_date",
    dateFormat = "%Y-%m-%d"
  )
  
  ## Extract number of month or number of week
  if(  period == "week"){
    final$num  <- format( as.Date( final$calendar_date), "%U")
    }else if(  period == "month"){
      final$num  <- format( as.Date( final$calendar_date), "%m")
    }

  ###
  final <- final %>% 
    dplyr::group_by(patient_num, concept_code, num ) %>% 
    dplyr::mutate( minDate = min(calendar_date)) %>%
    dplyr::select( patient_num, concept_code, minDate, num ) %>%
    unique()
  
  
  
  ## Remove the patient identifier
  final <- final[, -1]

  if( VarSelection != "medication"){
  
    if( VarSelection == "mental"){
      final <- merge( final, mentalDisorder, by.x = "concept_code", by.y = "ICD10")
      final$description <- as.character(final$description)
      final$descriptionShort <- substr(final$description, 1, 40)
    }else if( VarSelection ==  "all"){
      final <- final
    }else if( VarSelection == "phecodes"){
      phecode <- read.csv("public-data/phecode_icd10.csv", colClasses = "character")
      phecode$Phenotype <- ifelse( phecode$Phenotype == "", phecode$ICD10.String, phecode$Phenotype )
      phecode <- unique( phecode %>%
                           mutate( concept_code = ICD10, description = Phenotype ) %>%
                           select( concept_code, PheCode, description ))
      final <- merge( final, phecode)
      final$description <- as.character(final$description)
      final$descriptionShort <- substr(final$description, 1, 40)
    }else if( VarSelection == "category"){
      icdCategory <- read.delim("public-data/icd10Codes.txt", header = FALSE, colClasses = "character")
      colnames(icdCategory) <- c("concept_code", "Description")
      final <- merge( final, icdCategory, by = "concept_code")
      final <- final[!duplicated( final ), ]  
    }
    

  }  
  
  probMaps <- estimateDataTemporalMap(data           = final, 
                                      dateColumnName = "minDate", 
                                      period         = period)
  if( obfuscation !=  FALSE ){
    
    for( i in 1:length(probMaps)){
      probMaps[[i]]@countsMap[probMaps[[i]]@countsMap > 0 & probMaps[[i]]@countsMap <= obfuscation ] <- 0.5 * obfuscation
    }
  }
  names(probMaps) <- paste0( VarSelection,names(probMaps))
  
  # if( VarSelection %in% c("mental", "phecodes")){
  #   print( plotDataTemporalMap(
  #     dataTemporalMap =  probMaps[[paste0( VarSelection,"descriptionShort")]],
  #     startValue = 1,
  #     endValue = 20,
  #     colorPalette    = "Magma", 
  #     absolute = absoluteValue))
  # }else{
  #   print( plotDataTemporalMap(
  #     dataTemporalMap =  probMaps[[paste0( VarSelection,"concept_code")]],
  #     startValue = 1,
  #     endValue = 20,
  #     colorPalette    = "Magma", 
  #     absolute = absoluteValue))
  # }
  
  return( probMaps)
  
}
