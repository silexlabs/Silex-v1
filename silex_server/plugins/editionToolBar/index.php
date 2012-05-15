<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
// include './rootdir.php'; we do not call rootdir.php for the moment as it's already within the filepath. Also this includes seems to break the administration part of the plugin. If we notice some cases where ROOTPATH isn't known when we call index.php, we will have to rethink this part.
require_once ROOTPATH.'cgi/includes/plugin_base.php';
require_once ROOTPATH.'cgi/includes/logger.php';
require_once ROOTPATH.'cgi/includes/silex_config.php';
require_once ROOTPATH.'cgi/includes/LangManager.php';

class editionToolBar extends plugin_base
{

	
	function initDefaultParamTable()
	{
		//$this->paramTable = array();
	}
	
	public function initHooks($hookManager)
	{
		$hookManager->addHook('admin-body-end', array($this, 'editionToolBarAdminBodyEnd'));
	}
	
	
	/**
	 * Silex hook callback to load the editionToolBar
	 */
	public function editionToolBarAdminBodyEnd()
	{
		// Part to load the translations in the corresponding files
		/*$langManager = LangManager::getInstance();
		$localisedFileUrl = $langManager->getLangFile($this->pluginName, "en");
		$localisedStrings = $langManager->getLangObject($this->pluginName, $localisedFileUrl);*/
			
		?>
		<script type="text/javascript">
			// <![CDATA[
			
			/**
			 * the toolbox flash object  
			 */
			var editionToolBar;
			
			/**
			 * The Container div
			 */
			var CONTAINER_DIV = "#leftToolsContainerDiv";
			/**
			 * The plugin div
			 */
			var PLUGIN_DIV = "#editionToolBarDiv";
			//var PLUGIN_CONTENT_DIV = "editionToolBarDiv";
			var isVisibleEditionToolBarDiv=true;
			
			/**
			 * This function loads the edition toolbar div and flash object
			 */
			function loadEditionToolBar(event)
			{	
				if (!$('#editionToolBarDiv').length)
				{
					$frame = $('<div id="editionToolBarDiv" name="editionToolBarDiv" align="center" style="width: 35px; position: absolute; z-index: 20;  top: 0px; left: 0px" ></div>');
					//$('"#toolsContainerDiv"').append($frame);
					//$('#editionToolBarDiv0').append($frame);
					$(CONTAINER_DIV).append($frame);
					
					var fo = new SWFObject($rootUrl+"plugins/editionToolBar/EditionToolBar.swf", "editionToolBar", "100%", "100%", "8", "0","best",null,$rootUrl + "no-flash.html");
					fo.addVariable("baseUrlWysiwygStyle", $rootUrl+"plugins/wysiwyg/design/WysiwygStyle.swf");
					fo.addParam("bgcolor", "#D6D6D6");
					fo.addParam("wmode","opaque");
					fo.addParam("AllowScriptAccess","always");
					fo.write("editionToolBarDiv");
					var editionToolBar = $('#editionToolBar')[0];
					silexNS.SilexAdminApi.addEventListener(editionToolBar);
				}
				redrawEditionToolBarDiv();
			}
			
			/**
			 * This function initialises the needed hooks and flash icons
			 */
			function initEditionToolBarTool()
			{
				silexNS.HookManager.addHook("openSilexPage",openSilexPageEditionToolBar);
				silexNS.HookManager.addHook("bodyResize",onBodyResizeEditionToolBar);
				silexNS.HookManager.addHook("refreshWorkspace",onBodyResizeEditionToolBar);
				silexNS.HookManager.addHook("loginSuccess", showWysiwygEditionToolBar);
				silexNS.HookManager.addHook("logout",hideWysiwygEditionToolBar);
		
				silexNS.SilexAdminApi.callApiFunction("editionToolBars", "addItem", [{
				name:"EditionToolBarTool",
				uid:"silex.EditionToolBar.Tool",
				label:"the EditionToolBar label",
				description:" the EditionToolBar description"}]);
			
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"History", 
				uid:"silex.EditionToolBar.ToolItemGroup.History", 
				level:1, 
				toolUid:"silex.EditionToolBar.Tool", 
				label:"", 
				description:""}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"Main",
				uid:"silex.EditionToolBar.ToolItemGroup.Main", 
				level:2,
				toolUid:"silex.EditionToolBar.Tool",
				label:"",
				description:""}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"Utils",
				uid:"silex.EditionToolBar.ToolItemGroup.Utils", 
				level:3,
				toolUid:"silex.EditionToolBar.Tool",
				label:"",
				description:""}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Navigation",
				hasBackground:true,
				uid:"silex.EditionToolBar.ToolItem.Navigation",
				groupUid:"silex.EditionToolBar.ToolItemGroup.Main",
				level:0, 
				toolUid:"silex.EditionToolBar.Tool",
				label:"Navigation mode",
				description:"N",
				url:$rootUrl+"plugins/editionToolBar/navigation_button.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Selection",
				hasBackground:true,
				uid:"silex.EditionToolBar.ToolItem.Selection",
				groupUid:"silex.EditionToolBar.ToolItemGroup.Main",
				level:1, 
				toolUid:"silex.EditionToolBar.Tool",
				label:"Edit mode",
				description:"E",
				url:$rootUrl+"plugins/editionToolBar/selection_button.swf"}]);

				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Save",
				hasBackground:true,
				uid:"silex.EditionToolBar.ToolItem.Save",
				groupUid:"silex.EditionToolBar.ToolItemGroup.History",
				level:0, 
				toolUid:"silex.EditionToolBar.Tool",
				url:$rootUrl+"plugins/viewMenu/save_button.swf",
				label:"Save (all) layers",
				description:"Ctr S"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Undo",
				hasBackground:true,
				uid:"silex.EditionToolBar.ToolItem.Undo",
				groupUid:"silex.EditionToolBar.ToolItemGroup.History",
				level:1, 
				toolUid:"silex.EditionToolBar.Tool",
				url:$rootUrl+"plugins/viewMenu/undo_button.swf",
				label:"Undo",
				description:"Ctr Z"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Redo",
				hasBackground:true,
				uid:"silex.EditionToolBar.ToolItem.Redo",
				groupUid:"silex.EditionToolBar.ToolItemGroup.History",
				level:2, 
				toolUid:"silex.EditionToolBar.Tool",
				url:$rootUrl+"plugins/viewMenu/redo_button.swf",
				label:"Redo",
				description:"Ctr Y"}]);
				
				
			}
			
			/**
			 * This function resises the edition toolbar div
			 */
			function redrawEditionToolBarDiv()
			{
				$sizeWYSIWYG = getDivSize($("#toolsContainerDiv"));
				//alert("redrawEditionToolBarDiv called: " + $(window).height() + " - " + $sizeWYSIWYG.height);
				if (isVisibleEditionToolBarDiv == true)
				{
					$('#editionToolBarDiv').width("35px");
					$('#editionToolBarDiv').height(($(window).height() - $sizeWYSIWYG.height) + "px");
				}
				
				$sizeToolBox = getDivSize($(CONTAINER_DIV));
				$('#flashcontent').css( { "width": ($(window).width() - $sizeToolBox.width) + "px", "height": ($(window).height() - $sizeWYSIWYG.height) + "px","left" : $sizeToolBox.width + "px" } );
			}
			
			/**
			 * This function is the onBodyLoad hook callback
			 */
			function onBodyResizeEditionToolBar(){
				redrawEditionToolBarDiv();
			}
			
			/**
			 * This function is the loginSuccess hook callback
			 */
			function showWysiwygEditionToolBar(){
				isVisibleEditionToolBarDiv = true;
				$(PLUGIN_DIV).show();
				redrawEditionToolBarDiv();
			}	
			
			/**
			 * This function is the logout hook callback
			 */
			function hideWysiwygEditionToolBar(){
				isVisibleEditionToolBarDiv = false;
				$(PLUGIN_DIV).hide();
				redrawEditionToolBarDiv();
			}
			
			/**
			 * hook for Silex API, called when silex changes the current deeplink
			 */
			function openSilexPageEditionToolBar($event)
			{
				//alert("openSilexPageEditionToolBar called");
				if (editionToolBar && editionToolBar.flashSelectPage){
					$pageName = $event.hashValue;
					$pageName = $pageName.substring($pageName.lastIndexOf("/")+1);
					editionToolBar.flashSelectPage($pageName);
				}
			}
			
			/**
			 * compute the size of all the lowest children in a div
			 */
			function getDivSize($div)
			{
				var $sumW=0; 
				var $sumH=0; 
				$div.children().each(
					function () {
						if ($(this).children().length>0)
						{
							$size = getDivSize($(this));
							$sumW += $size.width; 
							$sumH += $size.height;
						}else
						{
							$sumW += $(this).width();
							$sumH += $(this).height();
						} 
					} 
				); 
				return {width:$sumW,height:$sumH};
			}
			
			loadEditionToolBar();
			initEditionToolBarTool();
			document.getElementById('silex').SetVariable('silex_exec_str','alertSimple:'+'Navigation mode selected');
			
		</script>
		<?php
		;
	}
	
}

?>