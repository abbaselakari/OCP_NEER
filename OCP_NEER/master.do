/* The first piece of this programm is the following master do file, it is 
responsible for running all the other do files one after one, and checking their
dependenices i.e. the data files on wich each do file relies on to process, input 
and output results, if no change has been made to a dependency or to the do file itself
the master do file will just skip running it and then move to the next one 

To run the following programm start by installing the project package by typing 
	ssc install project 
once its done select the following do file to be the master file by typing  
	project, setup 
a pop up window will open asking you to select the master do file (this one)
once done, you can run the programm by typing 
	project master, build
This will run all the do files associated with the program. 
*/

* First we start by setting up little tweaks in the environement
set more off 
set varabbrev off
set linesize 132

* These are the do files that are going to be run by this do file
project, do("Codes/comtrade.do")
project, do("Codes/ifa.do")
project, do("Codes/exchange.do")
project, do("Codes/deflators.do")
project, do("Codes/merge_trade_ifa.do")
project, do("Codes/weights.do")
project, do("Codes/weights_agg1.do")
project, do("Codes/weights_agg2.do")
project, do("Codes/neer_year.do")
project, do("Codes/neer_month.do")
project, do("Codes/reer_month.do")
project, do("Codes/reer_year.do")
project, do("Codes/neer_index_arithmetic_month.do")
project, do("Codes/neer_index_arithmetic_year.do")
project, do("Codes/reer_index_arithmetic_month.do")
project, do("Codes/reer_index_arithmetic_year.do")
project, do("Codes/output.do")
project, do("Codes/decomposition.do")
project, do("Codes/export_excel.do")

* Note : you can comment out a do file so that it is not run ,
