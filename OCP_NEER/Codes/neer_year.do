*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/weights.dta")

cd "`pdir'/data_derived/neer/year"
*** Merge with weights Year 
project, uses("`pdir'/data_derived/neer/year/exchange_year.dta")
use exchange_year , clear 
cd "`pdir'/data_derived/neer"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
	merge 1:m partner year using  `file', gen(_merge_rate)
	keep if _merge_rate == 3
	drop _merge_rate 
	drop if double_weights == .
	drop if simple_weights == . 
	*Compute the NEER 
	bysort t_p_group : gen pdct = exchange^double_weights
	bysort t_p_group : gen neer = pdct[1]
	bysort t_p_group : replace neer = neer[_n-1] * pdct if _n > 1
	bysort t_p_group : replace neer = neer[_N]
	cd "`pdir'/data_derived/neer/year"
	save neer_year_`file', replace
	project, creates("`pdir'/data_derived/neer/year/neer_year_`file'") 
	use exchange_year , clear 
	cd "`pdir'/data_derived/neer"
}

*--------------------------------End of do file------------------------------- 
