*! version 0.1  22aug2013 Roberto E Ferrer Pirela, refp16@gmail.com
	* TRYing to put graphing code in a program and save some space in do files.
	*Not finished, nor works.
program define stand_figs
	
	version 12
	
	*syntax varlist(max=1 numeric) [if]
	
	*marksample touse, novarlist
	
	* options could be: EITHER growth, indx growth, contribution, levels + Exp # + Variable for subtitle (variance, 9050 gap or 5010 gap)
	
	* call would be stand_figs growth_var_wage growth_Va yearobs "growth" "total variance" "2"
	* Accept only two vars (legend only made for two vars and order must be : realized cf xaxis.
	
	local y1  : word 1 of `varlist' 
	local y2  : word 2 of `varlist' 
	local x  : word 3 of `varlist' 
	local typefig: word 4 of `varlist'
	local varinterest : word 5 of `varlist'
	local expnum : word 6 of `varlist'
		
	if `typefig' == "Growth" | `typefig' == "Idx growth" {
	
		twoway connected `y1' `y2' `x', ///
		title("Realized vs Cf, Exp `expnum'") ///
		subtitle("`typefig' of `varinterest'") ///
		legend( lab(1 "1 Realized") lab(2 "2 Counterf") )		
		window manage close graph
	}
	
	
	if `typefig' == "contrib" {
	
		twoway connected `y1' `y2' `x', ///
		title("Realized vs Cf, Exp `expnum'") ///
		subtitle("Idx growth of `varinterest'") ///
		legend( lab(1 "1 Realized") lab(2 "2 Counterf") )		
		window manage close graph
	}


twoway dropline comp_Va yearobs, ///
	title("Contribution (idx) of agglomeration") ///
	subtitle("to total variance, Exp 3")
graph export "`pdir'/output/`dofile'_ig_tot_var_cont.png", replace width(1600)
project, creates("`pdir'/output/`dofile'_ig_tot_var_cont.png") preserve
window manage close graph
	
	* Tkae these out of the program:
	*graph export "`pdir'/output/`dofile'_ig_tot_var.png", replace width(1600)
	*project, creates("`pdir'/output/`dofile'_ig_tot_var.png") preserve
	
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
