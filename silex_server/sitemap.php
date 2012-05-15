<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

// **
// includes
set_include_path(get_include_path() . PATH_SEPARATOR . "./"  . PATH_SEPARATOR . "./cgi/library/");
//require_once 'cgi/includes/silex_search.php';
require_once('cgi/includes/logger.php');
require_once('cgi/includes/server_config.php');
require_once('cgi/includes/file_system_tools.php');
require_once('cgi/includes/site_editor.php');
require_once('framework/hx-seo/php/Boot.class.php');

$logger = new logger('sitemap');
$fst = new file_system_tools();
$siteEditor = new site_editor(); 
$server_config = new server_config();

// **
// create search object
//$silex_search_obj=new silex_search();

// **
// inputs
//Note that we remove tags in order to prevent HTML (and therefor script tags) injection.
if (isset($_GET['id_site']))
	$id_site= strip_tags($_GET['id_site']);
else
	$id_site=$server_config->silex_server_ini['DEFAULT_WEBSITE'];

// build website content folder
$contentFolder=$server_config->getContentFolderForPublication($id_site);
$websiteContentFolder='./'.$contentFolder.$id_site.'/';
// check rights
if ($fst->checkRights($fst->sanitize($websiteContentFolder), constant('file_system_tools::USER_ROLE'), constant('file_system_tools::READ_ACTION')))
{

	// compute url base
	$urlBase=$ROOTURL;

	// compute url base
	// **
	// search
	$websiteConfig = $siteEditor->getWebsiteConfig($id_site);
	//$query=$websiteConfig['CONFIG_START_SECTION'];
	//$res=$silex_search_obj->find($websiteContentFolder.'/',$query);
	//$seoDataHomePage=$siteEditor->getSectionSeoData($id_site, $websiteConfig['CONFIG_START_SECTION'], $linksUrlBase);
}
else{
	$logger->emerg('feed.php no rights to read '.$websiteContentFolder);
	echo 'feed.php no rights to read '.$websiteContentFolder;
	exit(0);
}

//**
// echo rss
//Wed, 12 Dec 2007 16:06:09 +0100
header('Content-Type: text/xml; charset=UTF-8');
//$indexFolder=$server_config->silex_server_ini['CONTENT_FOLDER'].$id_site.'/search_index/';
$siteFolder=$server_config->silex_server_ini['CONTENT_FOLDER'].$id_site;

//if(file_exists($siteFolder.'/calque2.seodata.xml'))

//var_export(org_silex_core_seo_LayerSeo::readLayerSeoModel($siteFolder.'/calque2.seodata.xml', "start/calque2"), FALSE);

//if (is_dir($indexFolder))
// $pubDate=date ('r',filemtime($indexFolder));
//else
//	$pubDate=date ('r');

/**
 * This function gets website's pages seo information to generate sitemap inforamtion (recursive)
 * @modification author: RapH
 * @modification date: 2011-01-28
 * @parameter $id_site: site id
 * @parameter $layerName: name of the layer for which we want seo information to be retrieved
 * @parameter $deeplink: layer's full deeplink
 * @parameter $urlBase: website's url base
 * @parameter $depth: layer depth
 * @parameter $priority: layer priority, used by sitemap
 */
//function getPages($id_site, $layerName, $urlBase, $parentDeeplink='', $depth=0, $priority=1)
function getPagesV2($id_site, $layerName, $deeplink, $urlBase, $depth=0, $priority=1)
{
	$server_config = new server_config();
	$siteFolder=$server_config->silex_server_ini['CONTENT_FOLDER'].$id_site;
	$res = array();

	$thisPageData = array(); //{deeplink, title, priority}
	$thisPageData["deeplink"] = $deeplink;
	$thisPageData["title"] = $layerName;
	$thisPageData["priority"] = $priority;

	//Add this page to $res
	array_push($res, $thisPageData);

	//Now, let's load child pages
	$layer = org_silex_core_seo_LayerSeo::layerSeoModel2PhpArray(org_silex_core_seo_LayerSeo::readLayerSeoModel($siteFolder.'/'.$thisPageData['title'].'.seodata.xml', $deeplink));

	//We have to iterate on each component and then on each link
	if(array_key_exists("components", $layer))
	{
		if(is_array($layer["components"]))
		foreach($layer["components"] as $component)
		{
			if(array_key_exists("links", $component))
			{	
				if(is_array($component["links"]))
				foreach($component["links"] as $link)
				{
					$children = getPagesV2($id_site, $link["link"], $deeplink."/".ltrim($link["deeplink"]), $urlBase, $depth+1, max(0.1, $priority-0.1));

					//Add all children to our array.
					foreach($children as $child)
					{
						array_push($res, $child);
					}
				}
			}
		}
	}

	return $res;
}

function getPagesV1($id_site, $layerName, $urlBase, $parentDeeplink='', $depth=0, $priority=1)
{
	global $siteEditor;

	$layerSeoData = Array();
	$res = Array();
	$layerSeoData = $siteEditor->getSectionSeoData($id_site, $layerName, $urlBase);
	$res[0]=$layerSeoData;
	// Use title stored in parent's page, which has been cleaned by cleanID method, instead of child title which has not been cleaned. Otherwise script can fail as it does not find the correct title.seodata.xml page
	$res[0]["title"]=$layerName;
	$res[0]["priority"]=$priority;
	if(array_key_exists("subLayers", $layerSeoData))
	{
		foreach ($layerSeoData['subLayers'] as $layer) 
		{
			$pages=getPagesV1($id_site, $layer["title"], $urlBase,$layerSeoData['deeplink'],$depth+1,max(0,$priority-0.1));
			foreach ($pages as $page) 
			{
				$res[]=$page;
			}
		}
	}
	return $res;
}


/**
*  This function is a proxy to V1 or V2.
*/
function getPages($id_site, $layerName, $urlBase, $parentDeeplink='', $depth=0, $priority=1)
{
	$server_config = new server_config();
	$siteFolder=$server_config->silex_server_ini['CONTENT_FOLDER'].$id_site;

	$temporaryTitle = explode("/", $layerName);
	$thisPageData["title"] = $temporaryTitle[count($temporaryTitle)-1];

	$seoFilePath = $siteFolder.'/'.$thisPageData['title'].'.seodata.xml';
	// If seo xml exists, get the default deeplink (deeplink='') layer
	if(file_exists($seoFilePath))
	{
		// check if seodata.xml file is v1 or v2
		try
		{
			$layer = org_silex_core_seo_LayerSeo::readXml($seoFilePath, '');
		} catch(Exception $e)
		{
			$layer = null;
		}
		
		// seo xml file is V1 or not recognised as a layer seo file
		if ($layer == null)
		{
			return getPagesV1($id_site, $layerName, $urlBase, $parentDeeplink, $depth, $priority);
		}
		// seo xml file is V2
		else
		{
			return getPagesV2($id_site, $layerName, $layerName, $urlBase, $depth, $priority);
		}
	}
}

echo "<"."?xml version=\"1.0\" encoding=\"UTF-8\""."?>\n";
/**
 * Website's xml sitemap construction
 */
?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<?php
	$pages = getPages($id_site, $websiteConfig['CONFIG_START_SECTION'], $urlBase);
			//print_r('$pages:');
			//print_r($pages);
	foreach ($pages as $page) {
		// Check if page's xml and seodata.xml files are existing. Done to avoid php errors
		if (file_exists($siteFolder . '/' . $page['title'] . '.seodata.xml') && file_exists($siteFolder . '/' . $page['title'] . '.xml'))
		{
		//print_r('-' . $id_site . '-' . $page['titleCleaned'] . '-' . $urlBase . "-\n");
		//print_r($urlBase . '-' . '?/' . '-' . $id_site . '-' . '/' . '--' . $page['deeplink'] .$page['deeplink'] . "-\n");

?>
	<url>
		<loc><?php echo $urlBase.'?/'.$id_site.'/'.$page['deeplink']; ?></loc>
		<lastmod><?php echo date ("Y-m-d",filemtime($siteFolder . '/' . $page['title'] . '.seodata.xml')) ?></lastmod>
		<priority><?php echo $page['priority']?></priority>
	</url>
<?php
		}
	}
?>
</urlset>