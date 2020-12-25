*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/weights.dta")
project, uses("`pdir'/data_derived/neer/month/exchange_month.dta")

*** Merge with weights months 
cd "`pdir'/data_derived/neer"
local myfiles : dir . files "weights*.dta"
foreach file of local myfiles { 
use `file', clear
expand 12, gen(dup)
drop dup 
sort partner year product
quietly by partner  year product : gen dup = cond(_N==1,0,_n)
egen month = concat(year dup), punct("m")
drop dup 
gen Month = monthly(month, "YM")
format Month %tm
drop month 
rename Month month
save month_`file', replace 

cd "`pdir'/data_derived/neer/month"
use exchange_month , clear 
cd "`pdir'/data_derived/neer"
merge 1:1 partner month product using  month_`file' , gen(_merge_rate) force
keep if _merge_rate == 3
drop _merge_rate 

*** Compute the NEER 
egen group = group(month product)
bysort group : gen pdct = exchange^double_weights
bysort group : gen neer = pdct[1]
bysort group : replace neer = neer[_n-1] * pdct if _n > 1
bysort group : replace neer = neer[_N]

	* Change to base first month 
	bysort  product  : gen base = neer if month == ym(2002,01)
	levelsof product, local(P)
	foreach p of local P {
	levelsof base if product == `p' , local(F)
	foreach f of local F {
	replace base = `f' if base == . & product == `p'
		}
	}
	replace neer = (neer/base)*100
	drop base
	sort group
cd "`pdir'/data_derived/neer/month"
save neer_month_`file', replace
cd "`pdir'/data_derived/neer"
}

project, creates("`pdir'/data_derived/neer/month/neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/neer/month/neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/neer/month/neer_month_weights.dta")
