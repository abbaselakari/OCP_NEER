*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights.dta")
project, uses("`pdir'/data_derived/deflators/cpi_month.dta")

cd "`pdir'/data_derived/neer/index/geometric/month"

local myfiles : dir . files "neer*.dta"
foreach file of local myfiles {
use `file', clear 
cd "`pdir'/data_derived/deflators"
merge 1:1 partner month product using cpi_month, gen(_merge_rate) force
keep if _merge_rate == 3
drop _merge_rate pdct
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

*** Compute the REER double
bysort group : gen d_exchange = exchange*deflator
bysort group : gen pdct = d_exchange^double_weights
bysort group : gen reer_double = pdct[1]
bysort group : replace reer_double = reer_double[_n-1] * pdct if _n > 1
bysort group : replace reer_double = reer_double[_N]

* Change to base first month 
bysort  product  : gen base = reer_double if month == ym(2002,01)
levelsof product, local(P)
foreach p of local P {
levelsof base if product == `p' , local(F)
foreach f of local F {
replace base = `f' if base == . & product == `p'
	}
}
replace reer_double = (reer_double/base)*100
drop base
sort group

*** Compute the REER simple
drop pdct_s
bysort group : gen pdct_s = d_exchange^simple_weights
bysort group : gen reer_simple = pdct_s[1]
bysort group : replace reer_simple = reer_simple[_n-1] * pdct_s if _n > 1
bysort group : replace reer_simple = reer_simple[_N]

* Change to base first month 
bysort  product  : gen base = reer_simple if month == ym(2002,01)
levelsof product, local(P)
foreach p of local P {
levelsof base if product == `p' , local(F)
foreach f of local F {
replace base = `f' if base == . & product == `p'
	}
}
replace reer_simple = (reer_simple/base)*100
drop base
sort group
cd "`pdir'/data_derived/reer/index/geometric/month"
save reer_month_`file', replace
drop if month < ym(2002,01) 
* for double
sort product month	
bysort product (month) : gen var_reer_double = (reer_double/reer_double[_n-1])-1
replace var_reer_double = . if month == ym(2002,01)
bysort product (month) : replace var_reer_double = var_reer_double[_n-1] if var_reer_double == 0 & _n>1
replace var_reer_double = 0 if var_reer_double == . 
* for simple 
bysort product (month) : gen var_reer_simple = (reer_simple/reer_simple[_n-1])-1
replace var_reer_simple = . if month == ym(2002,01)
bysort product (month) : replace var_reer_simple = var_reer_simple[_n-1] if var_reer_simple == 0 & _n>1
replace var_reer_simple = 0 if var_reer_simple == . 

cd "`pdir'/data_derived/reer/variation/geometric/month"
save reer_month_variation_`file', replace
cd "`pdir'/data_derived/neer/index/geometric/month"
}

project, creates("`pdir'/data_derived/reer/variation/geometric/month/reer_month_variation_neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/variation/geometric/month/reer_month_variation_neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/variation/geometric/month/reer_month_variation_neer_month_weights.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/month/reer_month_neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/month/reer_month_neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/month/reer_month_neer_month_weights.dta")
