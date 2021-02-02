summaryTableOne <- function( df, obfuscation, stratifyBy ){
  
  df$subset <- factor( df$subset, levels=c("Subset Yes", "Subset No"), labels= c(stratifyBy, paste0( "No ",stratifyBy)))
  table_one_vars <- c("sex","age_group")
  
  if( stratifyBy != "PheWAS code"){
    table_one <- tableone::CreateTableOne(data=df,vars=table_one_vars,strata="subset")
  }else{
    table_one <- tableone::CreateTableOne(data=df,vars=table_one_vars)
    
  }
  
  if( obfuscation == FALSE ){
    export_table_one <- print(table_one,showAllLevels=TRUE,formatOptions=list(big.mark=","), 
                              test = FALSE)
    }else{
      export_table_one <- print(table_one,showAllLevels=TRUE,formatOptions=list(big.mark=","), 
                                test = FALSE, format = "p")
  }
  return( export_table_one )
}