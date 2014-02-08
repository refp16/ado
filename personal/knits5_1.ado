*! version 0.1  15dec2013 Roberto E Ferrer Pirela, refp16@gmail.com

/* 
This code takes from https://github.com/amarder/stata-tutorial. 
Modifications include:

- Check input file. It must have .domd extension
- Input files can now have ".domd" in the middle of their names
- If there is an error in Stata code, the return code is displayed.
Additionally, the ongoing log file is closed.
- File handle is now a tempvar so no need to manually close, neither if
user breaks program when running or if there is a Stata code error.
- Allows multiline code (e.g. for loops)
*/

program define knits5_1
  
	syntax using/ [, INTfile VIEWfile]

	/* 
	This program outputs a .do file with with all markdown syntax commented
	so it can be run by Stata. -do- and -log- is used and so the output 
        file contains a header and a footer.
	*/
	
	* TODO: graphs should be exported to local dir , not the home dir
	* TODO: bibliographic notes are erased after the -do-ing the .do file.
	* This only occurs here. When -do-ing dofile from outside this program
	* nothing is left out. Verify in Stata 13 and send error to Stata if
	* it persists.
	* TODO: set more off if on, but turn on when finished. if off do 
        * nothing set more off 
	
	* TODO: `i' gets erased  in the trial foor loop
	* TODO: when chunck has spaced code:
	*```{s}
	*    describe
	*```
	*the final result in the .md file is: 
	*.    describe
	*when it should be:
	*. describe.
	* Maybe using -trim-, but this gave problems when `' (e.g. for macros)
	* were involved. Check again and solve.

	* Get file name and extension
	local name = substr("`using'", 1, length("`using'") - 5)
	local ext = substr("`using'", -5, .)

	* Check that input is a file ending in .domd
	if "`ext'" != ".domd" {
		display as error "file extension must be .domd"
		exit 198
	}
	
	* Open file
	tempname fin fout
	file open `fin' using "`using'", read
	file open `fout' using "`name'.do", write replace
	
	* TODO: First thing should be to bypass any blank lines in the beginning.
	* Then we can check if first line is code or markdown.
    
	local iscode = 0 // assume first line is md
	file read `fin' line
	while !r(eof) {
	
	    * Omit blank spaces at initial part of file
	    *while "`line'" == "" {
		 *   file read `fin' line // read next line
		*}
		
		* Get initial characters
		local init = substr("`line'", 1, 6)
		
		/*
		The asserts verify that we go from ```{s} to ``` and viceversa.
		Two in a row of either would be an error. 
		TODO: Verify that every delimiter start has a delimiter end.
		*/
		
	        * Delimiter starts
		if "`init'" == "```{s}" {
		    *Check
		    capture assert `iscode' == 0
			if _rc {
			    display as error "two in a row of ```{s}. check .domd file"
				exit _rc
			}
			* Mark a delimiter start
		    local iscode = 1
		}
		
		* Delimiter ends
		if "`init'" == "```" {
		    * Check
		    capture assert `iscode' == 1
			if _rc {
			    display as error "two in a row of ```. check .domd file"
				exit _rc
			}
			* Mark as delimiter end
		    local iscode = 0
		}
		
		* No delimiter and is not code
		if !inlist("`init'", "```{s}", "```") & !`iscode' {
		    *file write `fout' "* `line'" _n
			file write `fout' "* " "`macval(line)'" _n //TODO: fix the space issue after the *. No space produces a better log file with more bibliography. Why?
			*file write `fout' `"* `macval(line)'"' _n
		}
		
		* No delimiter and is code
        if !inlist("`init'", "```{s}", "```") & `iscode' {
		    file write `fout' `"`macval(line)'"' _n
		    *file write `fout' `"`line'"' _n * TODO: write on why this line doesn't work
		}
		
		* Read next line
		file read `fin' line
	}

    * Start a log
	log using "`name'.log", name(thislog) text replace
	
	* Do the do-file
    capture noisily do "`name'.do"
	
	* If some command throws error, close log file and exit
	if _rc {
		display as error "error in Stata code"
		display ""
		log close thislog
		exit _rc
	}
	
	log close thislog
	
	*---------------------- Part 2 ---------------------------------------------

	/* 
	This program takes a .log file and indents with four spaces the Stata code. 
	Commented markdown (with *) is uncommented. 
	Headers and footers (created by -log-) are deleted.
	*/

	tempname f_in f_out
    
	* Count lines in log file
	file open `f_in' using "`name'.log", read
	
	local totlines = 0
	file read `f_in' line
	
	while !r(eof) {
	    local ++totlines
		file read `f_in' line
    }
	
    file close `f_in'
	
	* Main process
	file open `f_out' using "`name'.md", write replace
	file open `f_in' using "`name'.log", read
	
	local line_no = 0    
	
	file read `f_in' line
	while !r(eof) {
	
		*display "`line'"
		display `"`line'"'
		*display "`macval(line)'"
		display `"`macval(line)'"'
			
		* Update line number
		local ++line_no
		
		* If not header or footer. Header and footer add 6 lines each.
		if inrange(`line_no', 7, `totlines' - 6) {
			
			* Not Stata code
			if substr(`"`macval(line)'"', 1, 4) == ". * " {
				local nline = subinstr(`"`macval(line)'"', ". * ", "", 1)
				file write `f_out' "`nline'" _n // the _n is a linefeed
				*file write `f_out' `"`macval(nline)'"' _n // the _n is a linefeed
			}
			
			* Stata code
			else {
				*file write `f_out' "    `line'" _n // the _n is a linefeed
				file write `f_out' `"    `macval(line)'"' _n // the _n is a linefeed
			}
			
		}
		
		* Read next line
		file read `f_in' line
		
	}
	
	* Optionally erase intermediate .do and .log file
	if "`intfile'" == "" {
	    erase "`name'.do"
		erase "`name'.log"
	}
	
	* Optionally -view- the resulting .md file
	if "`viewfile'" != "" {
		view  "`name'.md"
	}
	
end	

