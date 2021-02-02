#' Function to read the Phase 2.0 input files with patient-level data
#'
#' Given the \code{path} where the files are located it will generates
#' a \code{list} with the \code{data.frame} object of the different files.
#'
#' @param path A path were the input files are located.
#' @param separator The separator between columns (by default ",").
#' @param skip In case the file does not start with the column names, add the number of lines that should be skipped at the beggining.
#' @param verbose By default \code{FALSE}. Change it to \code{TRUE} to get an on-time log from the function.
#' @return An object of class \code{list} with the \code{data.frames}.
#' @examples
#'
#' dataSet <- readInputFiles(
#'               path      = "./",
#'               separator = ",",
#'               skip      = 1,
#'              )
#' @export readInputFiles

readInputFiles <- function( path, separator = ",", skip = 0, verbose = FALSE ){
  
  #set the working directory
  setwd(path)
  
  #check that the input files needed are in the path 
  if( verbose == TRUE){
    print( 'Checking if the files are located in the directory provided')
  }
  
  filesInDirectory <- list.files( path = "./")
  
  #for this analysis we need two of the files, patientSummary and patientObservation
  checkPatientSummary <- ifelse( "localpatientsummary.csv" %in% tolower( filesInDirectory ), "OK", "File missing")
  
  if(checkPatientSummary == "OK"){
    if(verbose== TRUE){
    print("LocalPatientSummary.csv file in directory")
    }
  }else{
    print("LocalPatientSummary.csv file not present in the directory. Please check if the file name and the 
                                       directory are correct")
    stop()
  }
  
  checkPatientObservations <- ifelse( "localpatientobservations.csv" %in% tolower( filesInDirectory ), "OK", "File missing")
  
  if(checkPatientObservations == "OK"){
    if(verbose== TRUE){
      print("LocalPatientObservations.csv file in directory")
    }
  }else{
    print("LocalPatientObservations.csv file not present in the directory. Please check if the file name and the 
                                       directory are correct")
    stop()
  }
  
  checkPatientClinicalCourse <- ifelse( "localpatientclinicalcourse.csv" %in% tolower( filesInDirectory ), "OK", "File missing")
  
  if(checkPatientClinicalCourse == "OK"){
    if(verbose== TRUE){
      print("LocalPatientClinicalCourse.csv file in directory")
    }
  }else{
    print("LocalPatientClinicalCourse.csv file not present in the directory. Please check if the file name and the 
                                       directory are correct")
    stop()
  }
  
  #read the files 
  if( verbose == TRUE){
    print( 'Reading LocalPatientSummary, LocalPatientObservations and LocalPatientClinicalCourse files')
  }
  
  patientSummary <- read.delim("LocalPatientSummary.csv", sep = separator, skip = skip)
  patientObservations <- read.delim("LocalPatientObservations.csv", sep = separator, skip = skip)
  patientClinicalCourse <- read.delim("LocalPatientClinicalCourse.csv", sep = separator, skip = skip)
  
  if( verbose == TRUE){
    print( paste0( "LocalPatientsummary file contains: ", nrow( patientSummary ), " rows and ", ncol( patientSummary ), " columns."))
    print( paste0( "LocalPatientobservation file contains: ", nrow( patientObservations ), " rows and ", ncol( patientObservations ), " columns."))
    print( paste0( "LocalPatientClinicalCourse file contains: ", nrow( patientClinicalCourse ), " rows and ", ncol( patientClinicalCourse ), " columns."))
  }
  
  #return it as a list
  files <- list( patientSummary, patientObservations, patientClinicalCourse )
  
  if( verbose == TRUE){
    print( "A list wit the three data.frames read is being generated")
  }
  
  return( files )
}
