*! version 0.2  26aug2013 Roberto E Ferrer Pirela, refp16@gmail.com

program define growth_l2
	
	/*
	Creates growth variables given a varlist.	
	Assumes data is sorted by some time variable. 
	Growth is computed in absolute terms (levels). If variable is in logs than the 
	appropriate interpretation can be taken to be (approx.) percentage growth rates.
	User must give prefix/suffix to be used in resulting variable names.
	*/
	
	version 12
	
	syntax varlist(min=1 numeric) [if], [varpre(string) varsu(string)]
	
	marksample touse
	
	* If neither prefix nor suffix is provided, give error. Output variables cannot 
	* have same name as input variables.
    if "`varpre'" == "" & "`varsu'" == "" {
		dis as err "Must give either prefix or suffix for output name."
		exit 
    }

	* Compute growth for each variable in varlist.
	foreach v of local varlist {
	
		* Indexed growth (baseperiod to period)
		*gen `outvarpre'growth_`v'`outvarsu' = `v' - `v'[1] if `touse'
		gen `varpre'`v'`varsu'  = `v' - `v'[1] if `touse'
		
		* Growth (period to period)
		*gen `outvarpre'growth_`v'_yy`outvarsu' = `v' - `v'[_n-1] if `touse'
		gen `varpre'`v'_yy`varsu' = `v' - `v'[_n-1] if `touse'
		
	}	

end
