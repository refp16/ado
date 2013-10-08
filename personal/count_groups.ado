*! version 0.2  08aug2013 Roberto E Ferrer Pirela, refp16@gmail.com

program define count_groups, rclass
	
	version 12
	
	syntax varlist
	
	tempname dummy cum_sum
	
	quietly {
	
	    bysort `varlist': gen `dummy' = 1 if (_n==_N)
	
	    gen `cum_sum' = sum(`dummy')
	    
	    return scalar count = `cum_sum'[_N]
    	
    }
	
	display `cum_sum'[_N]
	
end

