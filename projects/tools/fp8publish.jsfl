/*
version A string that represents the version of Flash Player targeted by the specified document. 
Acceptable values are "FlashLite", "FlashLite11", "FlashLite20" , "1", "2", "3", "4", "5", "6", "7", "8", and "9". 
These values correspond to the Version drop-down list in the Publish Settings dialog box.
*/
var flashVersion = "8";
var outputFolder = "../silex_server/tools/";

var scriptDirectory = fl.scriptURI.substring(0, fl.scriptURI.lastIndexOf("/") + 1);
var flasInFolder = FLfile.listFolder(scriptDirectory + "*.fla","files");
FLfile.createFolder(outputFolder);
for(var i = 0; i < flasInFolder.length; i++){ 
	var flaName = flasInFolder[i];
	var flaPath = scriptDirectory + flaName;
	fl.openDocument(flaPath);
	var outputPath = scriptDirectory + outputFolder + flaName.substring(0, flaName.length - 4) + ".swf";
	fl.trace("flash"+flashVersion+" - "+(i+1)+"/"+flasInFolder.length+" - "+outputPath);
	var doc = fl.getDocumentDOM();
	doc.setPlayerVersion(flashVersion);
	doc.exportSWF(outputPath, true);
	doc.close(false);
	
	
}
