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

class ftpClient extends plugin_base
{
	
	function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "snapshot_icon_url",
				"label" => "Snaphot icon url",
				"description" => "This is the adress where the snapshot icon appearing in the view menu is located",
				"value" => "snap_shot_tool_view_menu_item_os.swf",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
	}
	public function initHooks($hookManager)
	{
		$hookManager->addHook('admin-body-end', array($this, 'ftpClientAdminBodyEnd'));
	}
			
	/**
	 * Silex hook for the script tag
	 */
	public function ftpClientAdminBodyEnd()
	{
		$i = 0;
		while( $i < count( $this->paramTable ) )
		{
			if($this->paramTable[$i]["name"] == "snapshot_icon_url")
				$snapshotIconUrl = $this->paramTable[$i]["value"];
			$i++;
		}
	
		?> 
		<script type="text/javascript">
			
			function openFtp()
			{
				silexJsObj.pop($rootUrl+"plugins/ftpClient/FtpClient.php", 653, 313);
			}
			
			//add the snapshot icon to the view menu icon array when the view menu is ready
			function changeViewMenuMode()
			{
				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"Ftp",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.Ftp",
				groupUid:"silex.ViewMenu.ToolItemGroup.Links",
				level:3, 
				toolUid:"silex.ViewMenu.Tool",
				url:$rootUrl+"plugins/ftpClient/FtpClientViewMenuItem.swf",
				label:"Open Ftp",
				description:"Open Ftp (Alt F)"}]);
			}
			
			changeViewMenuMode();
			
		</script>
		<?php	
		return true;
	}
	
}

?>
