echo OFF

REM @author Raphael Harmel
REM @date 2012-02-12

cls

echo ----------------------------------
echo.
echo - STEP 0: INITIALISING VARIABLES -
echo.
echo ----------------------------------
echo.

set version_tag_value=v1.7.0RC1
set svn_commit_message=New Silex Version
REM set manager_url=http://localhost/Raph/Silex_V1/silex_trunk/export/silex_server/?/manager
set manager_url=http://localhost/Silex_V1/silex_trunk_virgin/export/silex_server/?/manager

set default_publication=silex-business-card

set input_path=..\silex_server
set output_path=.\silex_server
set version_file_path=version.txt
set version_signature_file_path=version.xml

echo.
echo STARTING SILEX %version_tag_value% GENERATION PROCESS
echo.

echo -------------------------------------
echo.
echo - STEP 1: TRUNK EXPORT AND CLEANING -
echo.
echo -------------------------------------
echo.

echo Deleting temporary directory (if exists): %output_path% 
rd %output_path%\ /S /Q
echo.

echo Converting files from windows to unix format in %input_path%:
echo (line ends are changed from LF/CR to LF)...
call utilities\dos2unix_recursive.bat %input_path%>NUL
echo.

echo Exporting svn trunk from %input_path% to %output_path%
svn export %input_path% %output_path% -q
echo.

echo Cleaning %output_path%...
rd %output_path%\contents\ /S /Q
mkdir %output_path%\contents\
copy %input_path%\contents\index.php %output_path%\contents\index.php
xcopy %input_path%\contents\%default_publication% %output_path%\contents\%default_publication%\ /Q
rd %output_path%\media\test /S /Q
echo.

echo ------------------------------------
echo.
echo - STEP 2: SILEX VERSION GENERATION -
echo.
echo ------------------------------------
echo.

set version_generator_repo=https://silex.svn.sourceforge.net/svnroot/silex/apps/third-party/plugins/version_generator
set version_generator_path=%output_path%\plugins\version_generator

echo Updating %version_file_path% content to "version=%version_tag_value%"
echo version=%version_tag_value%> %output_path%\%version_file_path%
echo Converting file from windows to unix format
call utilities\dos-unix\DOS2UNIX %output_path%\%version_file_path%>NUL
echo.

echo Installing version generator plugin from svn repository
svn checkout %version_generator_repo% %version_generator_path% -q
echo.

echo Updating "version_tag_value" to %version_tag_value% in version_generator plugin's index
call utilities\BatchSubstitute.bat "version_tag_value" %version_tag_value% %version_generator_path%\index.php>%version_generator_path%\indextemp.php
del %version_generator_path%\index.php /Q
move %version_generator_path%\indextemp.php %version_generator_path%\index.php
echo Converting file from windows to unix format
call utilities\dos-unix\DOS2UNIX %version_generator_path%\index.php>NUL
echo.

echo Converting defaut assets\pass.php from windows to unix format
call utilities\dos2unix_recursive.bat assets\pass.php>NUL
echo Copying defaut assets\pass.php file with login/password as a/a
copy /B assets\pass.php %output_path%\conf\pass.php
echo.

echo Starting manager to generate silex new version
start %manager_url%
echo.

echo Please go to silex manager, login with a/a
echo and generate new silex version with the version generator plugin
echo.
echo Then press any key to continue

pause

echo.
echo Deleting %output_path%\conf\pass.php file
del %output_path%\conf\pass.php /Q
echo.

echo Deleting version generator plugin
rd %version_generator_path% /S /Q
echo.

REM echo Converting files from windows to unix format in %output_path%:
REM echo (line ends are changed from LF/CR to LF)...
REM call utilities\dos2unix_recursive.bat %output_path%>NUL
REM echo.

echo Copying %output_path%\%version_file_path% to %input_path%\%version_file_path% 
copy /B %output_path%\%version_file_path% %input_path%\%version_file_path% 
echo.

echo Copying %output_path%\%version_signature_file_path% to %input_path%\%version_signature_file_path% 
copy /B %output_path%\%version_signature_file_path% %input_path%\%version_signature_file_path% 
echo.

echo Please verify the modified file list before commiting via svn.
echo This list should include: 
echo   -new %version_file_path%
echo   -new %version_signature_file_path%
echo   -files converted to unix format
echo.
svn status %input_path%
echo.

choice /m "Do you confirm the svn commit"
IF errorlevel 2 goto CLEAN

echo.
echo Commiting %input_path%
REM svn commit -m "%svn_commit_message%" %output_path%
echo.


pause

:CLEAN

echo.
echo Deleting %output_path% directory...
rmdir %output_path%\ /S /Q
echo.

echo OPERATION COMPLETE
echo.

pause
