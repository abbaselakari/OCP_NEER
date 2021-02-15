/*--------------------------------Start of do file------------------------------- 
exchange do file inputs raw exchange rates data downloaded for the IMF website
the data is then processed, country names corrected, and output yearly and monthly datasets
-----------------------------------------------------------------------------*/

project, doinfo 
local pdir "`r(pdir)'"															// capturing the projects informations 
local dofile "`(dofile)'"														// capture the do file location

cd "`pdir'/data_raw/exchange"													// setting up the working directory
* Importing the exchange rates 
local myfiles : dir . files "*.xlsx"											// prepare a loop over all the exchange rate datasets
foreach file of local myfiles { 
	cd "`pdir'/data_raw/exchange"
	*project, original("`file'")
	import excel "`file'",firstrow cellrange(B7) allstring clear				// import excel files one by one, 
	drop Scale BaseYear 
	foreach v of varlist _all {													// renaming the variables 
	   local x : variable label `v'
	   rename `v' rate`x'
	  }
	rename rateCountry Country
	reshape long rate, i(Country) j(year) string 								// reshape the data to  a long format 
	rename year period
	cd "`pdir'/data_derived/exchange/sliced"
	save "`file'.dta", replace 
	project, creates("`file'.dta")
}

cd "`pdir'/data_derived/exchange/sliced"		
clear 
fs *.dta
append using `r(files)' 														// append all the period datasets
sort Country period
quietly by Country period : gen dup = cond(_N == 1,0,_n)						// control for duplicates 
tab dup 
drop if dup > 1
drop dup 
* for the euro are some countries have acceeded in different timings, we create those countries, 
expand 2 if Country == "Euro Area", generate (dup)								
replace Country = "Austria" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Belgium" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Finland" if dup == 1
drop dup
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "France" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Germany" if dup == 1
drop dup
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Ireland" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Italy" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Luxembourg" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Netherlands" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Portugal" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace Country = "Spain" if dup == 1
drop dup 

gen rate1 = real(rate)
drop rate
rename rate1 rate

* Extract monthly dates
gen Month = regexr(period, "[M]","/")
gen month = monthly(Month, "YM")
format month %tm
replace month = . if regexm(Month, "[Q]")

* Extract yearly dates
gen year = regexs(0) if regexm(period, "^([0-9][0-9][0-9][0-9])$")
gen year1= real(year)
drop year
rename year1 year

* Generate values for missing rate for 2003 Iraq from monthly Iraq rates 
egen mean = mean(rate) if Country == "Iraq" & inrange(month, ym(2003,01), ym(2003,12)) 
levelsof mean, local(x) 
replace rate = `x' if year == 2003 & Country == "Iraq" 
drop mean 
* Generate values for missing rate for 2004 Mauritania from monthly Mauritani rates 
egen mean = mean(rate) if Country == "Mauritania, Islamic Rep. of" & inrange(month, ym(2004,01), ym(2004,12)) 
levelsof mean, local(x) 
replace rate = `x' if year == 2004 & Country == "Mauritania, Islamic Rep. of" 
drop mean 
* Generate values for missing rate for 2004 Mauritania from monthly Mauritani rates 
egen mean = mean(rate) if Country == "Slovenia, Rep. of" & inrange(month, ym(2007,01), ym(2007,12)) 
levelsof mean, local(x) 
replace rate = `x' if year == 2007 & Country == "Slovenia, Rep. of" 
drop mean 
* for the created countries some have integrated the euro are in a later period, so we have two entries of the country that we merge together
expand 2 if Country == "Euro Area" & year >= 2015 & year != ., generate (dup)
replace Country = "Lithuania" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2014 & year != ., generate (dup)
replace Country = "Latvia" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2008 & year != ., generate (dup)
replace Country = "Cyprus" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2011 & year != ., generate (dup)
replace Country = "Estonia, Rep. of" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2001 & year != ., generate (dup)
replace Country = "Greece" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2008 & year != ., generate (dup)
replace Country = "Malta" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2008 & year != ., generate (dup)
replace Country = "Slovenia, Rep. of" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & year >= 2009 & year != ., generate (dup)
replace Country = "Slovak Rep." if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2015,01) & month != ., generate (dup)
replace Country = "Lithuania" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2014,01) & month != ., generate (dup)
replace Country = "Latvia" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2008,01) & month != ., generate (dup)
replace Country = "Cyprus" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2011,01) & month != ., generate (dup)
replace Country = "Estonia, Rep. of" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2001,01) & month != ., generate (dup)
replace Country = "Greece" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2008,01) & month != ., generate (dup)
replace Country = "Malta" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2008,01) & month != ., generate (dup)
replace Country = "Slovenia, Rep. of" if dup == 1
drop dup 
expand 2 if Country == "Euro Area" & month >= ym(2009,01) & month != ., generate (dup)
replace Country = "Slovak Rep." if dup == 1
drop dup 

cd "`pdir'/data_derived/merge"
save exchange, replace 

* Matching country names using the ISO file
cd "`pdir'/data_raw/ISO"
project, original("iso.xlsx")
import excel using "iso.xlsx", firstrow clear
rename country_exchange Country 
drop if country_ifa == "Dubai, UAE"
cd "`pdir'/data_derived/merge"
merge 1:m Country using exchange, gen(_merge_iso)
tab Country if _merge_iso == 1
tab Country if _merge_iso == 2
* keep the names needed
keep Country CountryCode ISO3digitAlpha CountryNameAbbreviation period rate _merge_iso year month
rename CountryCode Countrycode
rename ISO3digitAlpha Countryiso
rename CountryNameAbbreviation partner

keep if _merge_iso == 3
drop _merge_iso Country 
rename Countrycode partnercode 
rename Countryiso partneriso 

* Save data
cd "`pdir'/data_derived/exchange"
save exchange, replace 
project, creates("exchange.dta") preserve

* Exchange rates by year 
keep if year != . 
drop month
***Exchange_rate by year 
levelsof year, local(levels)						
foreach x of local levels { 					
	gen rate_mar_`x' = rate if year == `x' & partnercode == 504					// we get the moroccan exchange rate all over the observations 
			levelsof rate_mar_`x', local(F)										// so that we convert all the rates for us based to moroccan dirham based
			foreach f of local F {
			replace rate_mar_`x' = `f' if rate_mar_`x' == . & year == `x'
				}
}

egen rate_mar = rowtotal(rate_mar_*)											
drop rate_mar_*
drop if rate_mar == 0
gen exchange  = 1/(rate_mar/rate)												

sort partner year 
quietly by  partner year : gen dup = cond(_N==1,0,_n)							
drop if exchange ==.															// missing exchnage rates are dropped
drop dup
bysort partner : gen base = exchange if year == 2013							// we set the base year to be 2013, since its the most complete year 
levelsof partner, local(P)
foreach p of local P {
levelsof base if partner == "`p'" , local(F)
foreach f of local F {
replace base = `f' if base == . & partner == "`p'"
	}
}

replace exchange = (exchange/base)*100
drop base
drop if exchange == . 
expand 5, gen(dup) 																// we expand for 5 products to be merged with weights data
drop dup 
sort partner year
quietly by partner year : gen product = cond(_N==1,0,_n)

cd "`pdir'/data_derived/neer/index/geometric/year"
save exchange_year, replace 													// save yearly exchange rates 
project, creates("exchange_year.dta") 

***Exchange_rate by Month
cd "`pdir'/data_derived/exchange"

use exchange, clear
drop if month == .
drop year 
levelsof month, local(levels)
foreach x of local levels { 
	gen rate_mar_`x' = rate if month == `x' & partnercode == 504
			levelsof rate_mar_`x', local(F)
			foreach f of local F {
			replace rate_mar_`x' = `f' if rate_mar_`x' == . & month == `x'
				}
}

egen rate_mar = rowtotal(rate_mar_*)
drop rate_mar_*
drop if rate_mar == 0
gen exchange  = rate/rate_mar
drop if exchange == .
drop if partner == "Morocco"

sort partner month
bysort partner : gen base = exchange if month == ym(2013,01)
levelsof partner, local(P)
foreach p of local P {
levelsof base if partner == "`p'" , local(F)
foreach f of local F {
replace base = `f' if base == . & partner == "`p'"
		}
	}

replace exchange = (exchange/base)*100
drop base
sort partner month 
quietly by  partner month : gen dup = cond(_N==1,0,_n)
drop if dup > 0
///collapse (min)  exchange , by(partner month)
drop dup    

*winsor2 exchange, replace cuts(1,99)
drop if exchange == .
expand 5, gen(dup) 
drop dup 
sort partner month
quietly by partner month : gen product = cond(_N==1,0,_n)
cd "`pdir'/data_derived/neer/index/geometric/month"
save exchange_month, replace 
project, creates("exchange_month.dta")
