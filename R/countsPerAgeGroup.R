countsPerAgeGroup <- function( observationFile, clinicalFile, demogFile, obfuscation, type ){
 
    observations <- unique( obs_raw %>%
                              filter( concept_type == 'DIAG-ICD10', days_since_admission >= 0) %>%
                              mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
                              select( patient_num, pair, days_since_admission, concept_code ))
    
    observations$concept_code <- ifelse( substr( observations$concept_code,1,1) %in% c("D", "H"), substr( observations$concept_code,1,2), substr( observations$concept_code,1,1))
    observations <- observations[!duplicated( observations), ]
    
    clinical <- clinical_raw %>%
    mutate( pair = as.character(paste0( patient_num, "*",days_since_admission))) %>%
    select( patient_num, pair, calendar_date)
    
    final <- merge( observations, clinical, by="pair") 
  
  final <- final %>%
    mutate(patient_num = patient_num.x) %>%
    select(patient_num, concept_code, calendar_date)
  
  final$year_month <- as.factor( paste0( sapply(strsplit( as.character(final$calendar_date), "[-]"), '[', 1), "-", 
                                         sapply(strsplit( as.character(final$calendar_date), "[-]"), '[', 2)))
  
  
  demogFile <- demogFile[, c("patient_num", "admission_date", "age_group")]
  colnames(demogFile)[2] <- "calendar_date"
  
  final <- merge( final, demogFile, by = c("patient_num", "calendar_date"))
  
  counts_age_month <- final %>% dplyr::group_by( year_month, age_group, concept_code ) %>%
    dplyr::summarise(distinct_patients = n_distinct(patient_num)) %>%
    dplyr::arrange( desc(distinct_patients), .by_group = FALSE)
 
  counts_age <- final %>% dplyr::group_by( age_group, concept_code ) %>%
    dplyr::summarise(distinct_patients = n_distinct(patient_num)) %>%
    dplyr::arrange( desc(distinct_patients), .by_group = FALSE)
  
  if( obfuscation != FALSE){
    counts_age$distinct_patients <- ifelse( counts_age$distinct_patients < obfuscation, 0.5 * obfuscation, counts_age$distinct_patients)
    counts_age_month$distinct_patients <- ifelse( counts_age_month$distinct_patients < obfuscation, 0.5 * obfuscation, counts_age_month$distinct_patients)
  }
  counts <- list()
  counts[[1]] <- counts_age
  counts[[2]] <- counts_age_month
  
 
  return(counts)
  
}
