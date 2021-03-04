project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"
*--------------------------------Start of do file------------------------------- 
*Exporting To Excel files 
	* NEER 
		* INDEX geometric
			*Year
				*neer
				cd "`pdir'/data_derived/neer/index/geometric/year"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_year_weights|\.dta", "") 
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}
					* Exporting to exel files
					cd "`pdir'/results/neer/year"
					export excel ///
					year product neer_double neer_simple ///
					using "neer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"index_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/index/geometric/year"
				}
			* Month
				cd "`pdir'/data_derived/neer/index/geometric/month"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_month_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/month"
					export excel ///
					month product neer_double neer_simple ///
					using "neer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_index_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/index/geometric/month"
				}
		* INDEX ARITHMETIC
			* Year
				cd "`pdir'/data_derived/neer/index/arithmetic/year"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_year_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/year"
					export excel ///
					 year product neer_double neer_simple ///
					using "neer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_index_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/index/arithmetic/year"
				}
			* month 
				cd "`pdir'/data_derived/neer/index/arithmetic/month"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_month_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/month"
					export excel ///
					 month product neer_double neer_simple ///
					using "neer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_index_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/index/arithmetic/month"
				}	
		* Variation geometric
			* Year 
				cd "`pdir'/data_derived/neer/variation/geometric/year"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_year_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/year"
					export excel ///
					year product neer_double neer_simple var_neer_double var_neer_simple ///
					using "neer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_variation_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/variation/geometric/year"
				}
			* month
				cd "`pdir'/data_derived/neer/variation/geometric/month"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_month_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/month"
					export excel ///
					 month product neer_double neer_simple var_neer_simple var_neer_double ///
					using "neer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_variation_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/variation/geometric/month"
				}
		* Variation arithmetic
			* Year
				cd "`pdir'/data_derived/neer/variation/arithmetic/year"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_year_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/year"
					export excel ///
					 year product var_neer_double var_neer_simple ///
					using "neer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_variation_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/variation/arithmetic/year"
				}
			* month 
				cd "`pdir'/data_derived/neer/variation/arithmetic/month"
				local myfiles : dir . files "neer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "neer_month_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/neer/month"
					export excel ///
					 month product var_neer_double var_neer_simple ///
					using "neer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"neer_variation_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/neer/variation/arithmetic/month"
				}	
	* REER
		* INDEX geometric
			*Year
				*reer
				cd "`pdir'/data_derived/reer/index/geometric/year"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_neer_year_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/year"
					export excel ///
					year product reer_double reer_simple ///
					using "reer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_index_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/index/geometric/year"
				}
			* Month
				cd "`pdir'/data_derived/reer/index/geometric/month"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_month_neer_month_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/month"
					export excel ///
					 month product reer_double reer_simple ///
					using "reer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_index_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/index/geometric/month"
				}
		* INDEX ARITHMETIC
			* Year
				cd "`pdir'/data_derived/reer/index/arithmetic/year"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/year"
					export excel ///
					 year product reer_double reer_simple ///
					using "reer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_index_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/index/arithmetic/year"
				}
			* month 
				cd "`pdir'/data_derived/reer/index/arithmetic/month"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/month"
					export excel ///
					 month product reer_double reer_simple ///
					using "reer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_index_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/index/arithmetic/month"
				}	
		* Variation geometric
			* Year 
				cd "`pdir'/data_derived/reer/variation/geometric/year"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_year_variation_neer_year_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/year"
					export excel ///
					 year product var_reer_double var_reer_simple ///
					using "reer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_variation_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/variation/geometric/year"
				}
			* month
				cd "`pdir'/data_derived/reer/variation/geometric/month"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_month_variation_neer_month_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/month"
					export excel ///
					 month product var_reer_double var_reer_simple ///
					using "reer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_variation_geometric"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/variation/geometric/month"
				}
		* Variation arithmetic
			* Year
				cd "`pdir'/data_derived/reer/variation/arithmetic/year"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort year product 
					quietly by year product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/year"
					export excel ///
					 year product var_reer_double var_reer_simple ///
					using "reer_year`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_variation_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/variation/arithmetic/year"
				}
			* month  
				cd "`pdir'/data_derived/reer/variation/arithmetic/month"
				local myfiles : dir . files "reer*.dta"
				foreach file of local myfiles { 
					use `file', clear
					sort month product 
					quietly by month product : gen dup = cond(_N == 1,0,_n)
					drop if dup > 1
					drop dup 
					local x = ustrregexra("`file'", "reer_variation_weights|\.dta", "")
					if ("`x'" == "_agg2") {
					keep if product == 1 
					}
					if ("`x'" == "_agg1") { 
					keep if product == 1 | product == 3 | product == 4 
					}

					* Exporting to exel files
					cd "`pdir'/results/reer/month"
					export excel ///
					 month product var_reer_double var_reer_simple ///
					using "reer_month`x'.xlsx", /// 
					firstrow(variables) sheet(`"reer_variation_arithmetic"') sheetreplace datestring("%tm")
				cd "`pdir'/data_derived/reer/variation/arithmetic/month"
				}	

