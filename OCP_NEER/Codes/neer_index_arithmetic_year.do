*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/exchange_year_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/exchange_year_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/exchange_year_weights.dta")

cd "`pdir'/data_derived/neer/index/geometric"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
cd "`pdir'/data_derived/neer/index/geometric/year"
use exchange_year_`file', clear
	*** Compute the NEER arithmetic mean double weights
	bysort partner product (year) : gen diff_exchange = (exchange/exchange[_n-1])-1 if _n > 1
	drop if diff_exchange == .
	gen pdt = diff_exchange*double_weights
	bysort _p_group : egen var_neer_double = sum(pdt)
	bysort _p_group : egen sum_weights_double = sum(double_weights)
	bysort _p_group : replace var_neer_double = var_neer_double/sum_weights_double
	*** Compute the NEER arithmetic mean simple weights
	gen pdt_s = diff_exchange*simple_weights
	bysort _p_group : egen var_neer_simple = sum(pdt_s)
	bysort _p_group : egen sum_weights_simple = sum(simple_weights)
	bysort _p_group : replace var_neer_simple = var_neer_simple/sum_weights_simple
	cd "`pdir'/data_derived/neer/variation/arithmetic/year"
	save neer_year_variation_`file', replace
	project, creates("`pdir'/data_derived/neer/variation/arithmetic/year/neer_year_variation_`file'") preserve

	* Change to base first month double
	drop if year < 2002
	gen base = 100 
	levelsof year, local(Year)
	foreach year of local Year {
	bysort partner product (year) : replace base = base[_n-1]*(var_neer_double+1) if year == `year'+1
	}
	rename base neer_double
	* Change to base first month simple
	gen base = 100 
	levelsof year, local(Year)
	foreach year of local Year {
	bysort partner product (year) : replace base = base[_n-1]*(var_neer_simple+1) if year == `year'+1
	}
	rename base neer_simple
	sort _p_group
	cd "`pdir'/data_derived/neer/index/arithmetic/year"
	save neer_year_`file', replace
	project, creates("`pdir'/data_derived/neer/index/arithmetic/year/neer_year_`file'") 
}

