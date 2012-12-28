ECHO OFF
ECHO.
SET input_path=silex_dev_kit
SET output_path=silex_dev_kit

ECHO Deleting existing .\%output_path% directory...
rmdir %output_path% /S /Q
ECHO.

ECHO Exporting ..\%input_path% to .\%output_path%...
svn export ..\%input_path% %output_path%
ECHO.

echo Deleting %output_path%.zip ...
del %output_path%.zip /Q
echo.

ECHO Compressing %output_path%.zip ...
C:\"Program Files"\7-Zip\7z.exe a -tzip %output_path%.zip %output_path%
ECHO.

ECHO Deleting .\%output_path% directory...
rmdir %output_path% /S /Q
ECHO.

ECHO Operation complete
ECHO.

PAUSE
