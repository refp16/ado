{smcl}
{* *! version 0.1  14dec2013}{...}
{cmd:help knit}
{hline}

{title:Title}

{phang}
{bf:knit} {hline 2} A simple program to create Stata Markdown (.md) files.

{title:Syntax}

{pstd}
To create a {it:.md} file from a {it:.domd} file

{p 8 16 2}
{cmd:knit} {cmd:using} {it:{help filename}} [, {opt int:file} {opt view:file}]

{pstd}
When the {cmd:intfile} option is used, intermediate {it:.do} and {it:.log} 
files are saved. The default is to discard them permanently (bypassing the
system Recycle Bin or Trash). The {cmd:viewfile} option displays the resulting
{it:.md} file in the Viewer.

{title:Description}

{pstd}
Markdown is an easy-to-read/write formatting syntax that can be converted to
XHTML or HTML. After authoring a {it:.domd} (do-Markdown) file containing 
Markdown syntax along
with Stata code, {cmd:knit} weaves the Markdown and executed Stata code to
form a syntactically correct {it:.md} file, ready for deployment in the web.
{cmd:knit} is specially useful for those publishing short to medium sized
notes/articles in a web page or blog. 

{pstd}
A {it:.domd} file is nothing more than a file with Markdown syntax and
Stata code indented with a least four (4) spaces. The parsing of the file
depends crucially on this indentation. Indented text is to be interpreted
as Stata code and an attempt at execution is made. {cmd:knit} works in two phases.
In the first phase non-indented text is commented out producing a {it:.do} file.
Stata then executes this file producing a {help log} file. In the second phase, 
the resulting log file
is parsed to uncomment the initially commented-out text and to delete the log
header and footer. Indented text (i.e. Stata code) is left as it is with 
corresponding results. 
Depending on whether the {cmd:intfile}
option is specified or not, the results of phase 1 are saved.

{title:References and Distribution}

{pstd}
{cmd:knit} is licensed under GLP2. For more information, see: http://gking.harvard.edu/cem/

{pstd} For a reference on Markdown, see:

{phang} Daring Fireball, at
<http://daringfireball.net/projects/markdown/>


{title:Author}

{pstd}
Roberto Ferrer based on initial code by John Muschelli at 
<https://github.com/amarder/stata-tutorial/blob/master/knitr.do>.{p_end}

{pstd} 
To report bugs or give comments, please contact Roberto Ferrer
<refp16@gmail.com>.

