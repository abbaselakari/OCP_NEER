/*--------------------------------Start of do file------------------------------- 
The following do file import deflator (cpi) rates from the IMF website, process. 
-----------------------------------------------------------------------------*/
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"
* Deflators 
	* CPI 
		* Import CPI 
			//project original
			cd "`pdir'/data_raw/deflators/cpi"									// setting up the working directory
			local myfiles : dir . files "*.xlsx"								// for each excel raw file
			foreach file of local myfiles { 
			cd "`pdir'/data_raw/deflators/cpi"
			*project, original("`file'")
			import excel using "`file'", firstrow cellrange(B7) clear			// import 
			drop BaseYear Scale 
			foreach v of varlist _all {
			local x : variable label `v'										// change variable names 
			rename `v' year`x'
			}
			rename yearCountry partner
			reshape long year, i(partner) j(period, string)						// reshape
			rename year cpi 
			cd "`pdir'/data_derived/deflators/cpi"
			save "`file'.dta", replace 											// then save
			}
* Append cpi yearly files into one
clear 
cd "`pdir'/data_derived/deflators/cpi"
fs *.dta
append using `r(files)' 														// all sliced datasets are then appended
sort partner period
quietly by partner period : gen dup = cond(_N == 1,0,_n)						// we control for any duplicates 
tab dup 
drop if dup > 1 
drop dup 	
cd "`pdir'/data_derived/merge"
save deflators, replace 														// and we get ready to matched by country names 
			* Merge with ISO 
			cd "`pdir'/data_raw/ISO"
			project, original("iso.xlsx")
			import excel using "iso.xlsx", firstrow clear
			rename country_deflator partner 
			drop if country_ifa == "Dubai, UAE"
			cd "`pdir'/data_derived/merge"
			merge 1:m partner using deflators, gen(_merge_iso)
			tab partner if _merge_iso == 1
			tab partner if _merge_iso == 2
			keep if _merge_iso == 3
			drop _merge_iso
			cd "`pdir'/data_derived/deflators"
			replace cpi = "." if cpi == "..."									// get the correct format for the missung value 
			gen cpi_1 = real(cpi)
			drop cpi 
			rename cpi_1 cpi 
			drop if cpi == .													// missing rates are just missing, information is lost
			drop partner
			rename CountryCode partnercode 
			rename CountryNameAbbreviation partner 
			rename ISO3digitAlpha partneriso
			keep partner partnercode partneriso cpi period
			save cpi, replace 
			project, creates("cpi.dta") preserve
			
			* Extract yearly cpi
			gen year = regexs(0) if regexm(period, "^([0-9][0-9][0-9][0-9])$")
			gen Year = real(year)
			drop year
			rename Year year
			drop if year == .
			
			* duplicate for products
			expand 5, gen(dup)
			drop dup 
			sort partner year
			quietly by partner year : gen product = cond(_N==1,0,_n)
			
			* Generation of Moroccan cpi nominator
			gen cpi_mar = cpi if partner == "Morocco"
			bysort year (cpi_mar) : replace cpi_mar = cpi_mar[_n-1] if missing(cpi_mar)	
			drop if cpi_mar == .
			keep partner year cpi product cpi_mar
			gen deflator = cpi_mar/cpi
			
			cd "`pdir'/data_derived/deflators"
			save cpi_year, replace		
			project, creates("cpi_year.dta")  

			* Extract monthly cpi
			project, uses("cpi.dta")
			use cpi, clear
			gen Month = regexr(period, "[M]","/")
			gen month = monthly(Month, "YM")
			format month %tm
			replace month = . if regexm(period, "[Q]")
			drop if month == .
			drop Month
			* duplicate for products
			expand 5, gen(dup)
			drop dup 
			sort partner month
			quietly by partner month : gen product = cond(_N==1,0,_n)
			gen cpi_mar = cpi if partner == "Morocco"
			bysort month (cpi_mar) : replace cpi_mar = cpi_mar[_n-1] if missing(cpi_mar)	
			drop if cpi_mar == .
			keep partner month cpi product cpi_mar cpi 
			gen deflator = cpi_mar/cpi
			
			cd "`pdir'/data_derived/deflators"
			save cpi_month, replace		
			project, creates("cpi_month.dta") 

			
***************************** Draft fucntion ***********************************		

			* Replicate values for computation 
			* generate cpi as an index based 100 
			/*replace cpi = 0.00001 if cpi == 0
			sort partner month product 
			bysort partner : gen base = cpi if _n==1
			levelsof partner, local(P)
			foreach p of local P {
			levelsof base if partner == "`p'" , local(F)
			foreach f of local F {
			replace base = `f' if base == . & partner == "`p'"
			}
			}
			replace cpi = (cpi/base)*100
			drop base
			
			* Standardization of the serie 
			egen mean = mean(cpi)
			egen max = max(cpi)
			egen min = min(cpi)
			egen std = sd(cpi)
			gen cpi_sd = (cpi - min)/(max - min)
			*/
			
			/* Changing the base year 
			bysort partner :gen cpi_2010 = cpi if month == ym(2010, 08) 
			levelsof partner, local(P)
			foreach p of local P {
			levelsof cpi_2010 if partner == "`p'", local(A)
			foreach a of local A { 	
			replace cpi_2010 = `a' if cpi_2010 == . & partner == "`p'"
						}
					}
			bysort partner : gen cpi_2005 = cpi if month == ym(2005, 01) 
			levelsof partner, local(P) 
			foreach p of local P {
			levelsof cpi_2005 if partner == "`p'", local(Q) 
			foreach q of local Q { 	
			replace cpi_2005 = `q' if cpi_2005 == . & partner == "`p'"
						}
					}
			gen base = (cpi_2010/cpi_2005)
			drop if base == .
			replace cpi = cpi*base 	*/
			
			/* Change index base to 2010,01 
		 	bysort partner : gen base = cpi if month == ym(2010,01)
			levelsof partner, local(P)
			foreach p of local P {
			levelsof base if partner == "`p'" , local(F)
			foreach f of local F {
			replace base = `f' if base == . & partner == "`p'"
			}
			}
			replace cpi = (cpi/base)*100
			drop base
			
			* Generation of Moroccan cpi nominator 
			
			gen cpi_mar = cpi if partner == "Morocco"
			bysort month (cpi_mar) : replace cpi_mar = cpi_mar[_n-1] if missing(cpi_mar)	
			drop if cpi_mar == .
			keep partner month cpi product cpi_mar cpi year
			gen deflator = cpi_mar/cpi
			
			cd "`pdir'/data_derived/deflators"
			save cpi_month, replace		
			project, creates("cpi_month.dta") preserve 
			
			* Generation of yearly cpi 
			* change index to base 100 for year 2010 
			project, uses("cpi.dta")
			use cpi, clear
			bysort partner year product: egen cpi_mean = mean(cpi)
			sort partner year product 
			quietly by partner year product : gen dup = cond(_N ==1,0,_n)
			tab dup 
			drop if dup > 1 
			bysort partner : gen base = cpi_mean if year == 2010
			levelsof partner, local(P)
			foreach p of local P {
			levelsof base if partner == "`p'" , local(F)
			foreach f of local F {
			replace base = `f' if base == . & partner == "`p'"
			}
			}
			replace cpi = (cpi_mean/base)*100
			drop base
			gen cpi_mar = cpi if partner == "Morocco"
			bysort month (cpi_mar) : replace cpi_mar = cpi_mar[_n-1] if missing(cpi_mar)	
			drop if cpi_mar == .
			keep partner month cpi product cpi_mar cpi year
			gen deflator = cpi_mar/cpi

			save cpi_year, replace 
			project, creates("cpi_year.dta") preserve 

		/* ULCM dollar annual
			cd "`pdir'/data_raw/deflators"
			import delimited using "ulc_dollar.csv",  clear 
			rename ïref_arealabel partner
			rename time period 
			rename obs_value ulc
			keep partner period ulc
			save ulcm, replace 	
	* ULCT
	

	* PPI
	
	
	* EPI
	

