ECHO OFF
ECHO.
SET input_path=..\silex_server
SET output_path=.\silex_server
set default_publication=silex-business-card

ECHO Deleting existing .\%output_path% directory...
rmdir %output_path% /S /Q
ECHO.

ECHO Exporting %input_path% to %output_path%...
svn export %input_path% %output_path%
ECHO.

ECHO Cleaning .\%output_path%...
rmdir %output_path%\contents\ /S /Q
mkdir %output_path%\contents\
copy %input_path%\contents\index.php %output_path%\contents\index.php
xcopy %input_path%\contents\%default_publication% %output_path%\contents\%default_publication%\ /Q
rmdir %output_path%\media\test /S /Q
ECHO.

echo Deleting %output_path%\conf\%plugin_server_conf_file% file
del %output_path%\conf\%plugin_server_conf_file% /Q
echo.

echo Deleting %output_path%.zip ...
del %output_path%.zip /Q
echo.

pause

ECHO Compressing %output_path%.zip ...
C:\"Program Files"\7-Zip\7z.exe a -tzip %output_path%.zip %output_path%
ECHO.

ECHO Deleting .\%output_path% directory...
rmdir %output_path% /S /Q
ECHO.

ECHO Operation complete
ECHO.

PAUSE
