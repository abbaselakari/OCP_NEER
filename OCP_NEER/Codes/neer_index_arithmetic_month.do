*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights_agg1.dta")

*** Merge with weights months 
cd "`pdir'/data_derived/neer/index/geometric"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
cd "`pdir'/data_derived/neer/index/geometric/month"
use exchange_month_`file' , clear 
*** Compute the NEER arithmetic mean
bysort partner product (month) : gen diff_exchange = (exchange/exchange[_n-1])-1 if _n > 1
drop if diff_exchange == .
*egen _p_group = group(month product)
gen pdt = diff_exchange*double_weights
bysort group : egen var_neer_double = sum(pdt)	
bysort group : egen sum_weights_double = sum(double_weights)
bysort group : replace var_neer_double = var_neer_double/sum_weights_double
** Compute the NEER arithmetic mean simple weights 
gen pdt_s = diff_exchange*simple_weights
bysort group : egen var_neer_simple = sum(pdt_s)
bysort group : egen sum_weights_simple = sum(simple_weights)
bysort group : replace var_neer_simple = var_neer_simple/sum_weights_simple

cd "`pdir'/data_derived/neer/variation/arithmetic/month"
save neer_month_variation_`file', replace

	* Change to base first month double
	drop if month < ym(2002,01)
	sort group
	gen base = 100 
	levelsof month, local(Month)
	foreach month of local Month {
	bysort partner product (month) : replace base = base[_n-1]*(var_neer_double+1) if month == `month'+1
	}
	rename base neer_double
	sort group
	* Change to base first month simple
	gen base = 100 
	levelsof month, local(Month)
	foreach month of local Month {
	bysort partner product (month) : replace base = base[_n-1]*(var_neer_simple+1) if month == `month'+1
	}
	rename base neer_simple
	sort group

cd "`pdir'/data_derived/neer/index/arithmetic/month"
save neer_month_`file', replace
cd "`pdir'/data_derived/neer/index/geometric/"
}

project, creates("`pdir'/data_derived/neer/index/arithmetic/month/neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/neer/index/arithmetic/month/neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/neer/index/arithmetic/month/neer_month_weights.dta")
