var scriptDirectory = fl.scriptURI.substring(0, fl.scriptURI.lastIndexOf("/") + 1);
var flasInFolder = FLfile.listFolder(scriptDirectory + "*.cmp.fla","files");
for(var i = 0; i < flasInFolder.length; i++){ 
	var flaName = flasInFolder[i];
	var flaPath = scriptDirectory + flaName;
	var doc = fl.openDocument(flaPath);
	fl.trace(flaPath+" ("+(i+1)+"/"+flasInFolder.length+") - Successfully saved: "+fl.saveDocumentAs(flaPath));
	fl.closeDocument(doc);
}
