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

class htmlGenerator extends plugin_base
{
	function initDefaultParamTable()
	{
		$this->paramTable = array( 
			array(
				"name" => "defaultFormat",
				"label" => "Default format",
				"description" => "Values can be 'html' or 'flash'. It is the format which will be displayed if there is not a format given in the URL (the '&format=html' or '&format=flash' in the address)",
				"value" => "flash",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "255"
			),
			array(
				"name" => "cssDeclarations",
				"label" => "CSS declaration",
				"description" => "CSS declaration URL-encoded. Click <a href=\"http://www.silexlabs.org/?p=2503\">here for more info</a>.",
				"value" => "",
				"restrict" => "",
				"type" => "string",
				"maxChars" => "2550"
			)
		);
	}
	
	public function initHooks($hookManager)
	{
		
		$hookManager->addHook('index-head-end', array($this,'indexHeadEnd'));
		$hookManager->addHook('index-script', array($this, 'noFlashJS'));
		$hookManager->addHook('admin-body-end', array($this, 'htmlAdminBodyEnd'));
		//$hookManager->addHook('index-noembed', array($this, 'noFlashNoJS'));
		//if(isset($_GET['format']))
		//{
		//	if($_GET['format'] == "html")
		//	{
		//		$hookManager->addHook('pre-index-head', array($this, 'htmlGeneratorStart'));
		//	}
		//}	
		$this->htmlGeneratorStart();
	}
	/**
	 * Silex hook executed befor the end of the </head> tag
	 * echo the CSS
	 */
	function indexHeadEnd()
	{
		$i = 0;
		$cssDeclarations = "";
		$defaultFormat = "flash";
		while( $i < count( $this->paramTable ))
		{
			if($this->paramTable[$i]["name"] == "cssDeclarations")
				$cssDeclarations = $this->paramTable[$i]["value"];
			if($this->paramTable[$i]["name"] == "defaultFormat")
				$defaultFormat = $this->paramTable[$i]["value"];
			$i++;
		}
		if(isset($_GET['format']) && $_GET['format'] == "html"
			|| (!isset($_GET['format']) && $defaultFormat == "html")
		)
		{
			echo '<style type="text/css">';
			echo urldecode($cssDeclarations);
			echo '</style>';
		}
	}
			
	/**
	 * Silex hook for the script tag
	 */
	public function htmlGeneratorStart()
	{
		//include(dirname(__FILE__)."/generator/index.php");
		if(class_exists("php_Lib"))
		{
			php_Lib::loadLib(dirname(__FILE__).'/generator/lib');
			org_silex_htmlGenerator_Main::main();
			//exit;
		}
	//	org_silex_htmlGenerator_Main::main();
		//exit;
	}
	public function noFlashJS($idSite, $deeplink)
	{
		php_Lib::loadLib(dirname(__FILE__).'/generator/lib');
		org_silex_htmlGenerator_Main::noFlashJS($idSite, $deeplink);
	}
	
	public function htmlAdminBodyEnd()
	{
		?>
		<script type="text/javascript">
			// <![CDATA[
			
			function onHtml5Press()
			{
				window.open($rootUrl + '?/' + $id_site + '&format=html','_blank');
			}
			
			function initHtmlTool()
			{

				silexNS.SilexAdminApi.callApiFunction("toolBarItems", "addItem", [{
				name:"html5",
				hasBackground:true,
				uid:"silex.ViewMenu.ToolItem.html5",
				groupUid:"silex.ViewMenu.ToolItemGroup.Links",
				level:4, 
				toolUid:"silex.ViewMenu.Tool",
				label:"Open html5 site",
				description:"Open html5 site (5)",
				url:$rootUrl+"plugins/htmlGenerator/html5_logo.swf"}]);
			}
			
			initHtmlTool();
			// ]]>
		</script>

		<?php
	}
}
?>