*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month_weights.dta")
project, uses("`pdir'/data_derived/deflators/cpi_month.dta")

cd "`pdir'/data_derived/neer/index/geometric"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
cd "`pdir'/data_derived/neer/index/geometric/month"
use exchange_month_`file' , clear 
cd "`pdir'/data_derived/deflators"
merge 1:1 partner month product using cpi_month, gen(_merge_rate) force
keep if _merge_rate == 3
drop _merge_rate  
bysort partner product : gen id = _N 											// identifying countries with missing data 
drop if id < 242																// dropping countries 

	* rescaling to 1 after weights being dropped in merge
	bysort group : egen s = total(double_weights)
	gen p = 0 
	replace p = 1 if double_weights != 0 
	bysort group : egen r = total(p)
	bysort group : gen 	e = (1-s)/r
	replace double_weights = double_weights + e if double_weights != 0
	bysort group : egen q = total(double_weights)
	tab q
	drop p q r s e 
	* rescaling to 1 after weights being dropped in merge
	gen p = 0 
	bysort group : egen s = total(simple_weights)
	replace p = 1 if simple_weights != 0 
	bysort group : egen r = total(p)
	bysort group : gen 	e = (1-s)/r
	replace simple_weights = simple_weights + e if simple_weights != 0
	bysort group : egen q = total(simple_weights)
	tab q
	drop p q r s e 

*** Compute the REER double arithmetic 
gen d_exchange = exchange*deflator
bysort partner product (month) : gen diff_exchange = (d_exchange/d_exchange[_n-1])-1 if _n > 1
drop if diff_exchange == .
gen pdt = diff_exchange*double_weights
bysort group : egen var_reer_double = sum(pdt)
bysort group : egen sum_weights_double = sum(double_weights)
bysort group : replace var_reer_double = var_reer_double/sum_weights_double


*** Compute the REER simple arithmetic 
gen pdt_s = diff_exchange*simple_weights
bysort group : egen var_reer_simple = sum(pdt_s)
bysort group : egen sum_weights_simple = sum(simple_weights)
bysort group : replace var_reer_simple = var_reer_simple/sum_weights_simple

cd "`pdir'/data_derived/reer/variation/arithmetic/month"
save reer_variation_`file', replace

* Change to base first month double
	drop if month < ym(2002,01)
	sort partner product month
	gen base = 100 
	levelsof month, local(Month)
	foreach month of local Month {
	bysort partner product (month) : replace base = base[_n-1]*(var_reer_double+1) if month == `month'+1
	}
	rename base reer_double
sort group
* Change to base first month simple
	gen base = 100 
	levelsof month, local(Month)
	foreach month of local Month {
	bysort partner product (month) : replace base = base[_n-1]*(var_reer_simple+1) if month == `month'+1
	}
	rename base reer_simple
sort group
cd "`pdir'/data_derived/reer/index/arithmetic/month"
save reer_`file', replace
cd "`pdir'/data_derived/neer/index/geometric/month"
}

project, creates("`pdir'/data_derived/reer/index/arithmetic/month/reer_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/index/arithmetic/month/reer_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/index/arithmetic/month/reer_weights.dta")
project, creates("`pdir'/data_derived/reer/variation/arithmetic/month/reer_variation_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/variation/arithmetic/month/reer_variation_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/variation/arithmetic/month/reer_variation_weights.dta")
