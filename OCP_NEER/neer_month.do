*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/month/exchange_month.dta")

*** Merge with weights months 
cd "`pdir'/data_derived/neer/index/geometric"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
use `file', clear
expand 12, gen(dup)																// now for monthly data we have only yearly weights, we just expand the latter
drop dup 																		// into 12 months, so that they can match monthly exchange rates datat
sort partner year product
quietly by partner year product : gen dup = cond(_N==1,0,_n)
egen month = concat(year dup), punct("m")
drop dup 
gen Month = monthly(month, "YM")
format Month %tm
drop month 
rename Month month
save month_`file', replace 

cd "`pdir'/data_derived/neer/index/geometric/month"
use exchange_month , clear 
cd "`pdir'/data_derived/neer/index/geometric"
merge 1:1 partner month product using  month_`file' , gen(_merge_rate) force
drop if _merge_rate == 2

*** Generating double weights for n+1 
gen p = 1 if double_weights != .

bysort partner product : egen pp = total(p)
sort partner product  p month 
bysort partner product  p : gen id = _n
bysort partner product p  : gen x = month[_n] if _n == pp & _merge_rate == 3
format x %tm
bysort partner product : gen double_weights_2 = double_weights if month == x

levelsof partner, local(P)
	foreach p of local P { 
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof double_weights_2 if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace double_weights_2 = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
levelsof partner, local(P)
	foreach p of local P { 
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof x if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace x = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
format x %tm
bysort partner product : replace double_weights = double_weights_2 if month > x 
drop p pp x id double_weights_2 

*** Generating simple weights for n+1
gen p = 1 if simple_weights != .
bysort partner product : egen pp = total(p)
sort partner product  p month 
bysort partner product  p : gen id = _n
bysort partner product p  : gen x = month[_n] if _n == pp & _merge_rate == 3
bysort partner product : gen simple_weights_2 = simple_weights if month == x

levelsof partner, local(P)
	foreach p of local P { 
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof simple_weights_2 if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace simple_weights_2 = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
levelsof partner, local(P)
	foreach p of local P { 
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof x if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace x = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
bysort partner product : replace simple_weights = simple_weights_2 if month > x 

	replace double_weights = 0 if _merge_rate == 1 & month < x
	replace simple_weights = 0 if _merge_rate == 1 & month < x
	drop  p pp x id simple_weights_2 _merge_rate 
	drop if double_weights == .
	drop if simple_weights == . 
	* rescaling to 1 after weights being dropped and added for double 
	bysort t_p_group : egen s = total(double_weights)
	gen p = 0 
	replace p = 1 if double_weights != 0 
	bysort t_p_group : egen r = total(p)
	bysort t_p_group : gen 	e = (1-s)/r
	replace double_weights = double_weights + e if double_weights != 0
	bysort t_p_group : egen q = total(double_weights)
	tab q
	drop p q r s e 
	* rescaling to 1 after weights being dropped and added for simple
	gen p = 0 
	bysort t_p_group : egen s = total(simple_weights)
	replace p = 1 if simple_weights != 0 
	bysort t_p_group : egen r = total(p)
	bysort t_p_group : gen 	e = (1-s)/r
	replace simple_weights = simple_weights + e if simple_weights != 0
	bysort t_p_group : egen q = total(simple_weights)
	tab q
	drop p q r s e 

*** Compute the NEER 
egen group = group(month product)
bysort group : gen pdct = exchange^double_weights
bysort group : gen neer_double = pdct[1]
bysort group : replace neer_double = neer_double[_n-1] * pdct if _n > 1
bysort group : replace neer_double = neer_double[_N]

	* Change to base first month 
	bysort  product  : gen base = neer_double if month == ym(2002,01)
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer_double = (neer_double/base)*100
	drop base
	sort group
	*** Compute the NEER simple
bysort group : gen pdct_s = exchange^simple_weights
bysort group : gen neer_simple = pdct_s[1]
bysort group : replace neer_simple = neer_simple[_n-1] * pdct_s if _n > 1
bysort group : replace neer_simple = neer_simple[_N]

	* Change to base first month 
	bysort  product  : gen base = neer_simple if month == ym(2002,01)
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer_simple = (neer_simple/base)*100
	drop base
	sort group

cd "`pdir'/data_derived/neer/index/geometric/month"
save neer_month_`file', replace

drop if month < ym(2002,01) 
* for double
sort product month	
bysort product (month) : gen var_neer_double = (neer_double/neer_double[_n-1])-1
replace var_neer_double = . if month == ym(2002,01)
bysort product (month) : replace var_neer_double = var_neer_double[_n-1] if var_neer_double == 0 & _n>1
replace var_neer_double = 0 if var_neer_double == . 
* for simple 
bysort product (month) : gen var_neer_simple = (neer_simple/neer_simple[_n-1])-1
replace var_neer_simple = . if month == ym(2002,01)
bysort product (month) : replace var_neer_simple = var_neer_simple[_n-1] if var_neer_simple == 0 & _n>1
replace var_neer_simple = 0 if var_neer_simple == . 

cd "`pdir'/data_derived/neer/variation/geometric/month"
save neer_month_variation_`file', replace
cd "`pdir'/data_derived/neer/index/geometric"
}

project, creates("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/neer/index/geometric/month/neer_month_weights.dta")
