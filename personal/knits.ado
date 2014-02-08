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

program define knits
  
	syntax using/ [, intfile]

	* TODO: graphs should be exported to local dir , not the home dir
	* TODO: close log and handles if stata code error
	* TODO: bibnotes are erased after the -do-ing .md1
    *------------------- Part 1 -------
	
	/* 
	This program outputs an .md1 file with executed Stata code surrounded
	with <code> </code> tags. Non-code text in the .domd file is preserved
	as it is. -log- is used and so the output file contains a header and a
	footer.
	*/

	* TODO: set off if on, but turn on when finished. if off do nothing
	*set more off 
	
	*TODO: accents are not copied correctly to .md1

	* Get file name and extension
	local name = substr("`using'", 1, length("`using'") - 5)
	local ext = substr("`using'", -5, .)

	* Check that input is a file ending in .domd
	if "`ext'" != ".domd" {
		display as error "file extension must be .domd"
		exit 198
	}
    
	* Name of output file
	local out = "`name'" + ".md1"
	
	* Open file
	tempname fin fout
	file open `fin' using "`using'", read
	file open `fout' using "`out'", write replace
	
	* TODO: First thing should be to bypass any blank lines in the beginning.
	* Then we can check if first line is code or markdown.
    
	local initflag = 0
	local inmd = 1 // assume first line is md
	file read `fin' line
	while !r(eof) {
	    * Omit blank spaces at initial part of file
	    while `initflag' == 0 & "`line'" == "" {
		    file read `fin' line // read next line
		}
	    * Modify flag when initial blanks are over
		local ++initflag
		
	    * No delimiter and first line
		if substr("`line'", 1, 6) != "```{s}" & `inmd' == 1 {
		    file write `fout' "/*" _n
			*file write `fout' `"`=ltrim("`line'")'"' _n
			file write `fout' "`line'" _n
		    local ++inmd
			file read `fin' line // read next line
		}
		* No delimiter and subsequent lines.
		* Could be in_code_block or not.
		* TODO: `i' gets erased  in the trial foor loop
		if substr("`line'", 1, 6) != "```{s}" & `inmd' != 1 {
		    display "`inmd'"
		    display "`line'"
		    display "in loop 2"
		    *file write `fout' `"`=ltrim("`line'")'"' _n
			file write `fout' "`line'" _n
			file read `fin' line // read next line
		}
		* Delimiter starts
		*display "```{s}"
		if substr("`line'", 1, 6) == "```{s}" {
		    *display "`inmd'"
		    *display "`line'"
		    *display "in loop 3"
		    file write `fout' "*/" _n
			*file write `fout' `"`=ltrim("`line'")'"' _n
			local inmd = 0
			file read `fin' line // read next line
		}
		* Delimiter ends
		if substr("`line'", 1, 6) == "```" {
		    *file write `fout' "`line'" _n
			local inmd = 1
			file read `fin' line // read next line
		}
		
	}

    * Start a log
	log using "`name'.log", name(thislog) text replace
	*sjlog using tut2, replace
    do "`out'"
	*sjlog close
	log close thislog
	
	
	
	
		*---------------------- Part 2 ---------------------------------------------

	/* 
	This program takes a .log file and indents with spaces text surrounded
	with <code> </code> tags. Non-code text in the .md1 file is preserved
	as it is. Headers and footers (created by -log-) are deleted.
	*/

	tempname f_in f_out

	* Name of output file
	local out = "`name'" + ".md"

	* Open log file to read
	file open `f_in' using "`name'.log", read

	* Open .md file to write
	file open `f_out' using "`out'", write replace

	local in_code_block = 0
	local footer = 0
    
	file read `f_in' line
	local line_no = 1
	while !r(eof) {
	    display "`line'"
		* Header and footer indicators
		local header = `line_no' <= 5
		local footer = ("`line'" == "end of do-file" & !`header') | `footer'
        
		if substr("`line'", 1, 2) == "> " {
		    local nline = regexr("`line'", "> ", "")
		    file write `f_out' "`nline'" _n // the _n is a linefeed
		}
		
		else {
		
			* but we care only for those lines that are not part of a header or footer
			if !`header' & !`footer' {
		        file write `f_out' "    `line'" _n // the _n is a linefeed
			}	
		}
		
		file read `f_in' line
		local ++line_no
	}
end	
		
		
		/*
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
	
	
end

/*	
	
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

