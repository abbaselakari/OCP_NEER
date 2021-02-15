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
drop _merge_rate 
drop  pdct 
*** Compute the REER DOUBLE
egen group = group(year product)
bysort group : gen d_exchange = exchange*deflator
bysort group : gen pdct = d_exchange^double_weights
bysort group : gen reer_double = pdct[1]
bysort group : replace reer_double = reer_double[_n-1] * pdct if _n > 1
bysort group : replace reer_double = reer_double[_N]

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
sort group

*** Compute the REER SIMPLE
drop pdct_s
bysort group : gen pdct_s = d_exchange^simple_weights
bysort group : gen reer_simple = pdct_s[1]
bysort group : replace reer_simple = reer_simple[_n-1] * pdct_s if _n > 1
bysort group : replace reer_simple = reer_simple[_N]

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
sort group

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
