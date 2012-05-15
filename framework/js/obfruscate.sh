#!/bin/bash
# obfuscate files
java -jar consyntools.jar Obfuscator jsframe.js jsframe.min.js $
java -jar consyntools.jar Obfuscator deeplink.js deeplink.min.js $
java -jar consyntools.jar Obfuscator silex.js silex.min.js $
java -jar consyntools.jar Obfuscator utils.js utils.min.js $
# merge and copy files
cat jquery.js swfobject.js *.min.js > ../../silex_server/js/compressed.min.js
# delete temp files
rm *.min.js
