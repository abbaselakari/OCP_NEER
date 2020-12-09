*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"


* Merge aggregation level 1
cd "`pdir'/data_derived/merge"
project, uses ("IFA.dta")
use IFA, clear 
merge 1:m year product partnercode using trade2 , gen(_merge_trade)
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
save ifa-trade2, replace 
project, creates("ifa-trade2.dta")


* Merge aggregation level 2
project, uses("IFA_agg1.dta")
use IFA_agg1, clear 
merge 1:m year product partnercode using trade2_agg1 , gen(_merge_trade)
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
save ifa-trade2_agg1, replace 
project, creates("ifa-trade2_agg1.dta")

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
