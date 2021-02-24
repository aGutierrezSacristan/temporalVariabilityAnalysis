# temporalVariabilityAnalysis
4CE Phase 2.1 Temporal Variability Analysis in Children
These analysis are done using the R library EHRtemporalVariability. For detail information about this library you can check the publication (https://doi.org/10.1093/gigascience/giaa079): Carlos Sáez, Alba Gutiérrez-Sacristán, Isaac Kohane, Juan M García-Gómez, Paul Avillach. EHRtemporalVariability: delineating temporal data-set shifts in Electronic Health Records. GigaScience, Volume 9, Issue 8, August 2020

## How to run this first approach?
First, clone the repository: git clone https://github.com/aGutierrezSacristan/temporalVariabilityAnalysis

Then open the file monthlytemporalVariability.Rmd and:
- add your site ID to the title
- change the myinputFiles to the directory where your phase 2.1 data is located
- determine the obfuscation threshold: 
    - obfuscation = FALSE if no obfuscation
    - the numeric value of the obfuscation threshold if any; e.g. obfuscation = 3
    Make sure you comment the existing obfuscation line, set up as FALSE
- change the absoluteValue variable as TRUE or FALSE to indicate if you want to visualize in the heatmaps the counts (absoluteValue = TRUE), or the frequencies (absoluteValue = FALSE)


After all these changes are done, run the monthlytemporalVariability.Rmd, as an output an html file named: monthlytemporalVariability.html and a RData file named myExport_month.RData should be generated. 



