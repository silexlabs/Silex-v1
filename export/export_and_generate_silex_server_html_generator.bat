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
set plugin_server_conf_file=plugins_server.php
set manager_conf_file=conf.txt

set flv_xml_path=\plugins\baseComponents\descriptors\Flv.xml
set swf_xml_path=\plugins\baseComponents\descriptors\Swf.xml
set FuturistButton_xml_path=\plugins\silexComponents\descriptors\FuturistButton.xml
set LegacyComponent_xml_path=\plugins\silexComponents\descriptors\LegacyComponent.xml

set input_path=..\silex_server
set output_path=.\silex_server_html

echo Initialisation complete
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

echo Deleting all non-HTML5 compatible components
echo.
echo Deleting %output_path%%flv_xml_path% file
del %output_path%%flv_xml_path% /Q
echo.
echo Deleting %swf_xml_path% file
del %output_path%%swf_xml_path% /Q
echo.
echo Deleting %FuturistButton_xml_path% file
del %output_path%%FuturistButton_xml_path% /Q
echo.
echo Deleting %LegacyComponent_xml_path% file
del %output_path%%LegacyComponent_xml_path% /Q
echo.

echo Deleting %output_path%\conf\%plugin_server_conf_file% file
del %output_path%\conf\%plugin_server_conf_file% /Q
echo.
echo Copying defaut assets\html\%plugin_server_conf_file% file
copy /B assets\html\%plugin_server_conf_file% %output_path%\conf\%plugin_server_conf_file%
echo.

echo Deleting %output_path%\contents_utilities\manager\%manager_conf_file% file
del %output_path%\contents_utilities\manager\%manager_conf_file% /Q
echo.
echo Copying defaut assets\html\%manager_conf_file% file
copy /B assets\html\%manager_conf_file% %output_path%\contents_utilities\manager\%manager_conf_file%
echo.

echo Deleting %output_path%.zip ...
del %output_path%.zip /Q
echo.

echo Compressing %output_path%.zip ...
C:\"Program Files"\7-Zip\7z.exe a -tzip %output_path%.zip %output_path%
echo.

pause

echo Deleting %output_path% directory...
rmdir %output_path%\ /S /Q
echo.

echo OPERATION COMPLETE
echo.

pause
