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
set pass_file=pass.php

set html_assets_path=assets\html\

set base_components_descriptors_path=\plugins\baseComponents\descriptors\
set flv_xml_path=%base_components_descriptors_path%Flv.xml
set swf_xml_path=%base_components_descriptors_path%Swf.xml
set star_xml_path=%base_components_descriptors_path%Star.xml
set polygon_xml_path=%base_components_descriptors_path%Polygone.xml
set triangle_xml_path=%base_components_descriptors_path%Triangle.xml

set silex_components_descriptors_path=\plugins\silexComponents\descriptors\
set LabelButton_descriptor_file=LabelButton.xml
set SimpleFlashButton_xml_path=%silex_components_descriptors_path%SimpleFlashButton.xml
set FuturistButton_xml_path=%silex_components_descriptors_path%FuturistButton.xml
set LegacyComponent_xml_path=%silex_components_descriptors_path%LegacyComponent.xml

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

echo Copy %input_path% to %output_path%
xcopy %input_path% %output_path%\ /S /Q
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
echo Deleting %star_xml_path% file
del %output_path%%star_xml_path% /Q
echo.
echo Deleting %polygon_xml_path% file
del %output_path%%polygon_xml_path% /Q
echo.
echo Deleting %triangle_xml_path% file
del %output_path%%triangle_xml_path% /Q
echo.
echo Deleting %output_path%%silex_components_descriptors_path%%LabelButton_descriptor_file% file
del %output_path%%silex_components_descriptors_path%%LabelButton_descriptor_file% /Q
echo.
echo Copying defaut %html_assets_path%%LabelButton_descriptor_file% file
copy /B %html_assets_path%%LabelButton_descriptor_file% %output_path%%silex_components_descriptors_path%%LabelButton_descriptor_file%
echo.
echo Deleting %SimpleFlashButton_xml_path% file
del %output_path%%SimpleFlashButton_xml_path% /Q
echo.
echo Deleting %FuturistButton_xml_path% file
del %output_path%%FuturistButton_xml_path% /Q
echo.
echo Deleting %LegacyComponent_xml_path% file
del %output_path%%LegacyComponent_xml_path% /Q
echo.

echo Deleting %output_path%\conf\%pass_file% file
del %output_path%\conf\%pass_file% /Q
echo.

echo Deleting %output_path%\conf\%plugin_server_conf_file% file
del %output_path%\conf\%plugin_server_conf_file% /Q
echo.
echo Copying defaut %html_assets_path%%plugin_server_conf_file% file
copy /B %html_assets_path%%plugin_server_conf_file% %output_path%\conf\%plugin_server_conf_file%
echo.

echo Deleting %output_path%\contents_utilities\manager\%manager_conf_file% file
del %output_path%\contents_utilities\manager\%manager_conf_file% /Q
echo.
echo Copying defaut %html_assets_path%%manager_conf_file% file
copy /B %html_assets_path%%manager_conf_file% %output_path%\contents_utilities\manager\%manager_conf_file%
echo.

pause

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
