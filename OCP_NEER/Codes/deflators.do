project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"
* Deflators 
	* CPI 
		* Import CPI 
			//project original
			cd "`pdir'/data_raw/deflators"
			import excel using "cpi.xlsx", firstrow cellrange(A3) clear
			drop B  
			foreach v of varlist _all {
			local x : variable label `v'
			rename `v' year`x'
			}
			rename year partner
			reshape long year, i(partner) j(period, string)
			rename year cpi 
			* Extract dates
			gen year = regexs(0) if regexm(period, "^([0-9][0-9][0-9][0-9])")
			gen Month = regexr(period, "[M]","/")
			gen month = monthly(Month, "YM")
			format month %tm
			replace month = . if regexm(Month, "[Q]")
			drop if month == .
			drop Month
			* duplicate for products
			expand 5, gen(dup)
			drop dup 
			sort partner month 
			quietly by partner month : gen product = cond(_N==1,0,_n)
			* match country names
				replace partner = "Afghanistan" if partner == "Afghanistan, Islamic Republic of"
				replace partner = "Armenia" if partner == "Armenia, Republic of"
				replace partner = "Azerbaijan" if partner == "Azerbaijan, Republic of"
				replace partner = "Bahamas" if partner == "Bahamas, The"
				replace partner = "Bahrain" if partner == "Bahrain, Kingdom of"
				replace partner = "Bolivia (Plurinational State of)" if partner == "Bolivia"
				replace partner = "Bonaire" if partner == "Bonaire, Sint Eustatius and Saba"
				replace partner = "Bosnia Herzegovina" if partner == "Bosnia and Herzegovina"
				replace partner = "Cayman Isds" if partner == "Cayman Islands"
				replace partner = "Central African Rep." if partner == "Central African Republic"
				replace partner = "China, Hong Kong SAR" if partner == "China, P.R.: Hong Kong"
				replace partner = "China, Macao SAR" if partner == "China, P.R.: Macao"
				replace partner = "China" if partner == "China, P.R.: Mainland"
				replace partner = "Dem. Rep. of the Congo" if partner == "Congo, Democratic Republic of"
				replace partner = "Congo" if partner == "Congo, Republic of"
				replace partner = "Cook Isds" if partner == "Cook Islands"
				replace partner = "C̫te d'Ivoire" if partner == "Cote d'Ivoire"
				replace partner = "Cura̤ao" if partner == "Curacao"
				replace partner = "Czechia" if partner == "Czech Republic"
				replace partner = "Dominican Rep." if partner == "Dominican Republic"
				replace partner = "Eswatini" if partner == "Eswatini, Kingdom of"
				replace partner = "Faeroe Isds" if partner == "Faroe Islands"
				replace partner = "French Polynesia" if partner == "French Territories: French Polynesia"
				replace partner = "Gambia" if partner == "Gambia, The"
				replace partner = "New Caledonia" if partner == "French Territories: New Caledonia"
				replace partner = "Iran" if partner == "Iran, Islamic Republic of"
				replace partner = "Dem. People's Rep. of Korea" if partner == "Korea, Democratic People's Rep. of"
				replace partner = "Rep. of Korea" if partner == "Korea, Republic of"
				replace partner = "Kyrgyzstan" if partner == "Kyrgyz Republic"
				replace partner = "Lao People's Dem. Rep." if partner == "Lao People's Democratic Republic"
				replace partner = "Marshall Isds" if partner == "Marshall Islands, Republic of"
				replace partner = "Rep. of Moldova" if partner == "Moldova"
				replace partner = "Neth. Antilles" if partner == "Netherlands Antilles"
				replace partner = "Norfolk Isds" if partner == "Norfolk Island"
				replace partner = "North Macedonia" if partner == "North Macedonia, Republic of"
				replace partner = "N. Mariana Isds" if partner == "Northern Mariana Isl"
				replace partner = "FS Micronesia" if partner == "Micronesia, Federated States of"
				replace partner = "Serbia" if partner == "Serbia, Republic of"
				replace partner = "Saint Maarten" if partner == "Sint Maarten"
				replace partner = "Slovakia" if partner == "Slovak Republic"
				replace partner = "Solomon Isds" if partner == "Solomon Islands"
				replace partner = "Saint Kitts and Nevis" if partner == "St. Kitts and Nevis"
				replace partner = "Saint Lucia" if partner == "St. Lucia"
				replace partner = "Saint Vincent and the Grenadines" if partner == "St. Vincent and the Grenadines"
				replace partner = "Syria" if partner == "Syrian Arab Republic"
				replace partner = "Timor-Leste" if partner == "Timor-Leste, Dem. Rep. of"
				replace partner = "Tokelau" if partner == "Tokelau Islands"
				replace partner = "Turks and Caicos Isds" if partner == "Turks and Caicos Islands"
				replace partner = "USA" if partner == "United States"
				replace partner = "United Rep. of Tanzania" if partner == "Tanzania"
				replace partner = regexs(0) if regexm(partner, "(Venezuela)") 
				replace partner = "Viet Nam" if partner == "Vietnam"
				replace partner = "Br. Virgin Isds" if partner == "Virgin Islands, British"
				replace partner = "Wallis and Futuna Isds" if partner == "Wallis and Futuna"
				replace partner = "State of Palestine" if partner == "West Bank and Gaza"
				replace partner = "Yemen" if partner == "Yemen, Republic of"
			cd "`pdir'/data_derived/merge"
			merge m:1 partner using iso, gen(_merge_iso)			
			keep if _merge_iso == 3
			drop _merge_iso
			cd "`pdir'/data_derived/deflators"
			* Replicate values for computation 
			* generate cpi as an index based 100 
			drop if cpi == .
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
			*/
			* Standardization of the serie 
			egen mean = mean(cpi)
			egen max = max(cpi)
			egen min = min(cpi)
			egen std = sd(cpi)
			gen cpi_sd = (cpi - min)/(max - min)
			* Generation of Moroccan cpi nominator 
			gen cpi_mar = cpi_sd if partner == "Morocco"
			bysort month (cpi_mar) : replace cpi_mar = cpi_mar[_n-1] if missing(cpi_mar)	
			drop if cpi_mar == .
			keep partner month cpi product cpi_mar cpi_sd
			gen deflator = cpi_mar/cpi_sd
			
			cd "`pdir'/data_derived/deflators"
			save cpi_month, replace		
			project, creates("cpi_month.dta")
			
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
	
