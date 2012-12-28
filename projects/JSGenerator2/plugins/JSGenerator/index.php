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

class JSGenerator extends plugin_base
{
	
	public function initHooks(HookManager $hookManager)
	{
		
		$hookManager->addHook('index-script', array($this, 'addJS'));
	}

	/**
	*  Adds loading of the JS script when index-script is run.
	*/
	public function addJS()
	{
		?>
		<script type="text/javascript" src="plugins/JSGenerator/JSGenerator.js">
		</script>
		<?php
	}
}

?>
