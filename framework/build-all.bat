c:\mtasc\mtasc ./as2/org/silex/core/Api.as ./as2/org/silex/link/HaxeLink.as -swf bin/silexApiAs2Lib.swf ./as2/org/silex/ui/tools/RegionTool.as -header 800:600:20 -cp ./as2/
haxe build.hxml
copy "bin\CodeInjection.swf" "..\silex_server\silex.swf"
c:\mtasc\mtasc.exe -swf ../silex_server/silex_admin_api.swf -cp ./as2 -cp . as2/org/silex/adminApi/SilexAdminApiMc.as -version 8
pause