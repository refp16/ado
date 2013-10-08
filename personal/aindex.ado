*! aindex, version 1.1, Soledad Giardili
*
* This program creates a summarize index of a group of variables 
* according to * Appendix A of Anderson 2007. Under an experiment
* (control/treatment) the main * objetive is to create a summarize 
* index for different dimension. For this purpose you need weight 
* from the product-sum of standarized variables. This standarization
* is according to the standard deviation of the variable for those 
* in the control groups. This means than the index give more weight 
* to variables with more variance in the control group and less to 
* variables highly correlated
* 
* NOTE, WE DO NOT DO THE ABOVE HERE! We do not have control/treatment 
* so variables are standardized according to the standard deviation of
* the variable. Now we obtain a product-sum of standarized variables 
* (X'X) that is equal to the correlation matrix multiply by n^2. So we
* do not need the mata syntax but keep to really construct Anderson's 
* index in the future.
*
* 1) -aindex- calculate the weights for the index using only non-missing data
* 2) -aindex- stardardized al variables son mean is zero and standard deviation
*     is equal to 1. TEST.
*
* Syntax:
* =======
*
* aindex varlist [if] [in], [GENerate(string)]
*
* Notes:
* ======
*
* (1) For all outcomes, switch signs where necessary so that the 
*     positive direction always indicates a “better” outcome.
*
* ==============================================================
* SG
* This version:  17. October 2012
* First version: 17. October 2012
* ==============================================================

// FALTA PONER LA OPCION TRATMENT Y CAMBIAR LA FORMA DE ESTANDARIZAR, NO OLVIDAR. GENERATE MUST BE MANDATORY!!!!!!!!!//

  capture program drop aindex
  program define aindex, rclass
  syntax varlist(min=2 numeric) [if] [in] , [GENerate(string)]
  //syntax varlist, [GENerate(str)]
  confirm new var `generate'

//Check name por index
  if "`generate'"=="" {
      di in red "Error: dummy options requires use of generate option."
      exit
  }
local genvar = "`generate'"

//Local varlist : list uniq varlist
  foreach var of local varlist {
    quietly summ `var', meanonly
    if r(max) > r(min) {
      local vlist `vlist' `var'
	}
    else {
      dis as txt "(`var' dropped because of zero variance)"
	}
  }

  if "`vlist'" == "" {
    dis as err "all variables dropped because of zero variance"
    exit 498
  }

//Check more than one variable is specified
  local nvar : word count `vlist'
  if `nvar'<=1 {
    di ""
    di in r "At least two variables with variance different from zero should be specified"
    di ""
    error 102
    exit
  }

//Standardising variables
  local vlist ""
  foreach var of local varlist {
  tempvar std_`var'
  quietly egen `std_`var''=std(`var') 
  sum `std_`var''
  label var    `std_`var'' "`: variable label `var'' (standardize)"
  local vlist `vlist' `std_`var''
  }

//Mark sample for covariance matrix
  marksample touse

//Mata function
  local varlist `vlist'
  mata: weight("`varlist'","`touse'")

//Creates weights for each variable
  foreach n of numlist 1/`nvar' {
    tempvar weight_`n'
    gen `weight_`n'' = weights2[`n',1]
  }

//Standardized variable * weight
  local i=1
  foreach var of local varlist {
    tempvar var`i'
    gen `var`i''=`var'*`weight_`i''
    local vlist2 `vlist2' `var`i''
    local i = `i' +1
  }

// Creating the Summary Index
  local varlist `vlist2'
  egen `genvar'=rsum(`varlist'), missing

end

//mata to compute covariance matrix: You cannot use mata interactively 
//in a program because end both defines the end of the program and the 
//end of the use of mata (interactively). We need to create a mata 
//function that do the mata part and then insert in the program a call 
//to this function.

  version 1
  cap mata mata drop weight()
  mata: 
  void weight(string scalar varlist, string scalar touse)
  {
  st_view(X=., ., tokens(varlist), touse)
  Y = invsym(X'X)       /* Computing the inverse of the covariance matrix */
  b = rowsum(Y)         /* Getting the sum across rows */
  c = colsum(b)
  weights = b/c         /* Weights matrix is now */
  weights
  st_matrix("weights2", weights)
  }
  end
