*! version 0.1  10aug2013 Roberto E Ferrer Pirela, refp16@gmail.com

program define perfcorr, rclass byable(recall) sortpreserve
	
	* Very slow. Must speed up some how.
	/* A perfect correlative is defined as a "sequence variable", i.e., one
	that takes the form of increments in a regular pattern. For example: 
	1, 2, 3, 4, 5,... or 0.5, 0.8, 1.1, 1.4,... The variable does not have 
	to be sorted. If the variable has a missing value, then it is not 
	considered a perfect correlative.
	*/
	version 12
	
	syntax varlist(max=1 numeric) [if]
	
	marksample touse, novarlist
	
	tempname dif
	
	quietly {
		
		
		* ---------------- CHECK IF PERFECT CORRELATIVE ------------------------
		
		sort `touse' `_byvars' `varlist'
		
	    by `touse' `_byvars': gen `dif' = `varlist' - `varlist'[_n-1] if `touse'
	
	    misstable summarize `dif' if `touse'
		
		* If max = min and only one missing and that missing is the first obs...
		if r(max) == r(min) & r(N_eq_dot) == 1 & `dif'[1] == . {
						
			scalar perfc = 1
			
		}
		
		else {
				
			scalar perfc = 0			
			
		}
    	
		return scalar perfc = perfc // 1 if perfect correlative, 0 if not.
		
		
		* ----------------------- GET SAMPLE SIZE ------------------------------
		
		summarize `varlist' if `touse'
		
		return scalar N = r(N)
		
    } // close quietly
	
	display "correlative = " perfc ", sample size = " r(N)
	
end
