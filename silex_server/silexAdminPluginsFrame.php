<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

set_include_path(get_include_path() . PATH_SEPARATOR . "./"  . PATH_SEPARATOR . "./cgi/library/");
require_once('cgi/includes/server_config.php');
require_once('cgi/includes/plugin_manager.php');
require_once('cgi/includes/config_editor.php');
require_once('cgi/includes/HookManager.php');
require_once('cgi/includes/ComponentManager.php');
require_once('cgi/includes/site_editor.php');


$serverConfig = new server_config();
$pluginManager = new plugin_manager();
$configEditor = new config_editor();
$siteEditor = new site_editor();
$plugin_manager = new plugin_manager();
$hookManager = HookManager::getInstance();

//Create server plugins

$silexPluginsConf = $configEditor->readConfigFile($serverConfig->silex_server_ini['SILEX_PLUGINS_CONF'], "phparray");
$pluginManager->createActivePlugins($silexPluginsConf, $hookManager);


//Create website-specific plugins
$websiteConfigPlugins = Array();
$websiteConfigPlugins['PLUGINS_LIST'] = $_GET['websitePlugins'];
$plugin_manager->createActivePlugins($websiteConfigPlugins, $hookManager);

// Call Hook admin-body-end to activate all admin specific plugins
$hookManager->callHooks('admin-body-end');

?>