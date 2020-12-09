set more off 
set varabbrev off
set linesize 132


project, do("Codes/comtrade.do")
project, do("Codes/ifa.do")
project, do("Codes/merge_trade_ifa.do")
project, do("Codes/weights.do")
project, do("Codes/weights_agg1.do")
project, do("Codes/weights_agg2.do")
project, do("Codes/exchange.do")
project, do("Codes/neer_year.do")
project, do("Codes/neer_month.do")
project, do("Codes/deflators.do")
project, do("Codes/reer_month.do")
project, do("Codes/output.do")

