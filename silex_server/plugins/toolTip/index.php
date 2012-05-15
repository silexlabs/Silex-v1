<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

require_once ROOTPATH.'cgi/includes/plugin_base.php';


class toolTip extends plugin_base
{

	function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "tooltipAssetUrl",
				"label" => "tooltip style url",
				"description" => "This is the url where the tooltip style style is located at",
				"value" => "plugins/toolTip/ToolTipAsset.swf",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			),
			
			array(
				"name" => "xOffset",
				"label" => "xOffset",
				"description" => "This is the x offset of the tooltip, relative to the mouse pointer",
				"value" => "15",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			),
			
			array(
				"name" => "yOffset",
				"label" => "yOffset",
				"description" => "This is the y offset of the tooltip, relative to the mouse pointer",
				"value" => "15",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			),
			
			array(
				"name" => "leftMargin",
				"label" => "left margin",
				"description" => "This is the left margin of the tooltip text",
				"value" => "3",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			),
			
			array(
				"name" => "rightMargin",
				"label" => "right margin",
				"description" => "This is the right margin of the tooltip text",
				"value" => "6",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
	}

	/**
	* override the initHooks method and add a callback
	*/ 
	public function initHooks(HookManager $hookManager)
	{
		parent::initHooks($hookManager);
		$hookManager->addHook('pre-index-head', array($this, 'preload_tooltip_index_head_hook'));
		$hookManager->addHook('index-body-end', array($this, 'tooltip_index_body_end'));
	}
	/**
	 * Adds the OofClasses.swf as2 component to the site's preload file list.
	*/
	public function preload_tooltip_index_head_hook($templateContextByRef)
	{
		$templateContext = $templateContextByRef;
		if ($templateContext->websitePreloadFileList != '') $templateContext->websitePreloadFileList .= ',';
		$templateContext->websitePreloadFileList .= "plugins/toolTip/ToolTip.swf";
	}
	
	public function tooltip_index_body_end()
	{
	
		?>
		<script>
			function getToolTipConfig()
			{
				return {assetUrl:'<?php echo $this->paramTable[0]['value'] ?>',
				xOffset:<?php echo $this->paramTable[1]['value'] ?>,
				yOffset:<?php echo $this->paramTable[2]['value'] ?>,
				leftMargin:<?php echo $this->paramTable[3]['value'] ?>,
				rightMargin:<?php echo $this->paramTable[4]['value'] ?>};
			}
		</script>
		<?php
	}
}

?>