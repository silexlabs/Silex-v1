REM echo OFF
for /R %1 %%G in (*.html *.php *.txt *.xml) DO (
 utilities\dos-unix\DOS2UNIX %%G
 REM echo %%G
)
