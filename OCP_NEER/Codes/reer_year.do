*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights.dta")
project, uses("`pdir'/data_derived/deflators/cpi_year.dta")

cd "`pdir'/data_derived/neer/index/geometric/year"

local myfiles : dir . files "neer*.dta"
foreach file of local myfiles {
use `file', clear 
cd "`pdir'/data_derived/deflators"
merge 1:1 partner year product using cpi_year, gen(_merge_rate) force
keep if _merge_rate == 3
drop _merge_rate pdct 
*** Compute the REER DOUBLE
	bysort _p_group : egen s = total(double_weights)
	gen p = 0 
	replace p = 1 if double_weights != 0 
	bysort _p_group : egen r = total(p)
	bysort _p_group : gen 	e = (1-s)/r
	replace double_weights = double_weights + e if double_weights != 0
	bysort _p_group : egen q = total(double_weights)
	tab q
	drop p q r s e 
	* rescaling to 1 after weights being dropped and added for simple
	gen p = 0 
	bysort _p_group : egen s = total(simple_weights)
	replace p = 1 if simple_weights != 0 
	bysort _p_group : egen r = total(p)
	bysort _p_group : gen 	e = (1-s)/r
	replace simple_weights = simple_weights + e if simple_weights != 0
	bysort _p_group : egen q = total(simple_weights)
	tab q
	drop p q r s e 

bysort _p_group : gen d_exchange = exchange*deflator
bysort _p_group : gen pdct = d_exchange^double_weights
bysort _p_group : gen reer_double = pdct[1]
bysort _p_group : replace reer_double = reer_double[_n-1] * pdct if _n > 1
bysort _p_group : replace reer_double = reer_double[_N]

* Change to base first month 
bysort  product  : gen base = reer_double if year == 2002
levelsof product, local(P)
foreach p of local P {
levelsof base if product == `p' , local(F)
foreach f of local F {
replace base = `f' if base == . & product == `p'
	}
}
replace reer_double = (reer_double/base)*100
drop base
sort _p_group

*** Compute the REER SIMPLE
drop pdct_s
bysort _p_group : gen pdct_s = d_exchange^simple_weights
bysort _p_group : gen reer_simple = pdct_s[1]
bysort _p_group : replace reer_simple = reer_simple[_n-1] * pdct_s if _n > 1
bysort _p_group : replace reer_simple = reer_simple[_N]

* Change to base first month 
bysort  product  : gen base = reer_simple if year == 2002
levelsof product, local(P)
foreach p of local P {
levelsof base if product == `p' , local(F)
foreach f of local F {
replace base = `f' if base == . & product == `p'
	}
}
replace reer_simple = (reer_simple/base)*100
drop base
sort _p_group

cd "`pdir'/data_derived/reer/index/geometric/year"
save reer_`file', replace
drop if year < 2002 
* for double
sort product year	
bysort product (year) : gen var_reer_double = (reer_double/reer_double[_n-1])-1
replace var_reer_double = . if year == 2002
bysort product (year) : replace var_reer_double = var_reer_double[_n-1] if var_reer_double == 0 & _n>1
* for simple
sort product year	
bysort product (year) : gen var_reer_simple = (reer_simple/reer_simple[_n-1])-1
replace var_reer_simple = . if year == 2002
bysort product (year) : replace var_reer_simple = var_reer_simple[_n-1] if var_reer_simple == 0 & _n>1

cd "`pdir'/data_derived/reer/variation/geometric/year"	
save reer_year_variation_`file', replace 
cd "`pdir'/data_derived/neer/index/geometric/year"
}

project, creates("`pdir'/data_derived/reer/variation/geometric/year/reer_year_variation_neer_year_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/variation/geometric/year/reer_year_variation_neer_year_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/variation/geometric/year/reer_year_variation_neer_year_weights.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights.dta")
