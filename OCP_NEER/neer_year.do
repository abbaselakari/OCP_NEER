/*--------------------------------Start of do file------------------------------- 
the following do file computes the effective exchange for yearly values. it inputs 
the weights, duplicate the values for to the unavailable last year for each country
then compute the nominal effective exchange rate and its variation.
--------------------------------------------------------------------------------*/
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg1.dta")		// stating the files the do file is using 
project, uses("`pdir'/data_derived/neer/index/geometric/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/index/geometric/weights.dta")

cd "`pdir'/data_derived/neer/index/geometric/year"
*** Merge exchange year data with weights 
project, uses("`pdir'/data_derived/neer/index/geometric/year/exchange_year.dta")
use exchange_year,  clear 														
cd "`pdir'/data_derived/neer/index/geometric"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
	merge 1:1 partner year product using  `file', gen(_merge_rate)
	drop if _merge_rate == 2
	
*** Generating double weights for n+1 
gen p = 1 if double_weights != .												// we get the number of years for which the country have weights
bysort partner product : egen pp = total(p)										
sort partner product  p year 
bysort partner product  p : gen id = _n											
bysort partner product p  : gen x = year[_n] if _n == pp & _merge_rate == 3		// by matching the last year for which weights are available with the id we derive this year
bysort partner product : gen double_weights_2 = double_weights if year == x		// and then save its value in a variables 

levelsof partner, local(P)														// by looping over each product year partner, 
	foreach p of local P { 														// we replicate the value of the saved value of weights for all obs
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof double_weights_2 if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace double_weights_2 = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
levelsof partner, local(P)														// we do the same for the year of last value
	foreach p of local P { 
		levelsof product if partner == "`p'", local(Q)
		foreach q of local Q  { 
			levelsof x if product == `q' & partner == "`p'", local(A)
				foreach a of local A { 
				replace x = `a' if partner == "`p'" & product == `q' 
			}
		}
	}
bysort partner product : replace double_weights = double_weights_2 if year > x 	// given the above information we replace the missing last years weights by the value of the previous one
drop p pp x id double_weights_2 

*** Generating simple weights for n+1											// we do the same thing for simple weights
gen p = 1 if simple_weights != .
bysort partner product : egen pp = total(p)
sort partner product  p year 
bysort partner product  p : gen id = _n
bysort partner product p  : gen x = year[_n] if _n == pp & _merge_rate == 3
bysort partner product : gen simple_weights_2 = simple_weights if year == x


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
bysort partner product : replace simple_weights = simple_weights_2 if year > x 

	replace double_weights = 0 if _merge_rate == 1 & year < x					// for the missing weights of previous years we get them to zero 
	replace simple_weights = 0 if _merge_rate == 1 & year < x
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
	*Compute the NEER_double
	egen _p_group = group(year product)
	bysort _p_group : gen pdct = exchange^double_weights
	bysort _p_group : gen neer_double = pdct[1]
	bysort _p_group : replace neer_double = neer_double[_n-1] * pdct if _n > 1
	bysort _p_group : replace neer_double = neer_double[_N]
	
	* Change to base first month 
	bysort  product  : gen base = neer_double if year == 2002
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer_double = (neer_double/base)*100
	drop base
	sort _p_group

	*Compute the NEER_simple
	bysort _p_group : gen pdct_s = exchange^simple_weights
	bysort _p_group : gen neer_simple = pdct_s[1]
	bysort _p_group : replace neer_simple = neer_simple[_n-1] * pdct_s if _n > 1
	bysort _p_group : replace neer_simple = neer_simple[_N]
	* Change to base first month 
	bysort  product  : gen base = neer_simple if year == 2002
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer_simple = (neer_simple/base)*100
	drop base
	sort _p_group
	cd "`pdir'/data_derived/neer/index/geometric/year"
	save neer_year_`file', replace
	project, creates("`pdir'/data_derived/neer/index/geometric/year/neer_year_`file'") preserve 
	
	* Generating variation 
	drop if year < 2002 
	* for double
	sort product year	 
	bysort product (year) : gen var_neer_double = (neer_double/neer_double[_n-1])-1
	replace var_neer_double = . if year == 2002
	bysort product (year) : replace var_neer_double = var_neer_double[_n-1] if var_neer_double == 0 & _n>1
	* for simple 
	bysort product (year) : gen var_neer_simple = (neer_simple/neer_simple[_n-1])-1
	replace var_neer_simple = . if year == 2002
	bysort product (year) : replace var_neer_simple = var_neer_simple[_n-1] if var_neer_simple == 0 & _n>1

	cd "`pdir'/data_derived/neer/variation/geometric/year"	
	save neer_year_variation_`file', replace 
	project, creates("`pdir'/data_derived/neer/variation/geometric/year/neer_year_variation_`file'") preserve

	cd "`pdir'/data_derived/neer/index/geometric/year"
	use exchange_year , clear 
	cd "`pdir'/data_derived/neer/index/geometric/"
}

