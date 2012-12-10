sudo /Applications/mtasc/mtasc ./as2/org/silex/core/Api.as ./as2/org/silex/link/HaxeLink.as ./as2/org/silex/ui/tools/RegionTool.as -swf bin/silexApiAs2Lib.swf -header 800:600:20 -cp ./as2/
haxe build.hxml
cp bin/CodeInjection.swf ../silex_server/silex.swf
