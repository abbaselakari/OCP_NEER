/*--------------------------------Start of do file------------------------------- 
The ifa do file take (international fertilizers association) excel datasets, 
process them, and output ready to merge stata format datasets in three levels of
aggregation, data is downloaded from ifastat website 
-----------------------------------------------------------------------------*/
project, doinfo 																// capturing the projects informations 
local pdir "`r(pdir)'"															// working directory of the do file
local dofile "`(dofile)'"


cd "`pdir'/data_raw/IFA"														// setting up the working directory for importing raw datasets 
* Importing IFA dataset
local myfiles : dir . files "*.xlsx"											// capturing the excel files in the directory
foreach file of local myfiles { 												// looping over each one 
	foreach x in "MAP" "DAP" "TSP" "Phosphate Rock all Grade" "PA" {			// each excel file have five different sheets for each product 
		cd "`pdir'/data_raw/IFA"												
		project, original("`pdir'/data_raw/IFA/`file'")						// the command is commented out to allow for the program to be run again 
																				// if a new file is added 
		import excel using "`file'", cellrange(A3) firstrow sheet(`x') clear	// importing each excel sheet apart from each excel file
		rename Country reporter 													
		replace Product = "4" if Product == "Phosphate Rock all Grade"			// renaming the products to the convention	
		replace Product = "1" if Product == "DAP" 
		replace Product = "2" if Product == "MAP" 
		replace Product = "3" if Product == "PA" 
		replace Product = "5" if Product == "TSP"
		drop Period 
		drop  if Year == . 														// drop any extra line from the download 
	cd "`pdir'/data_derived/IFA"
	save "`file'_`x'.dta" , replace 											// save each file apart 
	project, creates("`file'_`x'.dta")
	}
}

clear
fs *.dta 																		// append all the files created 
append using `r(files)'
sort Year Product reporter 
quietly by Year Product reporter : gen dup = cond(_N==1,0,_n) 					// check for the duplicates 
tab dup
drop if dup > 1															// drop if any 
drop dup 							
encode Product, gen(product)													// gen the product variables 
drop Product

cd "`pdir'/data_derived/merge"
save ifa_1.dta, replace 														// save the temporary dataset
project, creates("ifa_1.dta")

* Import iso files for matchine country names with iso and code 				
cd "`pdir'/data_raw/ISO"
project, original("iso.xlsx")
import excel using "iso.xlsx", firstrow clear
rename country_ifa reporter
cd "`pdir'/data_derived/merge"
merge 1:m reporter using ifa_1, gen(_merge_iso)
tab reporter if _merge_iso == 1
tab reporter if _merge_iso == 2
keep if _merge_iso == 3
keep CountryCode ISO3digitAlpha CountryNameAbbreviation Year Production Imports Exports ApparentConsumption Homedeliveries product
rename CountryCode partnercode
rename ISO3digitAlpha partneriso
rename CountryNameAbbreviation partner											// keep the conventional name used in all datasets 
rename Year year
sort year product partner
quietly by year product partner: gen dup = cond(_N==1,0,_n) 					// check again for duplicates 
tab dup																				
drop dup
* Merge UAE entries into one : the United arab emirates country is twice encoded in the ifa dataset as different countries, although they are one so we add them
sort year product partner
collapse (sum) Production Imports Exports Homedeliveries ApparentConsumption, by(year product partner partnercode partneriso)

cd "`pdir'/data_derived/merge"
save IFA, replace 																// process, cleaned and ready to merge ifa data set 
project, creates("IFA.dta") preserve

********************************************************************************

* Aggregation level 1 : Fertilizers 											// same as we did with comtrade, we aggregated into two levels of product
* Merge with prices
cd "`pdir'/data_raw/IFA/price"													// this time we need prices since, ifa is only in quantity
import excel using "IFA_PRICE.xlsx", firstrow clear								// import the proce dataset, this one can be changed 
cd "`pdir'/data_derived/merge"
save ifa_price, replace 
use IFA, clear
merge m:1 product using ifa_price, gen(_merge_price)							// merge ifa and prices to get the value 
drop _merge_price 
list Production product if partner == "Belgium" & year == 2017
* Multiply quantities by price 0f 2011
replace Production = Production*price 											// multiply to get the value 
replace Exports = Exports*price 
replace Imports = Imports*price 
replace ApparentConsumption = ApparentConsumption*price
replace Homedeliveries = Homedeliveries*price

replace product = 1 if product == 5 | product == 2
sort partner year product  
collapse (sum) Production Exports Imports Homedeliveries ApparentConsumption, by(year product partner partnercode partneriso)
list Production if partner == "Belgium" &  year == 2017

save IFA_agg1, replace 
project, creates("IFA_agg1.dta") preserve

********************************************************************************

*** Aggregation 2 : OCP products
list Production product if partner == "Belgium"  & year == 2017
replace product = 1 if product == 3 | product == 4
sort partner year product  
collapse (sum) Production Exports Imports Homedeliveries ApparentConsumption, by(year product partner partnercode partneriso)
list Production if partner == "Belgium"  & year == 2017

save IFA_agg2, replace 
project, creates("IFA_agg2.dta")

*--------------------------------End of do file------------------------------- 
