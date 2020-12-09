*--------------------------------Start of do file------------------------------- 

*Capture the project current directory and name of the do file 
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

cd "`pdir'/data_raw/Comtrade"
* COMTRADE cleansing 
local myfiles : dir . files "*.csv"
foreach file of local myfiles { 
cd "`pdir'/data_raw/Comtrade"
project, original ("`pdir'/data_raw/Comtrade/`file'")
import delimited "`file'",  clear 
	sort year reporter partner
	rename tradevalueus trade 
	rename netweightkg quantity
	rename commoditycode product
	keep reporter reportercode reporteriso partner partnercode partneriso year trade quantity product
	cd "`pdir'/data_derived/Comtrade"
	save "`file'.dta" , replace 
	project, creates ("`file'.dta")
}
* Append imported comtrade files into one dataset
clear
fs *.dta 
append using `r(files)'
sort partner reporter year product 
quietly by partner reporter year product : gen dup = cond(_N ==1,0,_n)
tab dup 
drop dup 
replace partner = "C├┤te d'Ivoire" if partner == "CÃ´te d'Ivoire"
* Generate categorical variable for products and years. 
	replace product = 1 if product == 310530 // DAP
	replace product = 2 if product == 310540 // MAP
	replace product = 3 if product == 280920 // PA
	replace product = 4 if product == 2510 // PR
	replace product = 5 if product == 3103 // TSP
	drop if product == . 
	sort year product 
	drop if partneriso == ""
	drop if reporteriso == ""
* Defining the partners of Morocco (OCP)
* Generate a dummy variable for defining the partners j of mororcco (Both exporters and importers)

	gen partner_j = 0 
	* Morocco is exporter 
	replace partner_j =2 if reporter == "Morocco" & partnercode != 0 
	* Morocco is importer 
	replace partner_j =1 if partner == "Morocco" & partnercode !=  0 

cd "`pdir'/data_derived/merge"

save trade2, replace 
project, creates("trade2.dta") preserve

*** Aggregation 1 : fertilizers = Dap + Map + tsp (1,2,5)

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

save trade2_agg1, replace 
project, creates("trade2_agg1.dta") preserve

*** Aggregation 2 : OCP products

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

save trade2_agg2, replace
project, creates("trade2_agg2.dta") preserve


*--------------------------------End of do file------------------------------- 

