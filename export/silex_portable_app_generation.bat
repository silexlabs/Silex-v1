echo OFF

REM @author Raphael Harmel
REM @date 2012-02-12

set input_path=..\silex_server
set output_path=.\silex_server


set silex_portable_app_repo=http://silex.svn.sourceforge.net/svnroot/silex/apps/silex_portable_app/bin
set silex_portable_app_path=.\silex_portable_app

set zinc_desktop_plugin_repo=http://silex.svn.sourceforge.net/svnroot/silex/apps/third-party/plugins/ZincDesktop/bin/plugins/ZincDesktop
set zinc_desktop_plugin_path=%silex_portable_app_path%\silex_server\plugins\ZincDesktop

echo Installing silex_portable_app from svn repository
echo This might take a few minutes...
svn checkout %silex_portable_app_repo% %silex_portable_app_path% -q
echo.

echo Deleting silex_design_kit & silex_server from the silex_portable_app
svn delete %silex_portable_app_path%\silex_design_kit\
svn delete %silex_portable_app_path%\silex_server\
echo.

echo Copying %output_path% to %silex_portable_app_path%\silex_server
xcopy %output_path% to %silex_portable_app_path%\silex_server\  /Q
echo.

echo Installing ZincDesktop plugin
svn checkout %zinc_desktop_plugin_repo% zinc_desktop_plugin_path -q

