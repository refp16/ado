*! version 0.1  14dec2013 Roberto E Ferrer Pirela, refp16@gmail.com

/* 
This is code from https://github.com/amarder/stata-tutorial that I have 
wrapped into a Stata command. Minor modifications were made:

- Check input file. It must have .domd extension
- Input files can now have ".domd" in the middle of their names
- If there is an error in Stata code, the return code is displayed.
Additionally, the ongoing log file is closed.
- File handle is now a tempvar so no need to manually close, neither if
user breaks program when running or if there is a Stata code error.
*/

program define knit
  
	syntax using/ [, intfile]

	* TODO: graphs should be exported to local dir , not the home dir
	
    *------------------- Part 1 ------------------------------------------------
	
	/* 
	This program outputs an .md1 file with executed Stata code surrounded
	with <code> </code> tags. Non-code text in the .domd file is preserved
	as it is. -log- is used and so the output file contains a header and a
	footer.
	*/

	* TODO: set off if on, but turn on when finished. if off do nothing
	*set more off 

	* Get file name and extension
	local name = substr("`using'", 1, length("`using'") - 5)
	local ext = substr("`using'", -5, .)

	* Check that input is a file ending in .domd
	if "`ext'" != ".domd" {
		display as error "file extension must be .domd"
		exit 198
	}

	* Open file
	tempname f
	file open `f' using "`using'", read

	* Name of output file
	local out = "`name'" + ".md1"

	* Start a log
	log using "`out'", name(thislog) text replace

	local in_code_block = 0
	file read `f' line
	while r(eof) == 0 {

		* If current line is indented by at least four spaces ...
		if substr("`line'", 1, 4) == "    " {
		
			* ... and previous line was not, then insert opening <code> tag
			if !`in_code_block' {
				display "<code>"
				local in_code_block = 1 // indicate we are in a code block
			}
			
			* ... and previous line was, then insert a blank line (to separate commands)
			else {
				display ""
			}
			
			* ... display the executed Stata command preappended with a .
			display ". `=ltrim("`line'")'"
			
			* ... display the result of the executed command
			capture noisily `line'
			* TODO: this executes only the line so blocks (e.g. a multiline
			* for loop won't work.
			
			* If command throws error, close log file and exit
			if _rc {
				local rc = _rc
				display "r(" "`rc'" ")"
				display as error "error in Stata code"
				display ""
				log close thislog
				exit _rc
			}

	    }

		* If current line is not indented by at least four spaces...
		else {
		
			* ... and previous line was, then insert closing </code> tag
			if `in_code_block' {
				display "</code>"
				local in_code_block = 0 // indicate we are out of a code block
			}
			
			* ... display the text in the line
			display "`line'"
			*display "`macval(line)'"
		
		}

		* Read line in file
		file read `f' line

	}

	log close thislog

	*---------------------- Part 2 ---------------------------------------------

	/* 
	This program takes a .md1 file and indents with spaces text surrounded
	with <code> </code> tags. Non-code text in the .md1 file is preserved
	as it is. Headers and footers (created by -log-) are deleted.
	*/

	tempname f_in f_out

	* Name of output file
	local out = "`name'" + ".md"

	* Open .md1 file to read
	file open `f_in' using "`out'1", read

	* Open .md file to write
	file open `f_out' using "`out'", write replace

	local in_code_block = 0
	local footer = 0

	file read `f_in' line
	local line_no = 1
	while r(eof) == 0 {
	    
		* Header and footer indicators
		local header = `line_no' <= 5
		local footer = ("`line'" == "      name:  thislog" & !`header') | `footer'

		* If line has start tag, indicate start of code block
		if "`line'" == "<code>" {
			local in_code_block = 1
		}

		* If line has end tag, indicate end of code block
		else if "`line'" == "</code>" {
		    local in_code_block = 0
		}

		* If anywhere else ...
		else {
		
			* We could be inside a code block, so indent with four spaces
			if `in_code_block' {
			    file write `f_out' "    `line'" _n // the _n is a linefeed
		    }
		
    		* We could be outside a code block...
			else {
				* but we care only for those lines that are not part of a header or footer
				if !`header' & !`footer' {
				    file write `f_out' "`line'" _n
				}
			}
	    }

		file read `f_in' line
		local ++line_no
	}
	
	* Optionally erase intermediate file .md1
	if "`intfile'" == "" {
	    erase "`out'1"
	}
  
end

