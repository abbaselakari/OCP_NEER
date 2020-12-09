*** Merge with exchange rate
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

cd "`pdir'/data_derived/merge"
project, uses("iso.dta")

cd "`pdir'/data_raw/exchange"
* Importing the exchange rates 
project, original("exchange_rate.xlsx")
import excel "exchange_rate.xlsx",firstrow cellrange(B7) allstring clear
drop Scale BaseYear 
foreach v of varlist _all {
   local x : variable label `v'
   rename `v' rate`x'
}
rename rateCountry Country
reshape long rate, i(Country) j(year) string 
rename year period

replace Country = "Hong Kong SAR" if Country == "China, P.R.: Hong Kong"
replace Country = "Macao SAR" if Country == "China, P.R.: Macao"
replace Country = "Congo dem" if Country == "Congo, Dem. Rep. of the"
replace Country = "Guinea Bissau" if Country == "Guinea-Bissau" 

gen partner  = regexs(1) if regexm(Country, "([A-Za-z]+[ ]*[A-Za-z]+[ ]*[A-Za-z]+)[,]*[A-Za-z]*")

*** Cleansing country names 

* Matching country names
replace partner = "China, Hong Kong SAR" if partner == "Hong Kong SAR"
replace partner = "China, Macao SAR" if partner == "Macao SAR"
replace partner = "Dem. Rep. of the Congo" if partner == "Congo dem"
replace partner = "Guinea-Bissau" if partner == "Guinea Bissau"
replace partner = "Bolivia (Plurinational State of)" if partner == "Bolivia"
replace partner = "Bosnia Herzegovina" if partner == "Bosnia and Herzegovina"
replace partner = "Cayman Isds" if partner == "Cayman Islands"
replace partner = "Central African Rep." if partner == "Central African Rep"
replace partner = "Czechia" if partner == "Czech Rep"
replace partner = "CuraÃ§ao" if partner == "Cura"
replace partner = "Dominican Rep." if partner == "Dominican Rep"
replace partner = "Faeroe Isds" if partner == "Faroe Islands"
replace partner = "Saint Kitts and Nevis" if partner == "Kitts and Nevis"
replace partner = "Rep. of Korea" if partner == "Korea"
replace partner = "Kyrgyzstan" if partner == "Kyrgyz Rep"
replace partner = "Lao People's Dem. Rep." if partner == "Lao People"
replace partner = "Saint Lucia" if partner == "Lucia"
replace partner = "FS Micronesia" if partner == "Micronesia"
replace partner = "Rep. of Moldova" if partner == "Moldova"
replace partner = "Saint Maarten" if partner == "Sint Maarten"
replace partner = "Solomon Isds" if partner == "Solomon Islands"
replace partner = "Syria" if partner == "Syrian Arab Rep"
replace partner = "United Rep. of Tanzania" if partner == "Tanzania"
replace partner = "Timor-Leste" if partner == "Timor"
replace partner = "USA" if partner == "United States"
replace partner = "Viet Nam" if partner == "Vietnam"
replace partner = "Saint Vincent and the Grenadines" if partner == "Vincent and the"
replace partner = "Sao Tome and Principe" if partner == "o Tom"
replace partner = "C├┤te d'Ivoire" if partner == "te d"

cd "`pdir'/data_derived/merge"
merge m:1 partner using iso, gen(_merge_iso)
tab partner if _merge_iso == 1
tab partner if _merge_iso == 2
replace _merge_iso = 3 if partner == "Euro Area" 

expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Austria" if dup == 1 
replace Country = "Austria" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Belgium" if dup == 1 
replace Country = "Belgium" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Cyprus" if dup == 1 
replace Country = "Cyprus" if dup == 1
drop dup
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Estonia" if dup == 1 
replace Country = "Estonia" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Finland" if dup == 1 
replace Country = "Finland" if dup == 1
drop dup
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "France" if dup == 1 
replace Country = "France" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Germany" if dup == 1 
replace Country = "Germany" if dup == 1
drop dup
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Greece" if dup == 1 
replace Country = "Greece" if dup == 1
drop dup
 expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Ireland" if dup == 1 
replace Country = "Ireland" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Italy" if dup == 1 
replace Country = "Italy" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Luxembourg" if dup == 1 
replace Country = "Luxembourg" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Malta" if dup == 1 
replace Country = "Malta" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Netherlands" if dup == 1 
replace Country = "Netherlands" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Portugal" if dup == 1 
replace Country = "Portugal" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Slovakia" if dup == 1 
replace Country = "Slovakia" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Slovenia" if dup == 1 
replace Country = "Slovenia" if dup == 1
drop dup 
expand 2 if Country == "Euro Area", generate (dup)
replace partner = "Spain" if dup == 1 
replace Country = "Spain" if dup == 1
drop dup 

keep if _merge_iso == 3

gen rate1 = real(rate)
drop rate
rename rate1 rate
drop _merge_iso

cd "`pdir'/data_derived/exchange"
save exchange, replace 
project, creates("exchange.dta") preserve

* Exchange rates by year 
gen year = regexs(0) if regexm(period, "^([0-9][0-9][0-9][0-9])$")
//gen Quarter = regexs(1) if regexm(period, "[Q]([0-9])$")
gen year1= real(year)
drop year
rename year1 year
keep if year != . 

***Exchange_rate by year 
levelsof year, local(levels)
foreach x of local levels { 
	gen rate_mar_`x' = rate if year == `x' & partnercode == 504
			levelsof rate_mar_`x', local(F)
			foreach f of local F {
			replace rate_mar_`x' = `f' if rate_mar_`x' == . & year == `x'
				}
}

egen rate_mar = rowtotal(rate_mar_*)
drop rate_mar_*
drop if rate_mar == 0
gen exchange  = 1/(rate_mar/rate)

keep partner year exchange 
sort partner year 
quietly by  partner year : gen dup = cond(_N==1,0,_n)
drop if exchange ==.
collapse (min)  exchange  , by(partner year)

bysort partner : gen base = exchange if _n == 1
levelsof partner, local(P)
foreach p of local P {
levelsof base if partner == "`p'" , local(F)
foreach f of local F {
replace base = `f' if base == . & partner == "`p'"
	}
}
replace exchange = (exchange/base)*100
drop base

cd "`pdir'/data_derived/neer/year"
save exchange_year, replace 
project, creates("exchange_year.dta") 

***Exchange_rate by Month
cd "`pdir'/data_derived/exchange"
use exchange, clear
gen Month = regexr(period, "[M]","/")
gen month = monthly(Month, "YM")
format month %tm
replace month = . if regexm(Month, "[Q]")
drop if month == .

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
keep partner month exchange 
drop if partner == "Morocco"


sort partner month
bysort partner : gen base = exchange if _n==1
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
///collapse (min)  exchange  , by(partner month)
drop dup 

winsor2 exchange, replace cuts(1,99)
cd "`pdir'/data_derived/neer/month"
save exchange_month, replace 
project, creates("exchange_month.dta")
