/*
version A string that represents the version of Flash Player targeted by the specified document. 
Acceptable values are "FlashLite", "FlashLite11", "FlashLite20" , "1", "2", "3", "4", "5", "6", "7", "8", and "9". 
These values correspond to the Version drop-down list in the Publish Settings dialog box.
*/

var outputFolder = "../../../silex_server/media/components/buttons/";

var copySwfToDirectories = new Array();
//copySwfToDirectories.push("file:///D|/ariel/projets/projets info/svn_projets/otstc/website/media/components/oof/");

var compsThatNeedFlash8 = new Array();
compsThatNeedFlash8.push("scale9_button1.cmp.fla");
	
var scriptDirectory = fl.scriptURI.substring(0, fl.scriptURI.lastIndexOf("/") + 1);
var flasInFolder = FLfile.listFolder(scriptDirectory + "*.cmp.fla","files");
FLfile.createFolder(outputFolder);
for(var i = 0; i < flasInFolder.length; i++){ 
	var flaName = flasInFolder[i];
	var flashVersion = "7";
	for(var j = 0; j < compsThatNeedFlash8.length; j++){
		//fl.trace(compsThatNeedFlash8[j] + "," + flaName);
		if(flaName == compsThatNeedFlash8[j]){
			flashVersion = "8";
		}
	}	
	var swfName =  flaName.substring(0, flaName.length - 4) + ".swf";
	var flaPath = scriptDirectory + flaName;
	fl.openDocument(flaPath);
	var outputPath = scriptDirectory + outputFolder + swfName;
	fl.trace("flash"+flashVersion+" - "+( i + 1 ) +"/"+flasInFolder.length+" - "+outputPath);
	var doc = fl.getDocumentDOM();
	doc.setPlayerVersion(flashVersion);
	doc.exportSWF(outputPath, true);
	doc.close(false);
	
	for(var j = 0; j < copySwfToDirectories.length; j++){
		var copyPath = copySwfToDirectories[j] + swfName;
		FLfile.remove(copyPath);
		FLfile.copy(outputPath, copyPath);
	}	
}
for(var j = 0; j < copySwfToDirectories.length; j++){
	fl.trace("swf copies at " + copySwfToDirectories[j]);
}	

