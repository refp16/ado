*! version 0.1  22aug2013 Roberto E Ferrer Pirela, refp16@gmail.com

program define growth_p
	
	/*
	Creates growth variables given a varlist.
	Assumes data is sorted by some time variable. 
	Growth is computed in relative terms (percentages).
	Values of output variable are %. For example, 35 == 35%.
	*/

	syntax varlist(min=1 numeric)
	
	foreach v of local varlist {
		* Indexed growth (baseperiod to period)
		gen growth_`v' = ((`v' / `v'[1]) - 1) * 100
		* Growth (period to period)
		gen growth_`v'_yy = ((`v' / `v'[_n-1]) - 1) * 100
	}	

end
