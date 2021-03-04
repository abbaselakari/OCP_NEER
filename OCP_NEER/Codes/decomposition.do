*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/year/neer_year_weights.dta")
project, uses("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights_agg1.dta")
project, uses("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights_agg2.dta")
project, uses("`pdir'/data_derived/reer/index/geometric/year/reer_neer_year_weights.dta")

* NEER variation decompostion graphs
cd "`pdir'/data_derived/neer/index/geometric/year"
local myfiles : dir . files "neer*.dta"
foreach file of local myfiles {
use `file', clear
levelsof product if t_p_group != ., local(P)
foreach p of local P { 
use `file', clear
keep if product == `p'
drop if year < 2002 | year > 2018

gen ln_neer_double = log(neer_double)
gen ln_exchange = log(exchange)
bysort partner (year) : gen diff_exchange = exchange/exchange[_n-1] if _n > 1
replace diff_exchange = ln_exchange if diff_exchange == .
gen ln_diff_exchange = log(diff_exchange)
bysort partner (year) : gen delta = double_weights - double_weights[_n-1] if _n > 1
replace delta = double_weights if delta == .
bysort partner (year) : gen var_term = (double_weights[_n-1]*ln_diff_exchange)+(delta*ln_exchange)
replace var_term = 0 if var_term == .
drop if var_term == 0 

bysort year : egen sum_var_term = sum(var_term)
gen sum11 = ln_neer_double - ln_neer_double[_n-1] 
bysort year : replace sum11 = sum11[_n-1] if sum11 == 0 & _n>1
replace sum11 = 0 if sum11 == .
tw (line sum_var_term year) (line sum11 year)

gen var_term_abs = abs(var_term)
bysort year : egen rank = rank(-var_term_abs)
bysort year : drop if rank > 5
graph bar var_term, over(partner, label(labsize(tiny))) over(year, label(labsize(tiny))) asyvars stack legend(rows(4) colfirst) /// 
title("NEER variation decomposition")
cd "`pdir'/results/variation decomposition/neer"
graph export "`file' NEER variation decomposition of `p'.pdf", replace 
cd "`pdir'/data_derived/neer/index/geometric/year"
}
}

* NEER variation decompostion graphs
cd "`pdir'/data_derived/reer/index/geometric/year"
local myfiles : dir . files "reer*.dta"
foreach file of local myfiles {
use `file', clear
levelsof product if t_p_group != ., local(P)
foreach p of local P { 
use `file', clear
keep if product == `p'
drop if year < 2002 | year > 2018

gen ln_reer_double = log(reer_double)
gen ln_exchange = log(d_exchange)
bysort partner (year) : gen diff_exchange = d_exchange/d_exchange[_n-1] if _n > 1
replace diff_exchange = ln_exchange if diff_exchange == .
gen ln_diff_exchange = log(diff_exchange)
bysort partner (year) : gen delta = double_weights - double_weights[_n-1] if _n > 1
replace delta = double_weights if delta == .
bysort partner (year) : gen var_term = (double_weights[_n-1]*ln_diff_exchange)+(delta*ln_exchange)
replace var_term = 0 if var_term == .
drop if var_term == 0 

bysort year : egen sum_var_term = sum(var_term)
gen sum11 = ln_reer_double - ln_reer_double[_n-1] 
bysort year : replace sum11 = sum11[_n-1] if sum11 == 0 & _n>1
replace sum11 = 0 if sum11 == .
tw (line sum_var_term year) (line sum11 year)

gen var_term_abs = abs(var_term)
bysort year : egen rank = rank(-var_term_abs)
bysort year : drop if rank > 5
graph bar var_term, over(partner, label(labsize(tiny))) over(year, label(labsize(tiny))) asyvars stack legend(rows(4) colfirst) /// 
title("REER variation decomposition")
cd "`pdir'/results/variation decomposition/reer"
graph export "`file' REER variation decomposition of `p'.pdf", replace 
cd "`pdir'/data_derived/reer/index/geometric/year"
}
}

*--------------------------------End of do file------------------------------- 
