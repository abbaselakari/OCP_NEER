*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"


cd "`pdir'/data_raw/IFA"
* Importing IFA dataset
local myfiles : dir . files "*.xlsx"
foreach file of local myfiles { 
	foreach x in "MAP" "DAP" "TSP" "Phosphate Rock all Grade" "PA" {
		cd "`pdir'/data_raw/IFA"
		project, original("`pdir'/data_raw/IFA/`file'")
		import excel using "`file'", cellrange(A3) firstrow sheet(`x') clear
		rename Country reporter 
		replace Product = "4" if Product == "Phosphate Rock all Grade"
		replace Product = "1" if Product == "DAP" 
		replace Product = "2" if Product == "MAP" 
		replace Product = "3" if Product == "PA" 
		replace Product = "5" if Product == "TSP"
		drop Period 
		drop  if Year == . 
		//encode Product, gen(product)
		//drop Product
	cd "`pdir'/data_derived/IFA"
	save "`file'_`x'.dta" , replace 
	project, creates("`file'_`x'.dta")
	}
}

//ssc install fs  
clear
fs *.dta 
append using `r(files)'
sort Year Product reporter 
quietly by Year Product reporter : gen dup = cond(_N==1,0,_n) 
tab dup
drop dup 
encode Product, gen(product)
drop Product

cd "`pdir'/data_derived/merge"
save ifa_1.dta, replace 
project, creates("ifa_1.dta")
* Add iso names for countries 

cd "`pdir'/data_derived/merge"
project, uses("`pdir'/data_derived/merge/trade2.dta")
use trade2, clear 

keep partner partneriso partnercode 
sort partner 
quietly by partner : gen dup = cond(_N==1,0,_n) 
drop if dup > 1 
drop dup 

save iso, replace 
project, creates("iso.dta")

* Get correct name for countries in ifa 
cd "`pdir'/data_derived/merge"
project, uses("`pdir'/data_derived/merge/ifa_1.dta")
use ifa_1,clear 

replace reporter = "United Arab Emirates" if reporter == "Abu Dhabi, UAE"
replace reporter = "Eswatini" if reporter == "Swaziland"
replace reporter = "Bolivia (Plurinational State of)" if reporter == "Bolivia"
replace reporter = "Bosnia Herzegovina" if reporter == "Bosnia and Herzegovina"
replace reporter = "Palau" if reporter == "Christmas Island"
replace reporter = "C├┤te d'Ivoire" if reporter == "Cote d'Ivoire"
replace reporter = "United Arab Emirates" if reporter == "Dubai, UAE"
replace reporter = "China, Hong Kong SAR" if reporter == "Hong Kong"
replace reporter = "Rep. of Korea" if reporter == "Korea Rep."
replace reporter = "Lao People's Dem. Rep." if reporter == "Laos"
replace reporter = "Luxembourg" if reporter == "Luxemburg"
replace reporter = "China, Macao SAR" if reporter == "Macao"
replace reporter = "North Macedonia" if reporter == "Macedonia"
replace reporter = "Rep. of Moldova" if reporter == "Moldova Rep."
replace reporter = "Neth. Antilles" if reporter == "Netherlands Antilles"
replace reporter = "Russian Federation" if reporter == "Russia"
replace reporter = "United Rep. of Tanzania" if reporter == "Tanzania"
replace reporter = "USA" if reporter == "U.S.A."
replace reporter = "Brunei Darussalam" if reporter == "Brunei"
replace reporter = "Dem. People's Rep. of Korea" if reporter == "Korea DPR"
replace reporter = "Dem. Rep. of the Congo" if reporter == "Zaire"
replace reporter = "Dem. Rep. of the Congo" if reporter == "Congo"

rename reporter partner 
sort Year product partner
quietly by Year product partner: gen dup = cond(_N==1,0,_n) 
tab dup

* Merge UAE and Congo entries into one 
sort Year product partner
collapse (sum) Production Imports Exports Homedeliveries ApparentConsumption, by(Year product partner)
merge m:1  partner using iso,  gen(_merge_iso)
tab partner if _merge_iso == 1
tab partner if _merge_iso == 2
/* Merging IFA with Comtrade : one should note that this is an important step, where matching countries 
production data with trade flows data,is essential to compute the neer, thus, more matchiing means higher 
probability of having precise indices, in this respect, names of IFA countries should be modified so as to 
they match the ones in Comtrade before merging both datasets
    not matched                         2,826
        from master                     2,805  (_merge_iso==1)
        from using                         21  (_merge_iso==2)
    matched                            13,685  (_merge_iso==3)
*/
 
* Get iso codes for countries not present in Comtrade
replace partneriso  = "AFG"  if partner == "Afghanistan"
replace partnercode  = 4 if partner == "Afghanistan"
replace partneriso  = "AGO" if partner == "Angola"
replace partnercode  = 24 if partner == "Angola"
replace partneriso  = "BMU" if partner == "Bermuda"
replace partnercode  = 60 if partner == "Bermuda"
replace partneriso  = "TCD" if partner == "Chad"
replace partnercode  = 148 if partner == "Chad"
replace partneriso  = "COD" if partner == "Congo"
replace partnercode  = 180 if partner == "Congo"
replace partneriso  = "DJI" if partner == "Djibouti"
replace partnercode  = 262 if partner == "Djibouti"
replace partneriso  = "DMA" if partner == "Dominica"
replace partnercode  = 212 if partner == "Dominica"
replace partneriso  = "ERI" if partner == "Eritrea"
replace partnercode  = 232 if partner == "Eritrea"
replace partneriso  = "GUF" if partner == "French Guiana"
replace partnercode  = 254 if partner == "French Guiana"
replace partneriso  = "GLP" if partner == "Guadeloupe"
replace partnercode  = 312 if partner == "Guadeloupe"
replace partneriso  = "GIN" if partner == "Guinea"
replace partnercode  = 324 if partner == "Guinea"
replace partneriso  = "HTI" if partner == "Haiti"
replace partnercode  = 332 if partner == "Haiti"
replace partneriso  = "IRQ" if partner == "Iraq"
replace partnercode = 368 if partner == "Iraq"
replace partneriso  = "PRK" if partner == "Korea DPR"
replace partnercode  = 408 if partner == "Korea DPR"
replace partneriso  = "LBR" if partner == "Liberia"
replace partnercode  = 430 if partner == "Liberia"
replace partneriso  = "LBY" if partner == "Libya"
replace partnercode  = 434 if partner == "Libya"
replace partneriso  = "MDV" if partner == "Maldives"
replace partnercode  = 462 if partner == "Maldives"
replace partneriso  = "MTQ" if partner == "Martinique"
replace partnercode  = 474 if partner == "Martinique"
replace partneriso  = "MMR" if partner == "Myanmar"
replace partnercode  = 104 if partner == "Myanmar"
replace partneriso  = "NRU" if partner == "Nauru"
replace partnercode  = 520 if partner == "Nauru"
replace partneriso  = "PRI" if partner == "Puerto Rico"
replace partnercode  = 630 if partner == "Puerto Rico"
replace partneriso  = "REU" if partner == "Reunion"
replace partnercode  = 638 if partner == "Reunion"
replace partneriso  = "SYC" if partner == "Seychelles"
replace partnercode  = 690 if partner == "Seychelles"
replace partneriso  = "SOM" if partner == "Somalia"
replace partnercode  = 706 if partner == "Somalia"
replace partneriso  = "TWN" if partner == "Taiwan, China"
replace partnercode  = 158 if partner == "Taiwan, China"
replace partneriso  = "TJK" if partner == "Tajikistan"
replace partnercode  = 762 if partner == "Tajikistan"
replace partneriso  = "TKM" if partner == "Turkmenistan"
replace partnercode  =  795 if partner == "Turkmenistan"
replace partneriso  = "UZB" if partner == "Uzbekistan"
replace partnercode  = 860 if partner == "Uzbekistan"


* keep only countries that are in both datasets
drop if _merge_iso == 1 | _merge_iso == 2 // 1756 obs
drop _merge_iso
rename Year year

cd "`pdir'/data_derived/merge"
save IFA, replace 
project, creates("IFA.dta") preserve

* Aggregation level 1 : Fertilizers 
list Production product if partner == "Belgium" & year == 2017
* Multiply quantities by price 0f 2011
replace Production = Production*90000 if product == 4
replace Exports = Exports*90000 if product ==4
replace Imports = Imports*90000 if product ==4
replace ApparentConsumption = ApparentConsumption*90000 if product ==4
replace Homedeliveries = Homedeliveries*90000 if product ==4

replace Production = Production*480000 if product == 1
replace Exports = Exports*480000 if product ==1
replace Imports = Imports*480000 if product ==1
replace ApparentConsumption = ApparentConsumption*480000 if product ==1
replace Homedeliveries = Homedeliveries*480000 if product ==1

replace Production = Production*389000 if product == 2
replace Exports = Exports*389000 if product ==2
replace Imports = Imports*389000 if product ==2
replace ApparentConsumption = ApparentConsumption*389000 if product ==2
replace Homedeliveries = Homedeliveries*389000 if product ==2

replace Production = Production*500000 if product == 3
replace Exports = Exports*500000 if product ==3
replace Imports = Imports*500000 if product ==3
replace ApparentConsumption = ApparentConsumption*500000 if product ==3
replace Homedeliveries = Homedeliveries*500000 if product ==3

replace Production = Production*288000 if product == 5
replace Exports = Exports*288000 if product ==5
replace Imports = Imports*288000 if product ==5
replace ApparentConsumption = ApparentConsumption*288000 if product ==5
replace Homedeliveries = Homedeliveries*288000 if product ==5


replace product = 1 if product == 5 | product == 2
sort partner year product  
collapse (sum) Production Exports Imports Homedeliveries ApparentConsumption, by(year product partner partnercode partneriso)
list Production if partner == "Belgium" &  year == 2017


save IFA_agg1, replace 
project, creates("IFA_agg1.dta") preserve

*** Aggregation 2 : OCP products
list Production product if partner == "Belgium"  & year == 2017
replace product = 1 if product == 3 | product == 4
sort partner year product  
collapse (sum) Production Exports Imports Homedeliveries ApparentConsumption, by(year product partner partnercode partneriso)
list Production if partner == "Belgium"  & year == 2017

save IFA_agg2, replace 
project, creates("IFA_agg2.dta")

*--------------------------------End of do file------------------------------- 
