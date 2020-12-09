*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

project, uses("`pdir'/data_derived/neer/month/neer_month_weights_agg1.dta")
project, uses("`pdir'/data_derived/neer/month/neer_month_weights_agg2.dta")
project, uses("`pdir'/data_derived/neer/month/neer_month_weights.dta")

cd "`pdir'/data_derived/neer/month"

local myfiles : dir . files "neer*.dta"
foreach file of local myfiles {
use `file', clear 
cd "`pdir'/data_derived/deflators"
merge 1:1 partner month product using cpi_month, gen(_merge_rate) force
keep if _merge_rate == 3
drop _merge_rate 
drop group pdct 
*** Compute the REER 
egen group = group(month product)
bysort group : gen d_exchange = exchange*deflator
bysort group : gen pdct = d_exchange^double_weights
bysort group : gen reer = pdct[1]
bysort group : replace reer = reer[_n-1] * pdct if _n > 1
bysort group : replace reer = reer[_N]

cd "`pdir'/data_derived/reer/month"
save reer_`file', replace
cd "`pdir'/data_derived/neer/month"
}

project, creates("`pdir'/data_derived/reer/month/reer_month_neer_month_weights_agg1.dta")
project, creates("`pdir'/data_derived/reer/month/reer_month_neer_month_weights_agg2.dta")
project, creates("`pdir'/data_derived/reer/month/reer_month_neer_month_weights.dta")
