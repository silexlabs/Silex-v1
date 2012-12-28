<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html

Author: 
Thomas Fétiveau (¯abojad)  <http://tofee.fr> or <thomas.fetiveau.tech@gmail.com>

TODO
	- add PHP indexes (and htaccess?) in each directory of the plugin
 */
require_once ROOTPATH.'cgi/includes/plugin_base.php';
/*
Class: updater
This is the main class of the Silex updater plugin.
*/
class updater extends plugin_base
{
	/*
	Variable: $pluginScope
	The scope of the plugin. In the case of the updater, we have a plugin only for the "manager" scope : 100.
	*/
	protected $pluginScope = 4;
	
	/*
	Function: initDefaultParamTable
	Initialize the updater's parameters. The first parameter initiliazed is update_server_address that contains the http url of the download server. The second is the exchange platform address where to find the new items to install
	*/
	function initDefaultParamTable()
	{
		$this->paramTable = array(
			array(
				"name" => "update_server_address",
				"label" => "Update server address",
				"description" => "This is the address of the update server which the plugin will communicate with. It does so in order to check if you are running the latest version of Silex and to download the files to update if necessary. In a normal use of Silex, you should not modify this parameter.",
				"value" => "http://downloads.silexlabs.org/silex/latest_version/",
				"restrict" => "",
				"type" => "string",
				"maxChars" => ""
			),
			array(
				"name" => "exchange_platform_address",
				"label" => "Exchange platform address",
				"description" => "The address of the exchange platform where to look for new Silex elements.",
				"value" => "http://www.silexlabs.org",
				"restrict" => "",
				"type" => "string",
				"maxChars" => ""
			)
		);
	}
	
	/*
	Function: getDescription
	Get the status of update of the the server (does it run the latest version?).
	
	Returns:
	The plugin's description string. 
	*/
	public function getDescription()
	{
		require_once ROOTPATH.'cgi/includes/version_editor.php';
		require_once ROOTPATH."plugins/updater/lib/lib_updater.php";
		require_once ROOTPATH."plugins/updater/updaterConsts.php";
		
		$description = "Silex updater plugin<br />/version.xml not found";
		
		if(file_exists(ROOTPATH.'/version.xml'))
		{
			$silexTree = SilexTree::loadVersion(ROOTPATH.'/version.xml', true);
			$currentVersion = $silexTree->version;
		
			// Download the latest version.xml into the local temporary directory
			$request = $this->paramTable[0]['value'] . "update_service.php?file_path=version.xml";
			
			if( downloadFile( $request , 'version.xml' ) )
			{
				$newSilexTree = SilexTree::loadVersion(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . 'version.xml', true);
				$latestVersion = $newSilexTree->version;
					
				if( $latestVersion == $currentVersion )
					$description = "Your server is up to date ($latestVersion)<br />";
				else
					$description = "Silex $latestVersion is avalaible<br /><FONT FACE='Arial' COLOR='#A63E26'><b>Upgrade now!</b></FONT><br /><br />";
			
				// check installed plugins
				if ( $dh = @opendir(ROOTPATH . VERSIONS_DIR_PATH) )
				{
					// List the /versions directory to get the list of the installed items
					$installedItems = array();
					$itemsToUpdate = array();
					// merge local information with online ones
					while ( ( $file = readdir($dh) ) !== false )
					{
						if ( is_dir($file) || $file===".DS_Store" || $file==="Thumbs.db" || $file==="index.php" || $file===".htaccess" )
							continue;
						
						$conf = new silex_config();
						$res = $conf->parseConfig(ROOTPATH . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . $file, 'phparray');        
						$res = $res->toArray();
						$res = $res["root"];
						
						$itemVersionDoc = new DOMDocument();
						$itemVersionDoc->loadXML($res['versionXml']);
						
						$itemSilexElement = SilexElement::fromXML($itemVersionDoc);
						
						$installedItems[$itemSilexElement->id] = array( "version" => $itemSilexElement->version , "file" => $file );
						
						// get and merge with online information
/* //////////////////// MODIF BY LEXA 2011/11/12: do not check plugins updates here for performance reasons

						$onlineItemsDoc = new DOMDocument();
						$onlineItemsDoc->load( $this->paramTable[1]['value'] . "?feed=ep_get_item_info&format=rss2&p=".$itemSilexElement->id );
						
						$node = $onlineItemsDoc->getElementsByTagName('item')->item(0);
						
						$installedItems[$itemSilexElement->id]['itemCurrentVersion'] = $node->getElementsByTagName('_itemCurrentVersion')->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
						
						if($installedItems[$itemSilexElement->id]['version'] != $installedItems[$itemSilexElement->id]['itemCurrentVersion'] )
							$itemsToUpdate[] = $installedItems[$itemSilexElement->id];
						
*/					}
					closedir($dh);
					
					if(count($itemsToUpdate) > 0)
						$description .= count($itemsToUpdate)." updates are available<br /><br />";
					else
						$description .= count($installedItems)." installed items<br /><br />";
				}
			}
			else
			{
				$description = "Silex updater plugin<br />Silex Labs download server is down";
			}
		}
		
		$description .= "<b>Exchange Platform</b><br/>install plugins, layouts, fonts...";
		
		return $description;
	}
	
   	/*
	Function: getAdminPage
	generates the administration page of the updater

	Returns:
	The html code of the administration page of the updater
	*/
	public function getAdminPage($siteName=null)
	{
		$content = "<div class=loading_screen><span class=updater_text>Loading...</span>
					<script type='text/javascript'>
						$('head').append('<link rel=\"stylesheet\" href=\"plugins/".$this->pluginName."/style/".$this->pluginName.".css\" type=\"text/css\">');
						$.post( 'plugins/".$this->pluginName."/updater.php', 
						{
							plugin_name: '".$this->pluginName."',
							update_server_address: '".$this->refactorUrl($this->paramTable[0]['value'])."',
							exchange_platform_address: '".$this->refactorUrl($this->paramTable[1]['value'])."'
						}, function( data ) { $('#".$this->pluginName."').html(data); } );
					</script>";
		
		$result = "<div id='headers_".$this->pluginName."'></div>
				   <div id='".$this->pluginName."'>
						".$content."
				   </div>
				";
		
        return $result;
	}
	
   	/*
	Function: initParameters
	Initialize the plugin's configuration parameters values from web site configuration. If these parameters aren't set yet for the input site configuration, it will keep the default values.  
	This method also ensure that the user doesn't input a directory (for the temp_dir_path parameter) that would create trouble during the update: to be accepted, it must be a directory inside the updater plugin directory but not one already used by the plugin.

	Parameters:
		$siteConf - array containing the site's configuration
	*/
	public function initParameters($siteConf)
	{
		for($i = 0; $i<count($this->paramTable); $i++)
		{
			if( isset( $siteConf[ $this->paramTable[$i]["name"] ] ) )
			{
				if($this->paramTable[$i]["name"] == "temp_dir_path")
				{
					$userChosen = $this->refactorPath( DIRECTORY_SEPARATOR . $siteConf[ $this->paramTable[$i]["name"] ] . DIRECTORY_SEPARATOR );
					$mustBeWithin = DIRECTORY_SEPARATOR . "plugins" . DIRECTORY_SEPARATOR . $this->pluginName . DIRECTORY_SEPARATOR;
					$forbiddenPaths = array( 
						DIRECTORY_SEPARATOR . "plugins" . DIRECTORY_SEPARATOR . $this->pluginName . DIRECTORY_SEPARATOR ,
						DIRECTORY_SEPARATOR . "plugins" . DIRECTORY_SEPARATOR . $this->pluginName . DIRECTORY_SEPARATOR . "img" . DIRECTORY_SEPARATOR ,
						DIRECTORY_SEPARATOR . "plugins" . DIRECTORY_SEPARATOR . $this->pluginName . DIRECTORY_SEPARATOR . "style" . DIRECTORY_SEPARATOR
					);
					if( !is_file($userChosen) && !in_array( $userChosen , $forbiddenPaths ) && !(substr( $userChosen , 0 , strlen($mustBeWithin) ) != $mustBeWithin ) )
						$this->paramTable[$i]["value"] = $userChosen;
				}
				else
				{				
					$this->paramTable[$i]["value"] = $siteConf[ $this->paramTable[$i]["name"] ];
				}
			}
		}
	}
	
	/*
	Function: refactorPath
	refactors a path according to local OS

	Parameters:
		$stringToRefactor - The path to refactor

	Returns:
	The refactored path
	*/
	private function refactorPath($stringToRefactor)
	{
		$refactoredString = str_replace( '/', DIRECTORY_SEPARATOR, $stringToRefactor);
		$refactoredString = str_replace( "\\", DIRECTORY_SEPARATOR, $refactoredString);
		$refactoredString = str_replace ( DIRECTORY_SEPARATOR.DIRECTORY_SEPARATOR , DIRECTORY_SEPARATOR  , $refactoredString );
		$refactoredString = strtolower($refactoredString);
		return $refactoredString;
	}
	
	/*
	Function: refactorUrl
	refactor a url so that it won't contain capital letters and will be encoded

	Parameters:
		$stringToRefactor - The url to refactor.

	Returns:
	The refactored url.
	*/
	private function refactorUrl($stringToRefactor)
	{
		$refactoredString = strtolower($stringToRefactor);
		return urlencode($refactoredString);
	}
}
?>
