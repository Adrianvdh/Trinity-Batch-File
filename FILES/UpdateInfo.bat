:TRINITY_UPDATEINFO_FILE
::Latest version (compared to users current local version):
set "currentversion=1.1.0"
::Latest version release date:
set "updatedate=2014/01/07"
::Latest version update fixes:
set "updatefixes=* Added this ...........""* Fixed this .............""* Removed this ............."
::Quick message for users:
set "updatemsg=No download is available, debuggging purposes only."
::Update file protocol:
set "downloadtype=http"
::URL update file:
REM FTP 
set "updatefileURL=ftp.trinity.bugs3.com"
REM HTTP set "updatefileURL=http://trinity.bugs3.com/anonymous/Trinity/Trinity.bat"
REM LINK set "updatefileURL=ftp://u956828123.anonymous:anonymous@trinity.bugs3.com/Trinity/Trinity.bat"
::FTP only
set "cdFTPdir=Trinity"
set "updatefilename=Trinity.bat"
set "FTPUser=u956828123.anonymous"
set "FTPPass=anonymous"
set "FTPtransfertype=binary"
::Misc for drawing (true) update form:
set "updatemodesize=52,21"
set "borderhyphencount=51"
set "titlespacecount=17"
::Update fixes for storing as array variable:
set LF=^



exit /b