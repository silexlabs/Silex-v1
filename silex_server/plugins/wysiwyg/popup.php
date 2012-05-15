<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
set_include_path(get_include_path() . PATH_SEPARATOR . '../../');
set_include_path(get_include_path() . PATH_SEPARATOR . '../../cgi/library/');
require_once('rootdir.php');

require_once ROOTPATH.'cgi/includes/LangManager.php';

session_start();

/**
 * list all files in the given folder
 * @result	a list of file names, coma separated
 */
function listToolBoxPlugins($folder)
{
	$result=Array();
	$tmpFolder = opendir( $folder ) ;
	while ( $tmpFile = readdir( $tmpFolder ) ) 
	{
		if ( is_file( $folder.'/'.$tmpFile ) )
		{
			$result[]=$tmpFile;
		}
	}
	return implode(',',$result);
}
 
 $langManager = LangManager::getInstance();
 $localisedFileUrl = urldecode($_GET['localisedFileUrl']);

$localisedStrings = $langManager->getLangObject("wysiwyg", $localisedFileUrl);

 
 $localisedFlashVars = "";
foreach ($localisedStrings as $key=>$value)
{
	 $addedString = urlencode($key."=".$value."&");
	 $localisedFlashVars .= $addedString;
}


$propertyEditorsData = array('RichText' => 'plugins/wysiwyg/panels/rich_text.swf',
								'richText' => 'plugins/wysiwyg/panels/rich_text.swf',
								'rich text' => 'plugins/wysiwyg/panels/rich_text.swf',
								'Array' => 'plugins/wysiwyg/panels/array.swf',
								'array' => 'plugins/wysiwyg/panels/array.swf',
								'url' => 'plugins/wysiwyg/panels/url.swf',
								'Url' => 'plugins/wysiwyg/panels/url.swf',
								'text' => 'plugins/wysiwyg/panels/text.swf',
								'Text' => 'plugins/wysiwyg/panels/text.swf',
								'Gradient' => 'plugins/wysiwyg/panels/gradient.swf',
								'gradient' => 'plugins/wysiwyg/panels/gradient.swf',
								'UltralignEditor' => 'plugins/wysiwyg/panels/ultralignEditor.swf',
								'ultralignEditor' => 'plugins/wysiwyg/panels/ultralignEditor.swf',								
								);


$propertyEditorsFlashVar = "";
	foreach ($propertyEditorsData as $key=>$value)
{
	$addedString = urlencode($key."=".$value."&");
	 $propertyEditorsFlashVar .= $addedString;
}	

?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html style="overflow:auto; height:100%;margin:0px;padding:0px;">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Silex Properties Editor</title>

<script type="text/javascript" src="../../js/hook.min.js"></script>
<script type="text/javascript" src="../../js/compressed.min.js"></script>
<script type="text/javascript" src="swfmacmousewheel_min.js"></script>

<script type="text/javascript">
	// <![CDATA[
	
	/**
	 * the toolbox flash object  
	 */
	var toolBoxPopup;
			
	if(!opener){
		//alert("opener not defined. popup can't find parent window. closing");
		window.close();
	}
	var silexNS = opener.silexNS;

	/**
	 * called by window when closing. Clean up
	 */
	function onClose(){
		//alert("onClose");
		silexNS.SilexAdminApi.removeEventListener(toolBoxPopup);		
		opener.wysiwygNS.popupManager.onPopupClosed();
	}
	
	$(document).ready( function() 
	{
	
		var propertyPlugins = "<?php echo listToolBoxPlugins('propertyPlugins'); ?>";
		var propertyEditorPlugins = "<?php echo listToolBoxPlugins('propertyEditorPlugins'); ?>";
		var layouts = "<?php echo listToolBoxPlugins('../../layouts'); ?>";
		var langs = "<?php echo listToolBoxPlugins('lang'); ?>";
		var specificPanels = "<?php echo listToolBoxPlugins('panels'); ?>";
		
		var propertyPlugins = "<?php echo listToolBoxPlugins('propertyPlugins'); ?>";
		var fo = new SWFObject("Wysiwyg.swf", "toolBoxPopup", "100%", "100%", "10", "0","best",null,"./no-flash.html");		
		fo.addParam("bgcolor", "#5E5E5E");
		fo.addParam("AllowScriptAccess","always");
		fo.addVariable("baseUrlPropertyPlugins", "propertyPlugins/");
		fo.addVariable("baseUrlPropertyEditorPlugins", "plugins/wysiwyg/panels/");
		fo.addVariable("gabaritUrl", layouts);
		fo.addVariable("baseUrlWysiwygStyle", "<?php echo urldecode($_GET['wysiwygStyleUrl']) ?>");
		fo.addVariable("propertyPlugins",propertyPlugins);
		fo.addVariable("propertyEditorPlugins","<?php echo $propertyEditorsFlashVar ?>");
		fo.addVariable("baseUrlLanguage", "lang/");
		fo.addVariable("libraryDefaultPicturePath", "<?php echo urldecode($_GET['rootUrl'])."media/logosilex.jpg" ?>");
		fo.addVariable("rootUrl", "<?php echo urldecode($_GET['rootUrl']) ?>");
		fo.addVariable("defaultLanguage", "<?php echo $_GET['defaultLanguage'] ?>");
		fo.addVariable("availableLanguages", langs);
		fo.addVariable("embeddedObjectClassName","org.silex.ui.players.AsFramePlayerEmbeddedObject");
		fo.addVariable("embeddedObjectAS2Url","plugins/baseComponents/as2/org.silex.ui.players.AsFrame.swf");
		fo.addVariable("embeddedObjectProperty","embededObject");
		fo.addVariable("mediaPreviewPath", "<?php echo urldecode($_GET['rootUrl']) ?>");
		fo.addVariable("mediaFolderPath", "media");
		fo.addVariable("skinsFolderPath", "skins/default_as2/");
		fo.addVariable("uploadScriptPath", "cgi/scripts/upload.php");
		fo.addVariable("localisedStrings", "<?php echo $localisedFlashVars ?>");
		fo.addVariable("specificPanels",specificPanels);
		fo.addVariable("session_id", "<?php echo session_id(); ?>");
		fo.addVariable("baseUrlSpecificPanels", "<?php echo urldecode($_GET['rootUrl'])."plugins/wysiwyg/panels/" ?>");
		fo.addVariable("defaultEditorUrl", "plugins/wysiwyg/panels/SpecificPlugin.swf");
		fo.write("toolBoxPopupContent");
		
		toolBoxPopup = $('#toolBoxPopup')[0];
		//alert("opener..." + opener)
		silexNS.SilexAdminApi.addEventListener(toolBoxPopup);		
		window.onbeforeunload = onClose;
		//Mousewheel support on Mac
		if(swfmacmousewheel != null)
			swfmacmousewheel.registerObject("toolBoxPopup");
	});
	
	
	
	// ]]>
</script>

</head>
<body style="overflow:auto; padding:0px; margin-top:0; margin-left:0; margin-bottom:0; margin-right:0;height:100%;">
	<div id="toolBoxPopupContent" name="toolBoxPopupContent" align="center" style="overflow:auto; width: 100%;  height:100%;">
	</div>
</body>
</html>

