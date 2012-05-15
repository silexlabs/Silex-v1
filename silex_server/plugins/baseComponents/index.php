<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once ROOTPATH.'cgi/includes/PluginComponentLibraryBase.php';


	class BaseComponents extends PluginComponentLibraryBase
	{
		public function initHooks($hookManager)
		{
			parent::initHooks($hookManager);
			$hookManager->addHook('index-head-end', array($this, 'registerJSFile'));
			$hookManager->addHook('pre-index-head', array($this, 'preload_silex_base_components_lib_index_head_hook'));
			$hookManager->addHook('admin-body-end', array($this, 'baseComponentsAdminBodyEnd'));
//			$hookManager->addHook('template-context', array($this, 'registerJSFile'));
		}
		
		public function registerJSFile($templateContext, $context)
		{
			if (!isset($_GET['format']) || $_GET['format'] == "html")
//			if($templateContext->renderer == "html")
			{
				?>
				<script type="text/javascript" src="plugins/baseComponents/html5/GeometryApi.js" ></script>
				<?php
			}
		}

		/**
		 * Adds the silex base components as2 lib to the site's preload file list.
		*/
		public function preload_silex_base_components_lib_index_head_hook($templateContextByRef)
		{
			$templateContext = $templateContextByRef;
			if ($templateContext->websitePreloadFileList != '') $templateContext->websitePreloadFileList .= ',';
			$templateContext->websitePreloadFileList .= "plugins/baseComponents/baseComponentsClasses.swf";
		}		
		
		public function baseComponentsAdminBodyEnd()
		{
			?>
			<script>
			
				/**
				 * This function initialises the needed hooks and flash icons
				 */
				function addToolBarItems()
				{
					silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
					name:"Rectangle",
					hasBackground:true,
					uid:"silex.EditionToolBar.ToolItem.Rectangle",
					groupUid:"silex.EditionToolBar.ToolItemGroup.Main",
					level:2, 
					toolUid:"silex.EditionToolBar.Tool",
					label:"Rectangle Geometry",
					description:"M",
					url:$rootUrl+"plugins/baseComponents/rectangle_button.swf"}]);
					
					silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
					name:"Ellipse",
					hasBackground:true,
					uid:"silex.EditionToolBar.ToolItem.Ellipse",
					groupUid:"silex.EditionToolBar.ToolItemGroup.Main",
					level:3, 
					toolUid:"silex.EditionToolBar.Tool",
					label:"Ellipse Geometry",
					description:"L",
					url:$rootUrl+"plugins/baseComponents/ellipse_button.swf"}]);
					
					silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
					name:"TextSelection",
					hasBackground:true,
					uid:"silex.EditionToolBar.ToolItem.TextSelection",
					groupUid:"silex.EditionToolBar.ToolItemGroup.Main",
					level:4, 
					toolUid:"silex.EditionToolBar.Tool",
					label:"Text field",
					description:"T",
					url:$rootUrl+"plugins/baseComponents/text_button.swf"}]);
					
					
				}
				
				addToolBarItems();
			</script>
			<?php
		}
	}

?>