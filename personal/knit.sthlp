{smcl}
{* *! version 0.1  14dec2013}{...}
{cmd:help knit}
{hline}

{title:Title}

{phang}
{bf:knit} {hline 2} A simple program to create Stata Markdown (.md) files.


{title:Syntax}

{pstd}
To create a .md file from a .domd file

{p 8 16 2}
{cmd:knit} {cmd:using} {it:{help filename}} [, intfile]

{pstd}
When the {cmd:intfile} option is used, an intermediate {it:.md1} file
is saved. The default is to discard it.


{title:Description}

{pstd}
Markdown is an easy-to-read/write formatting syntax that can be converted to
XHTML or HTML. After authoring a {it:.domd} (do-markdown) file containing 
markdown syntax along
with Stata code, {cmd:knit} weaves the markdown and executed Stata code to
form a syntactically correct {it:.md} file, ready for deployment in the web.
{cmd:knit} is specially useful for those publishing short to medium sized
notes/articles in a web page or blog. 

{pstd}
A {it:.domd} file is nothing more than a file with markdown syntax and
Stata code indented with a least four (4) spaces. The parsing of the file
depends crucially on this indentation. Indented text is to be interpreted
as Stata code and an attempt at execution is made. {cmd:knit} works in two phases.
In the first phase indented text is executed and tagged between {it:<code> </code>} 
tags. Non-indented text is left as it is. Depending on whether the {cmd:intfile}
option is specified or not, a file is saved with this result. In the second phase, everything 
between tags is indented with four (4) spaces, giving it the final markdown format.

{title:References and Distribution}

{pstd}
{cmd:knit} is licensed under GLP2. For more information, see: http://gking.harvard.edu/cem/

{pstd} For a reference on Markdown, see:

{phang} Daring Fireball, at
<http://daringfireball.net/projects/markdown/>


{title:Author}

{pstd}
John M. with minor changes from Roberto Ferrer.{p_end}

{pstd} 
To report bugs or give comments, please contact Roberto Ferrer
<refp16@gmail.com>.

