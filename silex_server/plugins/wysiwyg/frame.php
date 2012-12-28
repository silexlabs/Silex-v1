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

 $wysiwygStyleUrl = $_GET['wysiwygStyleUrl'];

 $langManager = LangManager::getInstance();
 $localisedFileUrl = urldecode($_GET['localisedFileUrl']);

 $localisedStrings = $langManager->getLangObject("wysiwyg", $localisedFileUrl);

 
 
 $localisedFlashVars = "";
foreach ($localisedStrings as $key=>$value)
{
	$addedString = urlencode($key."=".$value."&");
	 $localisedFlashVars .= $addedString;
}
 
 
if (substr($wysiwygStyleUrl, 0, 4) == 'http')
{
	$wysiwygStyleUrlDiv = $wysiwygStyleUrl;
}

else
{
	$wysiwygStyleUrlDiv = 'plugins/wysiwyg/'.$wysiwygStyleUrl;
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

								
?>
<script type="text/javascript">
	// <![CDATA[
	//////////////////////////////////////////////////////
	// root from silex index.php page
	var $rootUrl;

	/**
	 * name space for wysiwyg
	 */
	var wysiwygNS;
	if(!wysiwygNS){
		wysiwygNS = new Object();
	}
	wysiwygNS.relativeBaseUrl = "plugins/wysiwyg/";
	wysiwygNS.fullBaseUrl = $rootUrl + wysiwygNS.relativeBaseUrl;
	wysiwygNS.wysiwygModel;
	

	function initToolBox()
	{
		//alert("initToolBox");
		var propertyPlugins = "<?php echo listToolBoxPlugins('propertyPlugins'); ?>";
		var propertyEditorPlugins = "<?php echo listToolBoxPlugins('propertyEditorPlugins'); ?>";
		var layouts = "<?php echo listToolBoxPlugins('../../layouts'); ?>";
		var langs = "<?php echo listToolBoxPlugins('lang'); ?>";
		var specificPanels = "<?php echo listToolBoxPlugins('panels'); ?>";
		
		var fo = new SWFObject(wysiwygNS.fullBaseUrl + "Wysiwyg.swf", "toolBox", "100%", "100%", "10", "0","best",null,"./no-flash.html");
		fo.addParam("AllowScriptAccess","always");
		fo.addParam("bgcolor", "#5E5E5E");
		fo.addVariable("baseUrlPropertyPlugins","plugins/wysiwyg/propertyPlugins/");
		fo.addVariable("gabaritUrl", layouts);
		fo.addVariable("libraryDefaultPicturePath", $rootUrl+"media/logosilex.jpg");
		fo.addVariable("baseUrlWysiwygStyle", "<?php echo $wysiwygStyleUrlDiv ?>");
		fo.addVariable("rootUrl", $rootUrl);
		fo.addVariable("baseUrlPropertyEditorPlugins", "plugins/wysiwyg/panels/");
		fo.addVariable("baseUrlLanguage", wysiwygNS.fullBaseUrl + "lang/");
		fo.addVariable("availableLanguages", langs);
		fo.addVariable("defaultLanguage", "<?php echo $_GET['defaultLanguage'] ?>");
		fo.addVariable("propertyPlugins",propertyPlugins);
		fo.addVariable("embeddedObjectClassName","org.silex.ui.players.AsFramePlayerEmbeddedObject");
		fo.addVariable("embeddedObjectAS2Url","plugins/baseComponents/as2/org.silex.ui.players.AsFrame.swf");
		fo.addVariable("embeddedObjectProperty","embededObject");
		fo.addVariable("mediaPreviewPath", $rootUrl);
		fo.addVariable("mediaFolderPath", "media");
		fo.addVariable("skinsFolderPath", "skins/default_as2/");
		fo.addVariable("uploadScriptPath", "cgi/scripts/upload.php");
		fo.addVariable("propertyEditorPlugins", "<?php echo $propertyEditorsFlashVar ?>");
		fo.addVariable("localisedStrings", "<?php echo $localisedFlashVars ?>");
		fo.addVariable("specificPanels",specificPanels);
		fo.addVariable("session_id", "<?php echo session_id(); ?>");
		fo.addVariable("baseUrlSpecificPanels", $rootUrl+"<?php echo "plugins/wysiwyg/panels/" ?>");
		fo.addVariable("defaultEditorUrl", "plugins/wysiwyg/panels/SpecificPlugin.swf");
		
		fo.write("toolBoxContent");
		var toolBox = $('#toolBox')[0];
		silexNS.SilexAdminApi.addEventListener(toolBox);
		
		
	}	

	function onBodyResize(){
		wysiwygNS.wysiwygModel.refresh();
	}

	function showWysiwyg(){
		wysiwygNS.wysiwygModel.setWysiwygVisibility(true);		
	}	
	
	function hideWysiwyg(){
		wysiwygNS.wysiwygModel.setWysiwygVisibility(false);	
		wysiwygNS.wysiwygModel.logout();	
	}


	function initWysiwygFrame(){
		wysiwygNS.popupManager = new wysiwygNS.PopupManagerClass($(window).width(), 290, wysiwygNS.fullBaseUrl + 
		"popup.php?wysiwygStyleUrl=<?php echo $_GET['wysiwygStyleUrl'];  ?>&defaultLanguage=<?php echo $_GET['defaultLanguage'] ?>&localisedFileUrl=<?php echo urlencode($localisedFileUrl);?>&rootUrl="+encodeURIComponent($rootUrl));			
		wysiwygNS.wysiwygModel = new wysiwygNS.WysiwygModelClass();
		silexNS.SilexAdminApi.pluggedClasses["wysiwygModel"] = wysiwygNS.wysiwygModel;

		//initToolBox();
		wysiwygNS.wysiwygModel.refresh();
		silexNS.HookManager.addHook("bodyResize",onBodyResize);
		silexNS.HookManager.addHook("loginSuccess", showWysiwyg);
		silexNS.HookManager.addHook("logout",hideWysiwyg);
		//Register component for mac mouse wheel
		if(swfmacmousewheel)
			swfmacmousewheel.registerObject("toolBox");
		
	
	}
	
	
	wysiwygNS.initToolBox = initToolBox;
	wysiwygNS.alreadyLoaded = false;
	
	silexNS.SilexApi.addScript(wysiwygNS.fullBaseUrl + "popup_manager.js");
	silexNS.SilexApi.addScript(wysiwygNS.fullBaseUrl + "wysiwyg_model.js");
	silexNS.SilexApi.addScript(wysiwygNS.fullBaseUrl + "swfmacmousewheel_min.js");
	silexNS.SilexApi.includeJSSCripts(initWysiwygFrame);	
	
	
	
	// ]]>	
</script>
<div id="toolBoxContent" name="toolBoxContent" align="center" style="overflow:auto; width: 100%; height: 1px; position: absolute; z-index: 1000; "/>

