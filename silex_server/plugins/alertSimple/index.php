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

class AlertSimple extends plugin_base
{
	
	public function initHooks($hookManager)
	{
		$hookManager->addHook('index-body-end', array($this, 'alertSimpleIndexBodyEnd'));
		$hookManager->addHook('admin-body-end', array($this, 'alertSimpleAdminBodyEnd'));
	}
	
		function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "dialogBoxAssetUrl",
				"label" => "dialog boxes swf url",
				"description" => "This is the url if the swf containing the dialog boxes",
				"value" => "plugins/alertSimple/DialogBoxes.swf",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "200"
			)
		);
	}
	
	/**
	 * Silex hook for the script tag
	 */
	public function alertSimpleAdminBodyEnd()
	{
	
		?> 
		<script type="text/javascript">
			document.getElementById('silex').SetVariable('silex_exec_str','load_clip:plugins/alertSimple/AlertSimple.swf,plugins');
		</script>
		<?php	
		return true;
	}
	
	/**
	 * Silex hook for the script tag
	 */
	public function alertSimpleIndexBodyEnd()
	{
		?> 
		<script type="text/javascript">
		
		/**
		* load the swf containing the dialog box used in user mode
		*/
		function initDialogBoxes(){
		document.getElementById('silex').SetVariable('silex_exec_str','load_clip:<?php echo $this->paramTable[0]['value'] ?>,plugins,dialogBox');
		}
		// check if silexNS exists since it does not in html mode
		var silexNS; 
		if (silexNS != undefined)
			silexNS.HookManager.addHook("preloadDone",initDialogBoxes );
		</script>
		<?php	
		return true;
	}
	
}

?>
