project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"
* Deflators 
	* CPI 
		* Import CPI 
			//project original
			cd "`pdir'/data_raw/deflators"
			import excel using "cpi_2.xlsx", firstrow cellrange(B7) clear
			drop BaseYear Scale 
			foreach v of varlist _all {
			local x : variable label `v'
			rename `v' year`x'
			}
			rename yearCountry partner
			reshape long year, i(partner) j(period, string)
			rename year cpi 

			* match country names
				replace partner = "Afghanistan" if partner == "Afghanistan, Islamic Rep. of"
				replace partner = "Armenia" if partner == "Armenia, Rep. of"
				replace partner = "Aruba" if partner == "Aruba, Kingdom of the Netherlands"
				replace partner = "Azerbaijan" if partner == "Azerbaijan, Rep. of"
				replace partner = "Bahamas" if partner == "Bahamas, The"
				replace partner = "Belarus" if partner == "Belarus, Rep. of"
				replace partner = "Comoros" if partner == "Comoros, Union of the"
				replace partner = "Croatia" if partner == "Croatia, Rep. of"
				replace partner = "Egypt" if partner == "Egypt, Arab Rep. of"
				replace partner = "Saint Maarten" if partner == "Sint Maarten, Kingdom of the Netherlands"
				replace partner = "Equatorial Guinea" if partner == "Equatorial Guinea, Rep. of"
				replace partner = "Estonia" if partner == "Estonia, Rep. of"
				replace partner = "Ethiopia" if partner == "Ethiopia, The Federal Dem. Rep. of"
				replace partner = "Fiji" if partner == "Fiji, Rep. of"
				replace partner = "Lesotho" if partner == "Lesotho, Kingdom of"
				replace partner = "Madagascar" if partner == "Madagascar, Rep. of"
				replace partner = "Mauritania" if partner == "Mauritania, Islamic Rep. of"
				replace partner = "Mozambique" if partner == "Mozambique, Rep. of"
				replace partner = "Nauru" if partner == "Nauru, Rep. of"
				replace partner = "Netherlands" if partner == "Netherlands, The"
				replace partner = "Palau" if partner == "Palau, Rep. of"
				replace partner = "Poland" if partner == "Poland, Rep. of"
				replace partner = "San Marino" if partner == "San Marino, Rep. of"
				replace partner = "Slovenia" if partner == "Slovenia, Rep. of"
				replace partner = "South Sudan" if partner == "South Sudan, Rep. of"
				replace partner = "Tajikistan" if partner == "Tajikistan, Rep. of"
				replace partner = "Rep. of Moldova" if partner == "Moldova, Rep. of"
				replace partner = "Bahrain" if partner == "Bahrain, Kingdom of"
				replace partner = "Bolivia (Plurinational State of)" if partner == "Bolivia"
				replace partner = "Bonaire" if partner == "Bonaire, Sint Eustatius and Saba"
				replace partner = "Bosnia Herzegovina" if partner == "Bosnia and Herzegovina"
				replace partner = "Cayman Isds" if partner == "Cayman Islands"
				replace partner = "Central African Rep." if partner == "Central African Republic"
				replace partner = "China, Hong Kong SAR" if partner == "China, P.R.: Hong Kong"
				replace partner = "China, Macao SAR" if partner == "China, P.R.: Macao"
				replace partner = "China" if partner == "China, P.R.: Mainland"
				replace partner = "Dem. Rep. of the Congo" if partner == "Congo, Dem. Rep. of the"
				replace partner = "Congo" if partner == "Congo, Rep. of"
				replace partner = "Cook Isds" if partner == "Cook Islands"
				replace partner = "C̫te d'Ivoire" if regexm(partner, "(Ivoire)")
				replace partner = "Cura̤ao" if regexm(partner, "(Kingdom of the Netherlands)")
				replace partner = "Czechia" if partner == "Czech Rep."
				replace partner = "Dominican Rep." if partner == "Dominican Republic"
				replace partner = "Eswatini" if partner == "Eswatini, Kingdom of"
				replace partner = "Faeroe Isds" if partner == "Faroe Islands"
				replace partner = "French Polynesia" if partner == "French Territories: French Polynesia"
				replace partner = "Gambia" if partner == "Gambia, The"
				replace partner = "New Caledonia" if partner == "French Territories: New Caledonia"
				replace partner = "Iran" if partner == "Iran, Islamic Rep. of"
				replace partner = "Dem. People's Rep. of Korea" if partner == "Korea, Democratic People's Rep. of"
				replace partner = "Rep. of Korea" if partner == "Korea, Rep. of"
				replace partner = "Kyrgyzstan" if partner == "Kyrgyz Rep."
				replace partner = "Lao People's Dem. Rep." if partner == "Lao People's Democratic Republic"
				replace partner = "Marshall Isds" if partner == "Marshall Islands, Republic of"
				replace partner = "Neth. Antilles" if partner == "Netherlands Antilles"
				replace partner = "Norfolk Isds" if partner == "Norfolk Island"
				replace partner = "North Macedonia" if partner == "North Macedonia, Republic of"
				replace partner = "N. Mariana Isds" if partner == "Northern Mariana Isl"
				replace partner = "FS Micronesia" if partner == "Micronesia, Federated States of"
				replace partner = "Serbia" if partner == "Serbia, Rep. of"
				replace partner = "Slovakia" if partner == "Slovak Rep."
				replace partner = "Solomon Isds" if partner == "Solomon Islands"
				replace partner = "Saint Kitts and Nevis" if partner == "St. Kitts and Nevis"
				replace partner = "Saint Lucia" if partner == "St. Lucia"
				replace partner = "Saint Vincent and the Grenadines" if partner == "St. Vincent and the Grenadines"
				replace partner = "Syria" if partner == "Syrian Arab Rep."
				replace partner = "Timor-Leste" if partner == "Timor-Leste, Dem. Rep. of"
				replace partner = "Tokelau" if partner == "Tokelau Islands"
				replace partner = "Turks and Caicos Isds" if partner == "Turks and Caicos Islands"
				replace partner = "USA" if partner == "United States"
				replace partner = "United Rep. of Tanzania" if partner == "Tanzania, United Rep. of"
				replace partner = regexs(0) if regexm(partner, "(Venezuela)") 
				replace partner = "Viet Nam" if partner == "Vietnam"
				replace partner = "Br. Virgin Isds" if partner == "Virgin Islands, British"
				replace partner = "Wallis and Futuna Isds" if partner == "Wallis and Futuna"
				replace partner = "State of Palestine" if partner == "West Bank and Gaza"
				replace partner = "Yemen" if partner == "Yemen, Rep. of"
			    replace partner =  "Sao Tome and Principe" if regexm(partner, "(ncipe)")
			
			* Merge with ISO from comtrade 
			cd "`pdir'/data_derived/merge"
			merge m:1 partner using iso, gen(_merge_iso)			
			keep if _merge_iso == 3
			drop _merge_iso
			cd "`pdir'/data_derived/deflators"
			replace cpi = "." if cpi == "..."
			gen cpi_1 = real(cpi)
			drop cpi 
			rename cpi_1 cpi 
			drop if cpi == .
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
	

