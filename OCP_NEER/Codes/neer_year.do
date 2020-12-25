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
	merge 1:1 partner year product using  `file', gen(_merge_rate)
	drop if _merge_rate == 2
	/*expand 5 if _merge_rate == 1, gen(dup) 
	drop dup 
	sort partner year
	quietly by partner year : gen produt = cond(_N==1,0,_n) 
	replace product = produt if _merge_rate == 1 */
	replace double_weights = 0 if _merge_rate == 1
	replace simple_weights = 0 if _merge_rate == 1
	drop _merge_rate 
	drop if double_weights == .
	drop if simple_weights == . 
	*Compute the NEER 
	egen _p_group = group(year product)
	bysort _p_group : gen pdct = exchange^double_weights
	bysort _p_group : gen neer = pdct[1]
	bysort _p_group : replace neer = neer[_n-1] * pdct if _n > 1
	bysort _p_group : replace neer = neer[_N]
	* Change to base first month 
	bysort  product  : gen base = neer if year == 2002
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer = (neer/base)*100
	drop base
	sort _p_group

	cd "`pdir'/data_derived/neer/year"
	save neer_year_`file', replace
	project, creates("`pdir'/data_derived/neer/year/neer_year_`file'") 
	use exchange_year , clear 
	cd "`pdir'/data_derived/neer"
}

*--------------------------------End of do file------------------------------- 
