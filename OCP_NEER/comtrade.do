/*--------------------------------Start of do file------------------------------- 
The following do file process the comtrade data, downloaded from https://comtrade.un.org/ 
it inputs the raw csv files, and output cleaned ready to merge stata datasets 
-----------------------------------------------------------------------------*/
*Capture the project current directory and name of the do file 
	project, doinfo 
	local pdir "`r(pdir)'"
	local dofile "`(dofile)'"

* COMTRADE cleansing : the following block imports data in csv format, process and output in stata format 

cd "`pdir'/data_raw/Comtrade"													// setting up the working directory 
local myfiles : dir . files "*.csv" 											// capturing the comtrade csv files 
foreach file of local myfiles { 												// importing each file apart 
cd "`pdir'/data_raw/Comtrade"
project, original ("`pdir'/data_raw/Comtrade/`file'") 							// the project original command tells the program that this csv
																				//	 file is not created by the do file

import delimited "`file'",  clear 												// importing the data 
																												
	sort 		year reporter partner 											//Renaming variables and keep necessary ones 		
	rename 		tradevalueus 	trade 											
	rename 		netweightkg		quantity 
	rename 		commoditycode	product
	keep 		reporter reportercode reporteriso partner partnercode ///
				partneriso year trade quantity product 
	
	cd "`pdir'/data_derived/Comtrade"
	
	save "`file'.dta" , replace  
	
	project, creates ("`file'.dta") 											// command tells the program that this do file have created the dataset
																				// so any changes in the latter will cause the do file to be run again
}

* Append imported comtrade files into one dataset
clear
fs *.dta 																		// read the data created in the folder
append using `r(files)'															// append the data created in the folder 
sort partner reporter year product 													
* Drop the duplicates if found 
quietly by partner reporter year product : gen dup = cond(_N ==1,0,_n) 			// gen the dupicated variables dup 
tab dup 																		// check the frequency of the duplicates variables 
drop if dup > 1																	// drop if any exists 
drop dup 		

* Generate categorical variable for products and years. 
	replace product = 1 if product == 310530 									// DAP
	replace product = 2 if product == 310540 									// MAP
	replace product = 3 if product == 280920 									// PA
	replace product = 4 if product == 2510 										// PR
	replace product = 5 if product == 3103 										// TSP
	drop if product == . 
	sort year product 
	drop if partneriso == "" 													// this drops regions and anything other than a country 
	drop if reporteriso == "" 													// idem
	
* Defining the partners of Morocco (OCP)
* Generate a dummy variable for defining the partners j of mororcco (Both exporters and importers)
	gen partner_j = 0 
	* Morocco is exporter 
	replace partner_j =2 if reporter == "Morocco" & partnercode != 0 			
	* Morocco is importer 
	replace partner_j =1 if partner == "Morocco" & partnercode !=  0 			

cd "`pdir'/data_derived/merge"
save trade2, replace 															// trade2 dataset saved and ready to merge
project, creates("trade2.dta") preserve

********************************************************************************

*** The first level of aggregation, where we merge together product 1, 2 and 5 as one product called phosphatic fertilizers 
list trade product if partner == "Belgium" & reporter == "Morocco" & year == 2017
replace product = 1 if product == 5 | product == 2
sort partner year product reporter
collapse (sum) quantity trade, by(year product partner partnercode partneriso reportercode reporteriso reporter)
list trade if partner == "Belgium" & reporter == "Morocco" & year == 2017
	gen partner_j = 0 
	* Morocco is exporter 
	replace partner_j =2 if reporter == "Morocco" & partnercode != 0 
	* Morocco is importer 
	replace partner_j =1 if partner == "Morocco" & partnercode !=  0 

save trade2_agg1, replace 														// trade2 first level of aggregation dataset saved and ready to merge
project, creates("trade2_agg1.dta") preserve

********************************************************************************

*** Aggregation 2 : second level of aggregation, where we consider only one product OCP products
list trade product if partner == "Belgium" & reporter == "Morocco" & year == 2017
replace product = 1 if product == 3 | product == 4
sort partner year product reporter
collapse (sum) quantity trade, by(year product partner partnercode partneriso reportercode reporteriso reporter)
list trade if partner == "Belgium" & reporter == "Morocco" & year == 2017
	gen partner_j = 0 
	* Morocco is exporter 
	replace partner_j =2 if reporter == "Morocco" & partnercode != 0 
	* Morocco is importer 
	replace partner_j =1 if partner == "Morocco" & partnercode !=  0 

save trade2_agg2, replace														// trade2 second level of aggregation dataset saved and ready to merge
project, creates("trade2_agg2.dta") preserve


*--------------------------------End of do file------------------------------- 

