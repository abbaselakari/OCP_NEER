/*--------------------------------Start of do file------------------------------- 
The purpose of this do file is to merge both the comtrade data and the IFA one, 
merging is done by the importer level, since importers informations on production
are the ones found in the ifa dataset
-----------------------------------------------------------------------------*/

project, doinfo 																// capturing project information
local pdir "`r(pdir)'"															// working directory
local dofile "`(dofile)'"														// name of the dofile 


* Merge aggregation level 1 : 
cd "`pdir'/data_derived/merge"													// setting up the working directory 
project, uses ("IFA.dta")
use IFA, clear 
merge 1:m year product partnercode using trade2 , gen(_merge_trade)				// merge with comtrade without aggregation 
keep if _merge_trade == 3														// keep only matched entries 
drop _merge_trade
sort reporter year product 

* generate id variable for year product sample
egen t_p_group = group(year product) 
replace trade = trade/1000 														// trade values are expressed in us dollars in comtrade 
replace quantity = quantity/1000 												// quantities in comtrade are expressed in kg in comtrade 
replace Imports = Imports*1000 													// qties in ifa are expressed in 1000 tones in ifa
replace Exports = Exports*1000 													// idem 
replace Production = Production*1000 											// idem 
replace Homedeliveries = Homedeliveries*1000
replace ApparentConsumption = ApparentConsumption*1000
drop if Imports == 0 & trade > 0												// drop any bliateral trade information where the importer is reporting that is 0 in ifa Imports variable 
																				// this is important because otherwise the weights will compute negative values 
save ifa-trade2, replace 														// save the data to be inputted for weights computations 
project, creates("ifa-trade2.dta")

********************************************************************************

* Merge aggregation level 2
project, uses("IFA_agg1.dta")
use IFA_agg1, clear 
merge 1:m year product partnercode using trade2_agg1 , gen(_merge_trade)
keep if _merge_trade == 3
drop _merge_trade
sort reporter year product 

* generate id variable for year product sample
egen t_p_group = group(year product) 
replace trade = trade/1000 														// getting everything to tonnes. 
replace quantity = quantity/1000 												// quantities in comtrade are expressed in kg 
replace Imports = Imports*1000 													// qties in ifa are expressed in 1000 tones
replace Exports = Exports*1000 													// idem 
replace Production = Production*1000 											// idem 
replace Homedeliveries = Homedeliveries*1000
replace ApparentConsumption = ApparentConsumption*1000
drop if Imports == 0 & trade > 0
save ifa-trade2_agg1, replace 
project, creates("ifa-trade2_agg1.dta")

********************************************************************************

* Merge aggregation level 3
project, uses("IFA_agg2.dta")
use IFA_agg2, clear 
merge 1:m year product partnercode using trade2_agg2 , gen(_merge_trade)
keep if _merge_trade == 3
drop _merge_trade
sort reporter year product 

* generate id variable for year product sample
egen t_p_group = group(year product) 
replace trade = trade/1000 
replace quantity = quantity/1000 // quantities in comtrade are expressed in kg 
replace Imports = Imports*1000 // qties in ifa are expressed in 1000 tones
replace Exports = Exports*1000 // idem 
replace Production = Production*1000 // idem 
replace Homedeliveries = Homedeliveries*1000
replace ApparentConsumption = ApparentConsumption*1000
drop if Imports == 0 & trade > 0
save ifa-trade2_agg2, replace 
project, creates("ifa-trade2_agg2.dta")

*--------------------------------End of do file------------------------------- 
