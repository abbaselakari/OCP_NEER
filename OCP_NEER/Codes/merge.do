* Do file for merging all datasets
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

* First merging exchange rate data and comtrade data
cd "`pdir'/data_derived/neer/index/geometric/year"
project, uses("exchange_year.dta")
use exchange_year, clear
cd "`pdir'/data_derived/deflators"
project, uses("cpi_year.dta") preserve
merge 1:1 reporter year product using cpi_year, gen(_merge_cpi)
tab reporter if _merge_cpi == 1
tab reporter if _merge_cpi == 2
keep if _merge_cpi == 3
bysort reporter product : gen id = _N
tab reporter if id < 10, sum(id)
drop if id < 10
drop id
cd "`pdir'/data_derived/merge"
save temp, replace 

* Merge exchange and deflators with comtrade data 
cd "`pdir'/data_derived/merge"
local myfiles : dir . files "trade2*"
foreach file of local myfiles { 
project, uses("`file'") 
use `file', clear                                 
merge m:1 reporter year product using temp, gen(_merge_exchange)
tab reporter if _merge_exchange == 1
tab reporter if _merge_exchange == 2
drop if _merge_exchange == 2
replace partneriso = "none" if _merge_exchange == 1
replace partnercode = 9999 if _merge_exchange == 1
replace partner = "none" if _merge_exchange == 1
replace trade = 0 if _merge_exchange == 1
replace quantity = 0 if _merge_exchange == 1
replace partner_j = 0 if _merge_exchange == 1 
drop _merge_cpi _merge_exchange
save `file', replace
}

