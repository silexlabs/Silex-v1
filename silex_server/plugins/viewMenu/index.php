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

class viewMenu extends plugin_base
{

	function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "logo_link_url",
				"label" => "Logo link URL",
				"description" => "The url displayed when the user clicks on the logo",
				"value" => "http://projects.silexlabs.org/",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			),
			
			array(
				"name" => "logo_asset_url",
				"label" => "Logo asset URL",
				"description" => "The url of the logo graphical asset",
				"value" => "logoViewMenu.swf",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
	}
	
	public function initHooks($hookManager)
	{
		$hookManager->addHook('admin-body-end', array($this, 'viewMenuAdminBodyEnd'));
	}
	
	
	/**
	 * Silex hook for the script tag
	 */
	public function viewMenuAdminBodyEnd()
	{
			$langManager = LangManager::getInstance();
			$localisedFileUrl = $langManager->getLangFile($this->pluginName, "en");
			$localisedStrings = $langManager->getLangObject($this->pluginName, $localisedFileUrl);
			
			$i = 0;
			while( $i < count( $this->paramTable ) )
			{
				if($this->paramTable[$i]["name"] == "logo_link_url")
					$logoLinkUrl = $this->paramTable[$i]["value"];
					
				if($this->paramTable[$i]["name"] == "logo_asset_url")
					$logoAssetUrl = $this->paramTable[$i]["value"];	
					
				$i++;
				
				
			}
		?>
		<script type="text/javascript">
			// <![CDATA[
			
			function loadViewMenu(event)
			{	
				
				//alert("openWysiwyg" + $("#wysiwygDiv").length + $('#toolsContainerDiv'));
				if (!$("#viewMenuContent").length)
				{
					$frame = $('<div id="viewMenuContent" name="viewMenuContent" align="center" style="overflow:auto; width: 100%; height: 35px; position: absolute; bottom: 0px; z-index: 1000;" ></div>');
					$('#toolsContainerDiv').append($frame);
					
					var fo = new SWFObject($rootUrl+"plugins/viewMenu/view_menu.swf", "viewMenu", "100%", "100%", "8", "0","best",null,"./no-flash.html");
					fo.addVariable("baseUrlWysiwygStyle", $rootUrl+"plugins/wysiwyg/design/WysiwygStyle.swf");
					fo.addParam("bgcolor", "#D6D6D6");
					fo.addParam("wmode","opaque");
					fo.addVariable("ftpUrl", "tools/FtpClient/");
					fo.addVariable("logoUrl","<?php echo $logoAssetUrl ?>");
					fo.addParam("AllowScriptAccess","always");
					fo.write("viewMenuContent");
					var viewMenu = $('#viewMenu')[0];
					silexNS.SilexAdminApi.addEventListener(viewMenu);
					

					// ajax load html frame 
					//$("#viewMenuDiv").load($rootUrl+"plugins/viewMenu/view_menu.swf");
					
					//add the stage_border plugin to silex in the plugins MovieClip (second  parameter)
					document.getElementById('silex').SetVariable('silex_exec_str','load_clip:plugins/viewMenu/stage_border.swf,plugins');
				}

			}
			
			function onLogoClick()
			{
				window.open("<?php echo $logoLinkUrl ?>", "blank");
			}
			
			function initViewMenuTool()
			{
				silexNS.SilexAdminApi.callApiFunction("toolBars", "addItem", [{
				name:"ViewMenuTool",
				uid:"silex.ViewMenu.Tool",
				label:"the ViewMenu tool label",
				description:" the ViewMenu tool description"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"Windows",
				uid:"silex.ViewMenu.ToolItemGroup.Windows", 
				level:1,
				toolUid:"silex.ViewMenu.Tool",
				label:"",
				description:""}]);
				//label:"<?php echo $localisedStrings['VIEW_MENU_GROUP_WINDOWS_LABEL']; ?>",
				//description:"<?php echo $localisedStrings['VIEW_MENU_GROUP_WINDOWS_DESCRIPTION']; ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"Display",
				uid:"silex.ViewMenu.ToolItemGroup.Display",
				level:5,
				toolUid:"silex.ViewMenu.Tool",
				label:"",
				description:""}]);
				//label:"<?php echo $localisedStrings['VIEW_MENU_GROUP_DISPLAY_LABEL']; ?>",
				//description:"<?php echo $localisedStrings['VIEW_MENU_GROUP_DISPLAY_DESCRIPTION']; ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:"Links",
				uid:"silex.ViewMenu.ToolItemGroup.Links",
				level:10,
				toolUid:"silex.ViewMenu.Tool",
				label:"",
				description:""}]);

				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"scrollMode",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.scrollMode",
				groupUid:"silex.ViewMenu.ToolItemGroup.Display",
				level:0, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Set view to scroll mode",
				description:"Set view to scroll mode (D)",
				url:$rootUrl+"plugins/viewMenu/scrollScaleModeButton.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"showAllMode",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.showAllMode",
				groupUid:"silex.ViewMenu.ToolItemGroup.Display",
				level:1, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Set view to show all mode",
				description:"Set view to show all mode (F)",
				url:$rootUrl+"plugins/viewMenu/showAllButton.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"StageBorder",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.StageBorder",
				groupUid:"silex.ViewMenu.ToolItemGroup.Display",
				level:2, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Display stage border",
				description:"Display stage border (R)",
				url:$rootUrl+"plugins/viewMenu/stageBorderButton.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"openHelp",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.openHelp",
				groupUid:"silex.ViewMenu.ToolItemGroup.Links",
				level:0, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Open Help",
				description:"Open Help (H)",
				url:$rootUrl+"plugins/viewMenu/openHelp.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"openManager",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.openManager",
				groupUid:"silex.ViewMenu.ToolItemGroup.Links",
				level:1, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Open Manager",
				description:"Open Manager (Alt H)",
				url:$rootUrl+"plugins/viewMenu/openManager.swf"}]);
			}

			loadViewMenu();
			initViewMenuTool();
			
		</script>
		<?php
		;
	}
	
}

?>