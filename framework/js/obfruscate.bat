echo off
java -jar consyntools.jar Obfuscator jsframe.js jsframe.min.js $
java -jar consyntools.jar Obfuscator deeplink.js deeplink.min.js $
java -jar consyntools.jar Obfuscator silex.js silex.min.js $
java -jar consyntools.jar Obfuscator utils.js utils.min.js $
echo "files obfuscated"
pause
copy jquery.js + swfobject.js + *.min.js "../../silex_server/js/compressed.min.js" /y /B
echo "files merged"
pause
del *.min.js
echo "temp files deleted"
pause