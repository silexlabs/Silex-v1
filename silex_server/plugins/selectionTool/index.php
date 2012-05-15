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

class selectionTool extends plugin_base
{
	
	
	function initDefaultParamTable()
	{
		
	}
	
	public function initHooks($hookManager)
	{
		$hookManager->addHook('admin-body-end', array($this, 'selectionToolAdminBodyEnd'));
	}
	

	public function selectionToolAdminBodyEnd()
	{
		?>
		<script type="text/javascript">
		
		function loadSelectionTool()
		{
			document.getElementById('silex').SetVariable("silex_exec_str","load_clip:" + "<?php echo $this->pluginRelativeUrl ?>" +  "/selection_tool.swf,plugins,selectionTool");	
		}
		loadSelectionTool();

		</script>
		
		<?php
	}
	
}

?>