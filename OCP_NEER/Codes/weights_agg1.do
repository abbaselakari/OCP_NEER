*--------------------------------Start of do file------------------------------- 

project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"

cd "`pdir'/data_derived/merge"
* Divide data by product and year 
project, uses("ifa-trade2_agg1.dta")
use ifa-trade2_agg1,clear
levelsof t_p_group, local(levels)
foreach l of local levels {
keep if t_p_group == `l' 
cd "`pdir'/data_derived/merge/Agg1" 
save `l', replace 
cd "`pdir'/data_derived/merge" 
use ifa-trade2_agg1, clear
}


use ifa-trade2_agg1, clear 
levelsof t_p_group, local(I)
foreach i  of local I {
cd "`pdir'/data_derived/merge/Agg1"
use `i', clear
egen test = max(partner_j)
if test > 0 {
***Import Weights 
*****Total morocco imports (m)
			egen m_mar =   total(trade) if partnercode == 504 
			levelsof m_mar, local(F)
			foreach f of local F {
			replace m_mar = `f' if m_mar == .
				}
			replace m_mar = 0 if m_mar == .
*********** Compute share of each reporter in partner total imports m_i
			bysort partner : egen tm = total(trade)
			gen m_i  = trade/(tm)
******Total  exports (x)
			bysort reporter :egen x = total(trade) 
*********share of each country in moroccan exports 
**********Total moroccan exports
				gen x_mar = x if reportercode == 504
				levelsof x_mar, local(F)
				foreach f of local F {
				replace x_mar = `f' if x_mar == .
				}
				replace x_mar = 0 if x_mar == .
save temp, replace 
***********Import Weights 
			gen weight_m = m_i*(m_mar/(x_mar+m_mar)) if partnercode == 504
			replace weight_m = 0 if weight_m == .
			levelsof reportercode, local(levels)
			foreach x of local levels {
			gen weight_m_`x'  = weight_m if reportercode == `x'  & partnercode == 504
					levelsof weight_m_`x', local(F)
					foreach f of local F {
					replace weight_m_`x' = `f' if weight_m_`x' == . & partnercode == `x'
					}
			}
			egen weightm = rowtotal(weight_m_*)
			drop weight_m*
			* Expanding the observations 
			gen present = 0 
			levelsof partnercode, local(levels) 
			foreach x of local levels { 
				replace present = 1 if reportercode == `x' 
				}
			tab reporter if present == 0 & partnercode == 504
			levelsof reportercode if present == 0 & partnercode == 504, local(levels)
			foreach x of local levels { 
				expand 2 if reportercode == `x' & present == 0 & partnercode == 504, generate(dup) 
				levelsof reporter if reportercode == `x' & present == 0 & partnercode == 504, local(R)
				levelsof reporteriso if reportercode == `x' & present == 0 & partnercode == 504, local(P)
				replace partnercode = `x'  if dup == 1
					foreach r of local R {
						replace partner = "`r'" if dup == 1
						}
					foreach p of local P { 
						replace partneriso = "`p'" if dup == 1
						}
					replace weightm = weightm if dup == 1 
  					sort partner
					quietly by partner: gen dup2 = cond(_N==1,0,_n) 
					drop if dup2 > 1 & dup == 1
					drop dup2
					drop dup					
				}
			replace weightm = 0 if partnercode == 504
			drop if partnercode == 504
			save temp_m, replace 

**********Export weights 
if test == 2 {
use temp, clear
			levelsof partnercode if reportercode == 504, local(levels)
			foreach x of local levels {
			gen x_i_`x' = trade if partnercode == `x' & reportercode == 504
				levelsof x_i_`x', local(F)
				foreach f of local F {
				replace x_i_`x' = `f' if x_i_`x' == . & partnercode == `x'				
					}
			}
			egen xi = rowtotal(x_i_*)
			drop x_i_*
			gen x_i = xi/x_mar
			/// checking 
			tab trade if partner == "France" & reportercode == 504
			tab xi if partner == "France"
			tab x_i if partner == "France"
		
********Determine total demand of each partner 		
			gen m_i_mar  = (xi/tm)*Imports
			gen y =  (Production - Exports) + (Imports - m_i_mar)
			gen y_t  = (Production - Exports)/y 
			replace y_t = 0 if y_t == .
			replace y = 0 if y ==. 
**********Generating the first term			
			gen alpha = y_t*x_i
********** Compute total imports of each partner 
			gen x_i_k = (m_i)*(Imports)
			bysort partner : egen xc = total(m_i)
			bysort partner : egen cc = total(x_i_k)
			gen pf = Imports - cc
			replace x_i_k = (m_i)*pf +x_i_k
			bysort partner : egen new_cc = total(x_i_k)
			gen new_pf = Imports - new_cc
			tab new_pf
			// check 
			tab x_i_k if partner == "France" & reporter == "Morocco"
			tab trade if partner == "France" & reporter == "Morocco"
			gen beta = x_i_k/y
			replace beta = 0 if beta == .
************ Determine the share of the partner's partner part of moroccan exports 
			 gen sigma = beta*x_i
			 * Sum the partners share in third markets 
			 bysort reporter : egen sum_sigma = total(sigma)
			 * Replicate sigma values to partner 
			levelsof partnercode, local(levels)
			foreach x of local levels {
			gen sigma_`x' = sum_sigma if reportercode == `x' 
				levelsof sigma_`x', local(F)
				foreach f of local F {
				replace sigma_`x' = `f' if sigma_`x' == .		
				replace sigma_`x' = . if partnercode != `x'
				}
			}	
			egen sigm = rowtotal(sigma_*) 
			drop sigma_*
			* Determining recorded reporter but missing as a partner 
			gen present = 0 
			levelsof partnercode, local(levels) 
			foreach x of local levels { 
				replace present = 1 if reportercode == `x' 
				}
			tab reporter if present == 0
			* Expanding the observations 
			levelsof reportercode if present == 0, local(levels)
			foreach x of local levels { 
				expand 2 if reportercode == `x' & present == 0, generate(dup) 
				levelsof reporter if reportercode == `x' & present == 0, local(R)
				levelsof reporteriso if reportercode == `x' & present == 0, local(P)
				replace partnercode = `x'  if dup == 1
					foreach r of local R {
						replace partner = "`r'" if dup == 1
						}
					foreach p of local P { 
						replace partneriso = "`p'" if dup == 1
						}
					replace sigm = sum_sigma if dup == 1 
					replace alpha = 0 if present == 0 & dup == 1
					replace x_i = 0 if present == 0 & dup == 1
 					sort partner
					quietly by partner: gen dup2 = cond(_N==1,0,_n) 
					drop if dup2 > 1 & dup == 1
					drop dup2
					drop dup					
				}
 // checking 
			count if partnercode == reportercode
			drop if reportercode == 504 & partnercode == 504
			* Determination of the global export weight 
			gen w_x = alpha + sigm
***********Export weights 
			keep if partnercode != 504 
			gen double_weights_x = w_x*(x_mar/(x_mar+m_mar)) 
			gen simple_weights_x = x_i*(x_mar/(x_mar+m_mar))
			replace double_weights_x = 0 if double_weights_x ==. 
			replace simple_weights_x = 0 if simple_weights_x ==. 
			save temp_x, replace 
}
***********Merging both weights 
			use temp, clear 
			merge 1:1 partnercode reportercode using temp_m, gen(_merge_weights)
			drop _merge_weights
			if test == 2 {
			merge 1:1 partnercode reportercode using temp_x, gen(_merge_weights)
			drop _merge_weights
			replace weightm = 0 if weightm == .
			gen double_weights = double_weights_x + weightm
			gen simple_weights = simple_weights_x + weightm
			}
			if test == 1 {
			gen double_weights =   weightm
			gen simple_weights =   weightm
			}
			drop if partnercode == 504 & reportercode != 504
cd "`pdir'/data_derived/weights/Agg1"
	save `i', replace
	}
	else {
cd "`pdir'/data_derived/weights/Agg1"
	save `i', replace

	}
	}
	* Merge the weighted files into one
cd "`pdir'/data_derived/weights/Agg1"
clear 
fs *.dta 
append using `r(files)'
cd "`pdir'/data_derived/neer/index/geometric"
* Keep only partners distinct value 
sort t_p_group partner
quietly by t_p_group partner: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup
bysort t_p_group : egen s = total(double_weights)
tab s
* resampling to 1 
gen p = 0 
replace p = 1 if double_weights != 0 
bysort t_p_group : egen r = total(p)
bysort t_p_group : gen e = (1-s)/r
replace double_weights = double_weights + e if double_weights != 0
bysort t_p_group : egen q = total(double_weights)
tab q

keep partner year double_weights simple_weights product  t_p_group
save weights_agg1, replace 
project, creates("weights_agg1.dta") preserve
cd "`pdir'/results"
export excel using "weights.xlsx", firstrow(variables) sheet(`"weights_agg1"') sheetreplace 

*--------------------------------End of do file------------------------------- 
