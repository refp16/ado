program define imputw, byable(recall)
	
	/*
	Downloaded from http://fdz.iab.de/187/section.aspx/Publikation/k050719a04
	Based on Gartner, Herman. "The Imputation of Wages Above the Contribution 
	Limit with the German IAB Employment Sample." FDZ, 2005.
    */
	
	version 8
	
	syntax varlist [if] , Cens(varlist) Grenze(varlist) [Outvar(string asis)]

    marksample touse
	
	* If no name given to the output, call it by default "lnw_i".
    if "`outvar'" == "" {
		local outvar "lnw_i" 
    }
	
	* Estimate Tobit model
	cnreg `varlist' if `touse', censored(`cens') 
	
	quietly {
		* Make predictions
		predict xb00 if `touse'  , xb
		* Generate standardized limit for each value
		gen alpha00=(ln(`grenze')-xb00)/_b[_se] if `touse'  
    }

	cap gen  `outvar'=.
	replace `outvar'=`1' if `touse'  
	
	* Imputation
	replace `outvar'=xb00+_b[_se] * invnorm(uniform()*(1-norm(alpha00))+norm(alpha00)) if `touse'   & `cens'
 	
	drop xb00 alpha00
	
end

