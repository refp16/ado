



/* 
-webuse query- can be used to get the stub if stata version in use.
But maybe someone wants datasets of a particular version, which
could be newer or older. In this case, manuals could be inexistant
so, there would have to be some check. We need to cover the case in
which all files from different versions are downloaded.

Stata 7 databases are not classified by manuals. It has database URL:

    http://www.stata-press.com/data/r7/allfiles.tar

Stata < 7, have no databases online (at least not with the newer URL
format).

*-------------------

The simplest use :

    webdown 

downloads all databases of using version to current directory and unzips them.

If given a directory, it will save all files (of using version) there:

    webdown ~/mydata

If given a version, it will download all datafiles of that specific version:

    webdown ~/mydata, ver(8)
	
to where?? dir r8?? If yes, then why not save by default all versions, including
the using version in its own dir ?? e.g. ../r12/

Response: I think by default, the using version database is the one that should
have full feateres (unpacking, adding to adopath, direct system call, etc). Databases 
from
other verions of Stata should only be allowed to be downloaded to a specific
in a r8 (e.g.) folder.
*/

local targetdir "/home/roberto/ado/personal/webdta"

local webstub "http://www.stata-press.com/data"
local stataver "r8"
local compresstype ".tar"

local targetdir "/home/roberto/ado/personal/webdta_`stataver'"

#delimit ;

local manuals8
R
CL
XT
G
P
SVY
ST
TS
U
;

local manuals9
R
D
XT
G
MV
P
SVY
ST
TS
U
;

local manuals13
R
D
G
XT
ME
MI
MV
PSS
P
SEM
SVY
ST
TS
TE
U
;

#delimit cr

foreach manual of local manuals8 {
    tempfile temp
	display "downloading all`manual'files`compresstype' ..."
	display `""`webstub'/`stataver'/all`manual'files`compresstype'""'
	*copy http://www.stata-press.com/data/r13/allRfiles.tar
	copy "`webstub'/`stataver'/all`manual'files`compresstype'" "~/", replace // this works
    *copy "`webstub'/`stataver'/all`manual'files`compresstype'", replace
	*unzipfile "all`manual'files`compresstype'"
	*unzipfile "all`manual'files`compresstype'", replace
}

/*
local allsites
http://www.stata-press.com/data/r13/allRfiles.tar
http://www.stata-press.com/data/r13/allDfiles.tar
http://www.stata-press.com/data/r13/allSVYfiles.tar



copy  `site' `targetdir'

*/
