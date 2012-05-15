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
require_once ROOTPATH.'cgi/includes/server_config.php';
require_once ROOTPATH.'cgi/includes/LangManager.php';

class wysiwyg extends plugin_base
{
	
	var $serverConfig; 
	
	function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "wysiwyg_style_url",
				"label" => "Wysiwyg style url",
				"description" => "This is the adress where the wysiwyg style is located is located",
				"value" => "design/WysiwygStyle.swf",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
	}
	
	public function initHooks($hookManager)
	{
		$hookManager->addHook('admin-body-end', array($this, 'wysiwyg_admin_body_end_hook'));
	}
	
	/**
	 * Silex hook for the script tag
	 */
	public function wysiwyg_admin_body_end_hook()
	{
		$serverConfig = new server_config(); 
		
		$langManager = LangManager::getInstance();
		$localisedFileUrl = $langManager->getLangFile($this->pluginName, 'en');
		$localisedStrings = $langManager->getLangObject($this->pluginName, $localisedFileUrl);
		
		
		$i = 0;
		while( $i < count( $this->paramTable ) )
		{
			if($this->paramTable[$i]["name"] == "wysiwyg_style_url")
				$wysiwygStyleUrl = $this->paramTable[$i]["value"];
			$i++;
		}
		
		$dir = dir(ROOTPATH.'plugins/wysiwyg/panels/');
		$files = array();
		
		while($name =  $dir->read())
		{
			$files[] = $name;
		}
		
		$panelsUrl = implode($files, ",");
		
		
		?>
		<!-- WYSIWYG Plugin -->
		<script type="text/javascript">
		
			function loadWysiwyg(event)
			{	
			
				if (!$("#wysiwygDiv").length)
				{
					$frame = $('<div id="wysiwygDiv" name="wysiwygDiv" ></div>');
					$('#toolsContainerDiv').append($frame);

					// ajax load html frame 
					$("#wysiwygDiv").load($rootUrl+"plugins/wysiwyg/frame.php?wysiwygStyleUrl=<?php echo urlencode($wysiwygStyleUrl);  ?>&defaultLanguage=<?php echo $serverConfig->silex_server_ini['SILEX_ADMIN_DEFAULT_LANGUAGE']; ?>&localisedFileUrl=<?php echo urlencode($localisedFileUrl);?>");
					
				}

			}
			
			function toggleStageBorderVisibility()
			{
				document.getElementById('silex').toggleStageBorderVisibility();
			}
			
			
			
			function refreshStageBorder()
			{
				if (!$("#silex").length)
				{
					if (document.getElementById('silex').refreshStageBorder == undefined)
					{
						document.getElementById('silex').refreshStageBorder();
					}
				}
				
			}
			
			function initViewMenuItems()
			{
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"openWysiwyg",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.openWysiwyg",
				groupUid:"silex.ViewMenu.ToolItemGroup.Windows",
				level:0, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Open Wysiwyg frame",
				description:"Open Wysiwyg - frame mode (W)",
				url:$rootUrl+"plugins/wysiwyg/openWysiwyg.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"openPopUp",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.openPopUp",
				groupUid:"silex.ViewMenu.ToolItemGroup.Windows",
				level:1, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Open Wysiwyg popup",
				description:"Open Wysiwyg - popup mode (Alt H)",
				url:$rootUrl+"plugins/wysiwyg/openWysiwygPopUp.swf"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"closeWysiwyg",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.closeWysiwyg",
				groupUid:"silex.ViewMenu.ToolItemGroup.Windows",
				level:2, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Close Wysiwyg",
				description:"Close Wysiwyg (Ctrl W)",
				url:$rootUrl+"plugins/wysiwyg/closeWysiwyg.swf"}]);
				}
			
			function initSpecificPlugin()
			{
			
				silexNS.SilexAdminApi.callApiFunction("toolBars", "addItem", [{name:"PropertiesTool", uid:"silex.Properties.Tool", label:"the Properties tool label", description:" the Properties tool description"}]);
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{name:"Display", uid:"silex.Properties.ToolItemGroup.Display", level:0, toolUid:"silex.Properties.Tool", label:"", description:""}]);
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{name:"Action", hasBackground:false, uid:"silex.Properties.ToolItem.Action", groupUid:"silex.Properties.ToolItemGroup.Display", level:0, toolUid:"silex.Properties.Tool", label:"the Action plugin label", description:" the Action plugin description", url:$rootUrl+"plugins/wysiwyg/ActionPluginToolBarItem.swf"}]);
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{name:"Specifc", hasBackground:false, uid:"silex.Properties.ToolItem.Specifc", groupUid:"silex.Properties.ToolItemGroup.Display", level:0, toolUid:"silex.Properties.Tool", label:"the Specific plugin label", description:" the Specific plugin description", url:$rootUrl+"plugins/wysiwyg/SpecificPluginToolBarItem.swf"}]);
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{name:"List", hasBackground:false, uid:"silex.Properties.ToolItem.List", groupUid:"silex.Properties.ToolItemGroup.Display", level:0, toolUid:"silex.Properties.Tool", label:"the List plugin label", description:" the List plugin description", url:$rootUrl+"plugins/wysiwyg/ListPluginToolBarItem.swf"}]);
				
			}
			
			function initAddComponentToolBar()
			{
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Images',
				uid:'silex.AddComponent.ToolItemGroup.Images',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['IMAGES_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['IMAGES_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
			
				silexNS.SilexAdminApi.callApiFunction("toolBars", "addItem", [{
				name:"AddComponentTool", 
				uid:"silex.AddComponent.Tool",
				label:"the AddComponent tool label",
				description:" the AddComponent tool description"}]);
				
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Text',
				uid:'silex.AddComponent.ToolItemGroup.Text',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['TEXT_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['TEXT_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'AudioVideo',
				uid:'silex.AddComponent.ToolItemGroup.AudioVideo',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['AUDIO_VIDEO_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['AUDIO_VIDEO_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Animation',
				uid:'silex.AddComponent.ToolItemGroup.Animation',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['ANIMATION_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['ANIMATION_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Geometry',
				uid:'silex.AddComponent.ToolItemGroup.Geometry',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['GEOMETRY_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['GEOMETRY_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Cliparts',
				uid:'silex.AddComponent.ToolItemGroup.Cliparts',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['CLIPARTS_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['CLIPARTS_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
		
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Buttons',
				uid:'silex.AddComponent.ToolItemGroup.Buttons',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['BUTTONS_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['BUTTONS_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Frames',
				uid:'silex.AddComponent.ToolItemGroup.Frames',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['FRAMES_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['FRAMES_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Galleries',
				uid:'silex.AddComponent.ToolItemGroup.Galleries',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['GALLERIES_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['GALLERIES_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'UIElements',
				uid:'silex.AddComponent.ToolItemGroup.UIElements',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['UI_ELEMENTS_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['UI_ELEMENTS_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Lists & menus',
				uid:'silex.AddComponent.ToolItemGroup.ListsMenus',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['LISTS_AND_MENUS_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['LISTS_AND_MENUS_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);		
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'External Data',
				uid:'silex.AddComponent.ToolItemGroup.ExternalData',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['EXTERNAL_DATA_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['EXTERNAL_DATA_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Record',
				uid:'silex.AddComponent.ToolItemGroup.Record',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['RECORD_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['RECORD_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Email',
				uid:'silex.AddComponent.ToolItemGroup.Email',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['EMAIL_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['EMAIL_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);	
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Utilities',
				uid:'silex.AddComponent.ToolItemGroup.Utilities',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['UTILITIES_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['UTILITIES_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
				
				silexNS.SilexAdminApi.callApiFunction("toolBarGroups", "addItem", [{
				name:'Legacy',
				uid:'silex.AddComponent.ToolItemGroup.Legacy',
				level:0,
				toolUid:'silex.AddComponent.Tool',
				label:"<?php echo $localisedStrings['LEGACY_ADD_COMPONENT_GROUP_LABEL'] ?>",
				description:"<?php echo $localisedStrings['LEGACY_ADD_COMPONENT_GROUP_DESCRIPTION'] ?>"}]);
			}
			
			function getSpecificPluginConfig()
			{
				return {url:$rootUrl+"<?php echo "plugins/wysiwyg/panels/" ?>", panelsUrl:"<?php echo $panelsUrl ?>"};
			}
			
			loadWysiwyg();
			initSpecificPlugin();
			initAddComponentToolBar();
			initViewMenuItems();
			

		   // ]]>
		</script>
		<!-- End WYSIWYG Plugin -->
		
		<?php
		return true;
	}
	
}

?>