<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

require_once ROOTPATH.'cgi/includes/PluginComponentLibraryBase.php';


class OOFComponents extends PluginComponentLibraryBase
{

	/**
	* override the initHooks method and add a callback
	*/ 
	public function initHooks(HookManager $hookManager)
	{
		parent::initHooks($hookManager);
		$hookManager->addHook('pre-index-head', array($this, 'preload_oof_lib_index_head_hook'));
	}
	/**
	 * Adds the OofClasses.swf as2 component to the site's preload file list.
	*/
	public function preload_oof_lib_index_head_hook($templateContextByRef)
	{
		$templateContext = $templateContextByRef;
		if ($templateContext->websitePreloadFileList != '') $templateContext->websitePreloadFileList .= ',';
		$templateContext->websitePreloadFileList .= "plugins/oofComponents/OofClasses.swf";
	}
}

?>