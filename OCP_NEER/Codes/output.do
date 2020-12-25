*--------------------------------Start of do file------------------------------- 
project, doinfo 
local pdir "`r(pdir)'"
local dofile "`(dofile)'"


* Analysis 
cd "`pdir'/data_derived/neer/year"
project, uses("neer_year_weights.dta")
use  neer_year_weights.dta, clear
drop if t_p_group == .
tw (line neer year if product == 1  ) ///
 (line neer year  if product == 2  )  /// 
 (line neer year if product == 3 ) ///
 (line neer year if product == 4 ) ///
 (line neer year if product == 5 ), ///
 title("neer for all products") ///
legend(order(1 "DAP" 2 "MAP" 3 "PA" 4 "PR" 5 "TSP"))
cd "`pdir'/results"
graph export "neer_yearly.pdf", replace 
keep partner year product double_weights simple_weights neer
export excel using "neer_yearly.xlsx", firstrow(variables) datestring("%tm") replace 

cd "`pdir'/data_derived/neer/year"
project, uses("neer_year_weights_agg1.dta")
use  neer_year_weights_agg1.dta, clear
drop if t_p_group == .
tw (line neer year if product == 1  ) ///
 (line neer year if product == 3 ) ///
 (line neer year if product == 4 ), ///
legend(order(1 "fertilizers"  2 "PA" 3 "PR" )) /// 
title("neer for fertilizers aggregated, PR and PA")
cd "`pdir'/results"
graph export "neer_yearly_fertilizers.pdf", replace 
keep partner year product double_weights simple_weights neer
export excel using "neer_yearly_fertilizers.xlsx", firstrow(variables) datestring("%tm")  replace 

cd "`pdir'/data_derived/neer/year"
project, uses("neer_year_weights_agg2.dta")
use  neer_year_weights_agg2.dta, clear
drop if t_p_group == .
tw (line neer year if product == 1  ) ///
 (line neer year  if product == 2  )  /// 
 (line neer year if product == 3 ) ///
 (line neer year if product == 4 ) ///
 (line neer year if product == 5 ), ///
legend(order(1 "OCP")) ///
title("Neer for the OCP")
cd "`pdir'/results"
graph export "neer_yearly_ocp.pdf", replace 
keep partner year product double_weights simple_weights neer
export excel using "neer_yearly_ocp.xlsx", firstrow(variables) datestring("%tm")  replace 

*--------------------------------NEER MONTH------------------------------- 

cd "`pdir'/data_derived/neer/month"
project, uses("neer_month_weights.dta")
use  neer_month_weights.dta, clear
drop if t_p_group == .
tw (line neer month if product == 1  ) ///
 (line neer month  if product == 2  )  /// 
 (line neer month if product == 3 ) ///
 (line neer month if product == 4 ) ///
 (line neer month if product == 5 ), ///
legend(order(1 "DAP" 2 "MAP" 3 "PA" 4 "PR" 5 "TSP")) ///
title("neer for all products") 
cd "`pdir'/results"
graph export "neer_monthly.pdf", replace 
keep partner month product double_weights simple_weights neer
export excel using "neer_monthly.xlsx", firstrow(variables) datestring("%tm")   replace 

cd "`pdir'/data_derived/neer/month"
project, uses("neer_month_weights_agg1.dta")
use  neer_month_weights_agg1.dta, clear
drop if t_p_group == .
tw (line neer month if product == 1  ) ///
 (line neer month if product == 3 ) ///
 (line neer month if product == 4 ), ///
legend(order(1 "fertilizers"  2 "PA" 3 "PR" )) ///
title("neer fertilizers, PR, PA") 
cd "`pdir'/results"
graph export "neer_monthly_fertilizers.pdf", replace 
keep partner month product double_weights simple_weights neer
export excel using "neer_monthly_fertilizers.xlsx", firstrow(variables) datestring("%tm")  replace 

cd "`pdir'/data_derived/neer/month"
project, uses("neer_month_weights_agg2.dta")
use  neer_month_weights_agg2.dta, clear
drop if t_p_group == .
tw (line neer month if product == 1  ) ///
 (line neer month  if product == 2  )  /// 
 (line neer month if product == 3 ) ///
 (line neer month if product == 4 ) ///
 (line neer month if product == 5 ), ///
legend(order(1 "OCP")) /// 
title("Neer for the OCP")
cd "`pdir'/results"
graph export "neer_monthly_ocp.pdf", replace 
keep partner month product double_weights simple_weights neer
export excel using "neer_monthly_ocp.xlsx", firstrow(variables) datestring("%tm")   replace 



*--------------------------------REER MONTH------------------------------- 

cd "`pdir'/data_derived/reer/month"
project, uses("reer_neer_month_weights.dta")
use  reer_neer_month_weights.dta, clear
drop if t_p_group == .
tw (line reer month if product == 1  ) ///
 (line reer month  if product == 2  )  /// 
 (line reer month if product == 3 ) ///
 (line reer month if product == 4 ) ///
 (line reer month if product == 5 ), ///
legend(order(1 "DAP" 2 "MAP" 3 "PA" 4 "PR" 5 "TSP")) ///
title("reer for all products") 
cd "`pdir'/results"
graph export "reer_monthly.pdf", replace 
keep partner month product double_weights simple_weights neer reer
export excel using "reer_monthly.xlsx", firstrow(variables) datestring("%tm")  replace

cd "`pdir'/data_derived/reer/month"
project, uses("reer_neer_month_weights_agg1.dta")
use  reer_neer_month_weights_agg1.dta, clear
drop if t_p_group == .
tw (line reer month if product == 1  ) ///
 (line reer month if product == 3 ) ///
 (line reer month if product == 4 ), ///
legend(order(1 "fertilizers"  2 "PA" 3 "PR" )) ///
title("reer fertilizers, PR, PA") 
cd "`pdir'/results"
graph export "reer_monthly_fertilizers.pdf", replace 
keep partner month product double_weights simple_weights neer reer 
export excel using "reer_monthly_fertilizers.xlsx", firstrow(variables) datestring("%tm")  replace

cd "`pdir'/data_derived/reer/month"
project, uses("reer_neer_month_weights_agg2.dta")
use  reer_neer_month_weights_agg2.dta, clear
drop if t_p_group == .
tw (line reer month) ///
	(line neer month), ///
legend(order(1 "reer" 2 "neer")) /// 
title("reer and neer for the OCP")
cd "`pdir'/results"
graph export "reer_monthly_ocp.pdf", replace 
keep partner month product double_weights simple_weights neer reer
export excel using "reer_monthly_ocp.xlsx", firstrow(variables) datestring("%tm")   replace

*--------------------------------REER Year------------------------------- 

cd "`pdir'/data_derived/reer/year"
project, uses("reer_neer_year_weights.dta")
use  reer_neer_year_weights.dta, clear
drop if t_p_group == .
tw (line reer year if product == 1  ) ///
 (line reer year  if product == 2  )  /// 
 (line reer year if product == 3 ) ///
 (line reer year if product == 4 ) ///
 (line reer year if product == 5 ), ///
legend(order(1 "DAP" 2 "MAP" 3 "PA" 4 "PR" 5 "TSP")) ///
title("reer for all products") 
cd "`pdir'/results"
graph export "reer_yearly.pdf", replace 
keep partner year product double_weights simple_weights neer reer
export excel using "reer_yearly.xlsx", firstrow(variables) datestring("%tm")  replace

cd "`pdir'/data_derived/reer/year"
project, uses("reer_neer_year_weights_agg1.dta")
use  reer_neer_year_weights_agg1.dta, clear
drop if t_p_group == .
tw (line reer year if product == 1  ) ///
 (line reer year if product == 3 ) ///
 (line reer year if product == 4 ), ///
legend(order(1 "fertilizers"  2 "PA" 3 "PR" )) ///
title("reer fertilizers, PR, PA") 
cd "`pdir'/results"
graph export "reer_yearly_fertilizers.pdf", replace 
keep partner year product double_weights simple_weights neer reer 
export excel using "reer_yearly_fertilizers.xlsx", firstrow(variables) datestring("%tm")  replace

cd "`pdir'/data_derived/reer/year"
project, uses("reer_neer_year_weights_agg2.dta")
use  reer_neer_year_weights_agg2.dta, clear
drop if t_p_group == .
tw (line reer year) ///
	(line neer year), ///
legend(order(1 "reer" 2 "neer")) /// 
title("reer and neer for the OCP")
cd "`pdir'/results"
graph export "reer_yearly_ocp.pdf", replace 
keep partner year product double_weights simple_weights neer reer
export excel using "reer_yearly_ocp.xlsx", firstrow(variables) datestring("%tm")   replace
*--------------------------------End of do file---------------------------------

