#!/bin/bash

# obfuscate and move files
java -jar consyntools.jar Obfuscator silex_admin_api.js ../../silex_server/js/silex_admin_api.min.js $
java -jar consyntools.jar Obfuscator hook.js ../../silex_server/js/hook.min.js $
java -jar consyntools.jar Obfuscator silex_api.js ../../silex_server/js/silex_api.min.js $
