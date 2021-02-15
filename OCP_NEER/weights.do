/*--------------------------------Start of do file------------------------------- 
the weights do files computes the double weights for each country, for each product 
and for each year, for the disaggregated trade data, it inputs the merged ifa and 
comtrade data sets, and outputs weighted files, the logic is that first the ifa-trade
data is sliced by a group of year product, and then run into the weights function, 
once weights are associated, the sliced datasets are appended together
--------------------------------------------------------------------------------*/
project, doinfo 																// collecting project information
local pdir "`r(pdir)'"															// working directory 
local dofile "`(dofile)'"														// name of the do file 

cd "`pdir'/data_derived/merge"													// setting up the working directory

* Divide data by product and year 
project, uses("ifa-trade2.dta")
use ifa-trade2,clear

levelsof t_p_group, local(levels)												// the division is based on the group of year product eg 2002 product 1 is group 1
foreach l of local levels {
	keep if t_p_group == `l' 
cd "`pdir'/data_derived/merge/Normal" 
	save `l', replace 															// save each slice of dataset apart 
cd "`pdir'/data_derived/merge" 
	use ifa-trade2, replace
}


use ifa-trade2, clear 
levelsof t_p_group, local(I)
foreach i  of local I {															
cd "`pdir'/data_derived/merge/Normal"
use `i', clear																	// input one slice of dataset 
egen test = max(partner_j)														// see if morocco in this dataset is exporting, importing, both or none
if test > 0 {																	// if morocco is present in the dataset then run the weights, otherwise there is no need to do so

***Import Weights***************************************************************// we start by computing the import weights (simple method)
*****Total morocco imports (m)													// 
			egen m_mar =   total(trade) if partnercode == 504 					// total moroccan imports
			levelsof m_mar, local(F)											// we replicate the value to all rows of observation
			foreach f of local F {												// the reason behind this replication exercice is that at the end we would like to use this information 
			replace m_mar = `f' if m_mar == .									// for other countries to compute the import weigths. 
				}
			replace m_mar = 0 if m_mar == .										// having a zero value help us avoid the issue related to having a missing one, 
*********** Compute share of each reporter in partner total imports
			bysort partner : egen tm = total(trade) 							// total imports for each country
			gen m_i  = trade/(tm) 												// share of country exports in total imports of its partner
******Total  exports (x)
			bysort reporter :egen x = total(trade) 								// total exports of each country (reporter) 
*********share of each country in moroccan exports 
**********Total moroccan exports
				gen x_mar = x if reportercode == 504 							// total moroccan exports 
				levelsof x_mar, local(F)
				foreach f of local F {
				replace x_mar = `f' if x_mar == .								// replicate the value on all the rows, same logic as imports
				}
				replace x_mar = 0 if x_mar == .
save temp, replace 																// save the temp file to be used afterwards 
***********Import Weights 
			gen weight_m = m_i*(m_mar/(x_mar+m_mar)) if partnercode == 504 		// imports weigths calculation 
			replace weight_m = 0 if weight_m == .								// missing values are of an issue since they lead to computational issues, where any operation on a missing will lead to a missing unlike zero
			*replicate the value of import weights to the reporter to be added to export weights 
			levelsof reportercode, local(levels)								// slect the reporters
			foreach x of local levels {											// foreach reporter do the following :
		gen weight_m_`x' = weight_m if reportercode == `x' & partnercode == 504 // generate a variable if he is exporting to morocco and put the corresponding import weights value
					levelsof weight_m_`x', local(F)								// get the value of this import weights 
					foreach f of local F {										// and replicates on all entries for this partner 
					replace weight_m_`x' = `f' if weight_m_`x' == . & partnercode == `x'
					}
			}
			egen weightm = rowtotal(weight_m_*) 								// collapse all the columns for each country into one 
			drop weight_m*															
			* Expanding the observations : the above replication process works only if a partner is also present as a reporter, if not we need to create extra entries
			gen present = 0 													// gen a dummy called present = 0 if a country is only a partner but not present as a reporter  
			levelsof partnercode, local(levels) 
			foreach x of local levels { 
				replace present = 1 if reportercode == `x' 						// 1 says that this country is present 
				}
			tab reporter if present == 0 & partnercode == 504					// we consider the set of countries that are not present as partners and are exporting to morocco
			levelsof reportercode if present == 0 & partnercode == 504, local(levels) 
			foreach x of local levels { 										
				expand 2 if reportercode == `x' & present == 0 & partnercode == 504, generate(dup) // expand their values 
				levelsof reporter if reportercode == `x' & present == 0 & partnercode == 504, local(R) // capture thair name
				levelsof reporteriso if reportercode == `x' & present == 0 & partnercode == 504, local(P) // their iso 
				replace partnercode = `x'  if dup == 1							// replace the code by the reporter code 
					foreach r of local R {
						replace partner = "`r'" if dup == 1						// the name 
						}
					foreach p of local P { 
						replace partneriso = "`p'" if dup == 1					// the iso 
						}
					replace weightm = weightm if dup == 1 						// the weights
  					sort partner
					quietly by partner: gen dup2 = cond(_N==1,0,_n) 			// check for duplicates as the above command will result in extra entries
					drop if dup2 > 1 & dup == 1									// drop them
					drop dup2
					drop dup													// and voila 
				}
			replace weightm = 0 if partnercode == 504							// now replace the weights by 0 since morocco need not to have ones
			drop if partnercode == 504											// drop the country morocco 
			save temp_m, replace 												// and then save the import weights temp file 

**********Export weights********************************************************
if test == 2 {																	// if morocco is exporting in this group of product period then compute the export weights 
use temp, clear
			levelsof partnercode if reportercode == 504, local(levels)			// we would like to get the exports value of morocco to that country for all rows of this country
			foreach x of local levels {											// so that each time country (i) is reported we have the value of moroccan exports to it. 
			gen x_i_`x' = trade if partnercode == `x' & reportercode == 504		// and not only in the entry where it is trading with morocco
				levelsof x_i_`x', local(F)
				foreach f of local F {
				replace x_i_`x' = `f' if x_i_`x' == . & partnercode == `x'				
					}
			}
			egen xi = rowtotal(x_i_*) 											// exports of morocco to a reporter i 
			drop x_i_*
			gen x_i = xi/x_mar 													// share of these exports i in total moroccan exports (first term of the exports weights xi/x)
			/// checking 
			tab trade if partner == "France" & reportercode == 504				// checking 
			tab xi if partner == "France"										// it should give the same value 
			tab x_i if partner == "France"
		
********Determine total demand of each partner 		
			gen m_i_mar  = (xi/tm)*Imports 										// imports of partner from morocco based on ifa, 
			gen y =  (Production - Exports) + (Imports - m_i_mar) 				// domestic production
			gen y_t  = (Production - Exports)/y 								// share of domestic production in total demand
			replace y_t = 0 if y_t == .											// get rid of missing values 
			replace y = 0 if y ==. 
**********Generating the first term			
			gen alpha = y_t*x_i 												// the first term of the exports double weights, we call it alpha
********** Compute total imports of each partner 
			gen x_i_k = (m_i)*(Imports)											// exports of reporter to partner using ifa data
			bysort partner : egen xc = total(m_i) 								// needs to sum to 1 : xc is the total imports share of a partner 
			bysort partner : egen cc = total(x_i_k) 							// : cc is the value of theses imports, it should correspond to the iFA import value
			gen pf = Imports - cc												// now we check if there is any difference between IFA original Imports value and cc computed above
			replace x_i_k = (m_i)*pf +x_i_k										// if there is any difference we correct for it. 
			bysort partner : egen new_cc = total(x_i_k)							// and we check again, 
			gen new_pf = Imports - new_cc 										// 
			tab new_pf															// new_pf values should be close to 0
			// check 
			tab x_i_k if partner == "France" & reporter == "Morocco"
			tab trade if partner == "France" & reporter == "Morocco"
			gen beta = x_i_k/y 													// the share of partner exports in the supply of the other partner demand (the last term of the double export weights equation)
			replace beta = 0 if beta == .										// again dealing with missing values 
************ Determine the share of the partner's partner part of moroccan exports 
			 gen sigma = beta*x_i 												// the second term of double weights, notice that sigma term is what a country is importing from multiple ones, taking advantage of the fact that bilateral 
			 * Sum the partners share in third markets 							// trade data is mirrored (ones exports is another one import), and to make it easier to compute the second term of equation (third market effects) 
			 bysort reporter : egen sum_sigma = total(sigma) 					// by summing the sigma term over exporters we get the intended value 
			 * Replicate sigma values to partner 								
			levelsof partnercode, local(levels)									// here we replicate the sigma values over reporters
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
			gen w_x = alpha + sigm												// double export weights.
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
cd "`pdir'/data_derived/weights/Normal"
	save `i', replace

	}
	else {
cd "`pdir'/data_derived/weights/Normal"
	save `i', replace

	}
	}
	* Merge the weighted files into one
cd "`pdir'/data_derived/weights/Normal"
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
keep partner year double_weights simple_weights product t_p_group 
save weights, replace 
project, creates("weights.dta") preserve
cd "`pdir'/results"
export excel using "weights.xlsx", firstrow(variables) sheet(`"weights"') sheetreplace 
*--------------------------------End of do file------------------------------- 
