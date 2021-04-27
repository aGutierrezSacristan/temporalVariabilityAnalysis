countsPerPatientMonth <- function( observationFile, clinicalFile, obfuscation, type ){
  
  if(type == "diagnosis"){
    observations <- unique( obs_raw %>%
                              filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0) %>%
                              mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
                              select( patient_num, pair, days_since_admission, concept_code ))
   
  }else if(type == "medication"){
    observations <- unique( obs_raw %>%
                      filter( concept_type == 'MED-CLASS', days_since_admission >= 0) %>%
                      mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
                      select( patient_num, pair, days_since_admission, concept_code ))
    
  } 
  
  clinical <- clinical_raw %>%
    mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
    select( patient_num, pair, calendar_date, severe, deceased)
  
  final <- merge( observations, clinical, by="pair") 
  
  final <- final %>%
    mutate(patient_num = patient_num.x) %>%
    select(patient_num, concept_code, calendar_date)
  
  final$year_month <- as.factor( paste0( sapply(strsplit( as.character(final$calendar_date), "[-]"), '[', 1), "-", 
                                         sapply(strsplit( as.character(final$calendar_date), "[-]"), '[', 2)))
  
  counts <- final %>% dplyr::group_by( year_month ) %>%
    dplyr::summarise(distinct_patients = n_distinct(patient_num)) %>%
    dplyr::arrange( desc(distinct_patients), .by_group = FALSE)
  
  if( obfuscation != FALSE){
    counts$distinct_patients <- ifelse( counts$distinct_patients < obfuscation, 0.5 * obfuscation, counts$distinct_patients)
  }
  counts <- list(counts)
  return( counts )
  
  }
