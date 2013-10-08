*! version 0.1  22aug2013 Roberto E Ferrer Pirela, refp16@gmail.com

program define growth_l
	
	/*
	Creates growth variables given a varlist.	
	Assumes data is sorted by some time variable. 
	Growth is computed in absolute terms (levels). If variable is in logs than the 
	appropriate interpretation can be taken to be (approx.) percentage growth rates.
	*/

	syntax varlist(min=1 numeric)
	
	foreach v of local varlist {
		* Indexed growth (baseperiod to period)
		gen growth_`v' = `v' - `v'[1]
		* Growth (period to period)
		gen growth_`v'_yy = `v' - `v'[_n-1]
	}	

end
