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

class bugReporting extends plugin_base
{
	/*
		Variable: $pluginScope
		The scope of the plugin. In the case of the bugReporting plugin, we have a plugin only for the "manager" scope: 100.
	*/
	protected $pluginScope = 4;
	
	/*
		Function: getDescription
		Get the status of update of the the server (does it run the latest version?).
		
		Returns:
		The plugin's description string. 
	*/
	public function getDescription()
	{
		return "Bug Reporting";
	}
	
   	/*
		Function: getAdminPage
		generates the administration page of the bugReporting plugin

		Returns:
		The html code of the administration page of the updater
	*/
    public function getAdminPage($siteName)
	{
		$result = "<html><body><iframe width=\"980\" height=\"1800\" frameborder=\"0\"  vspace=\"0\"  hspace=\"0\"  marginwidth=\"0\"
					marginheight=\"0\" scrolling=no src=\"http://sourceforge.net/tracker/?func=add&group_id=192954&atid=943477\" /></body></html>" ;
        return $result;
    }
	
}

?>
