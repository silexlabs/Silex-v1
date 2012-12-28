<?php
/*
 This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

// include './rootdir.php'; we do not call rootdir.php for the moment as it's already within the filepath. Also this includes seems to break the administration part of the plugin. If we notice some cases where ROOTPATH isn't known when we call index.php, we will have to rethink this part.
require_once ROOTPATH.'cgi/includes/plugin_base.php';

class snapshot extends plugin_base
{
	/**
	* Initialises the plugin's parameters
	*/
	public function initDefaultParamTable()
	{
		// get plugin language data
		$langManager = LangManager::getInstance();
		$localisedFileUrl = $langManager->getLangFile($this->pluginName);
		global $localisedStrings;
		$localisedStrings = $langManager->getLangObject($this->pluginName, $localisedFileUrl);
		
		$this->paramTable = array( 
			array(
				'name' => 'snapShotTool_layoutDepth',
				'label' => $localisedStrings['SNAPSHOT_LAYOUT_DEPTH_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_LAYOUT_DEPTH_DESCRIPTION'],
				'value' => '0',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '2'
			),
			array(
				'name' => 'snapShotTool_imageType',
				'label' => $localisedStrings['SNAPSHOT_IMAGE_TYPE_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_IMAGE_TYPE_DESCRIPTION'],
				'value' => 'png',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '5'
			),
			array(
				'name' => 'snapShotTool_imageWidth',
				'label' => $localisedStrings['SNAPSHOT_IMAGE_WIDTH_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_IMAGE_WIDTH_DESCRIPTION'],
				'value' => '',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '200'
			),
			array(
				'name' => 'snapShotTool_imageHeight',
				'label' => $localisedStrings['SNAPSHOT_IMAGE_HEIGHT_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_IMAGE_HEIGHT_DESCRIPTION'],
				'value' => '',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '200'
			),
			array(
				'name' => 'snapShotTool_imageX',
				'label' => $localisedStrings['SNAPSHOT_IMAGE_X_POSITION_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_IMAGE_X_POSITION_DESCRIPTION'],
				'value' => '0',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '200'
			),
			array(
				'name' => 'snapShotTool_imageY',
				'label' => $localisedStrings['SNAPSHOT_IMAGE_Y_POSITION_LABEL'],
				'description' => $localisedStrings['SNAPSHOT_IMAGE_Y_POSITION_DESCRIPTION'],
				'value' => '0',
				'restrict' => '',
				'type' => 'string',
				'maxChars' => '200'
			)
		);
	}
	
	/**
	* Overrides the initHooks method and adds a callback
	*/
	public function initHooks(HookManager $hookManager)
	{
		parent::initHooks($hookManager);
		$hookManager->addHook('admin-body-end', array($this, 'snapShotAdminBodyEnd'));
	}
	
	/**
	* Admin-body-end hook callback
	*/
	public function snapShotAdminBodyEnd()
	{
		// get plugin language data
		global $localisedStrings;

		// plugin folder path
		$PLUGIN_DIR = 'plugins/snapshot/';
		// Url of the snapshot icon appearing in the view menu
		$SNAPSHOT_ICON_URL = 'snapshot_tool_view_menu_item.swf';

		?> 
		<script type='text/javascript'>
		
			/**
			 * Adds the snapshot icon to the view menu icon array when the view menu is ready
			 */
			function addToolBarItems()
			{
				silexNS.SilexAdminApi.callApiFunction('toolBarItems', 'addItem', [{
				name:'SnapShot',
				hasBackground:true,
				uid:'silex.EditionToolBar.ToolItem.SnapShot',
				groupUid:'silex.EditionToolBar.ToolItemGroup.Utils',
				level:0, 
				toolUid:'silex.EditionToolBar.Tool',
				url:$rootUrl+'<?php echo $PLUGIN_DIR . $SNAPSHOT_ICON_URL ?>',
				label:"Snapshot",
				description:"S"}]);
				//label:"<?php echo $localisedStrings['SNAPSHOT_VIEWMENU_BUTTON_LABEL']; ?>",
				//description:"<?php echo $localisedStrings['SNAPSHOT_VIEWMENU_BUTTON_DESCRIPTION']; ?>"}]);
			}
			
			/**
			 * Call the takeSnapShot method in AS2 via the Silex object. Launched on viewmenu snapshot icon click.
			 */
			function takeSnapshot()
			{
				//alert('javascript: takeSnapshot');
				document.getElementById('silex').SnapShotTool_takeSnapShot();
			}
			
			/**
			 * Send the needed translations to the AS2 client
			 */
			function getSnapshotTranslation()
			{
				return <?php echo '{SNAPSHOT_MESSAGE_START:"' . $localisedStrings['SNAPSHOT_MESSAGE_START'] . '",' . 'SNAPSHOT_MESSAGE_ERROR_7:"' . $localisedStrings['SNAPSHOT_MESSAGE_ERROR_7'] . '"}'; ?>
			}
			
			addToolBarItems();
			document.getElementById('silex').SetVariable('silex_exec_str','load_clip:'+'<?php echo $PLUGIN_DIR ?>'+'snapshot_tool.swf,plugins');
			
		</script>
		<?php
	}
}

?>