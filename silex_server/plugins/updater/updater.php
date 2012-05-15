<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html


File: updater.php
This file contains the actions of the Silex updater plugin. This is the controller of the updater plugin.

Author: 
Thomas Fétiveau (Żabojad)  <http://tofee.fr> or <thomas.fetiveau.tech@gmail.com>
 */

set_include_path(get_include_path() . PATH_SEPARATOR . "../../");
require_once 'rootdir.php';

set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH .'cgi/library/' . PATH_SEPARATOR . ROOTPATH .'cgi/includes/');
require_once 'version_editor.php';
require_once 'LangManager.php';
require_once 'server_config.php';
require_once 'consts.php';
require_once 'logger.php';

require_once "./updaterConsts.php";
require_once "./lib/UpdaterView.php";
require_once "./lib/lib_updater.php";


$logger = new logger("updater.php");


$action = getParameter("action");
if(empty($action))
	$action = "index";

$view = new UpdaterView($action);
$action .= "Action";

// error_log("**** $action ".print_r($_POST,true));
if ($logger) $logger->debug("[UPDATER] $action called with POST params: ".print_r($_POST,true));

if( !function_exists( $action ) )
{
	$action = "errorAction";
	$view->setView("error");
}

// Execute the action
$action();

// Render the view
$view->render();

/*
Function: getParameter
This function makes the updater compatible with both POST and GET methods

Parameters:
	paramName - the name of the param to get from $_POST or $_GET

Returns:
The value of the parameter if it exists in $_POST or $_GET, null otherwise
*/
function getParameter($paramName)
{	
	global $logger;
	
	$param=null;
	
	if(!isset($_POST[$paramName]) && !isset($_GET[$paramName]))
	{
		if ($logger) $logger->debug("[UPDATER] getParameter($paramName) returns null");
		return null;
	}
	
	if(isset($_POST[$paramName]))
		$param = $_POST[$paramName];
		
	if(isset($_GET[$paramName]))
		$param = $_GET[$paramName];
	
	if (TRUE == function_exists('get_magic_quotes_gpc') && 1 == get_magic_quotes_gpc())
	{
		if ($logger) $logger->debug("[UPDATER] getParameter($paramName) returns ".stripslashes($param));
		return stripslashes($param);
	}
	
	if ($logger) $logger->debug("[UPDATER] getParameter($paramName) returns ".$param);
	return $param;
}

/*
Function: indexAction
Default action. Prints a menu with the available actions on the moment: download and install new elements, update installed elements, update Silex server...
*/
function indexAction()
{
	global $view, $logger;
	
	/**************************************//**************************************//**************************************/
	/** Check if newer Silex version available **/
	/**************************************/
	$currentVersion = "unknown";
	if(file_exists(ROOTPATH.'/version.xml'))
	{
		$silexTree = SilexTree::loadVersion(ROOTPATH.'/version.xml', true);
		$currentVersion = $silexTree->version;
	}
	
	// Download the latest version.xml into the local temporary directory
	$updateServerAddress = urldecode(getParameter('update_server_address'));
	$request = $updateServerAddress . "/update_service.php?file_path=version.xml";
	// TODO we could avoid to download it twice but we still have to check if the plateform server works
	if( $testService = downloadFile( $request , 'version.xml' ) )
	{
		$newSilexTree = SilexTree::loadVersion(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . 'version.xml', true);
		$latestVersion = $newSilexTree->version;
	}
	
	$view->latestVersion = $latestVersion;
	$view->testService = $testService;
	$view->currentVersion = $currentVersion;
	$view->update_server_address = $updateServerAddress;
	/**************************************//**************************************//**************************************/
	
	
	/**************************************//**************************************//**************************************/
	/** Check if newer version available for any element installed on the Silex server **/
	/************************************************************************/
	$exchangePlatform = urldecode($_POST['exchange_platform_address']);
	
	// List the /versions directory to get the list of the installed items
	$installedItems = array();
	$itemsToUpdate = array();
	
	if ( $dh = @opendir(ROOTPATH . VERSIONS_DIR_PATH) )
	{
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
			// To do: handle the performance issue here
			$onlineItemsDoc = new DOMDocument();
			$onlineItemsDoc->load( $exchangePlatform . "?feed=ep_get_item_info&format=rss2&p=".$itemSilexElement->id );
			
			$node = $onlineItemsDoc->getElementsByTagName('item')->item(0);
			
			$installedItems[$itemSilexElement->id]['id'] = $node->getElementsByTagName('ID')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['title'] = $node->getElementsByTagName('post_title')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['postContent'] = $node->getElementsByTagName('post_content')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['postDate'] = $node->getElementsByTagName('post_date')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['authorName'] = $node->getElementsByTagName('user_nicename')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['authorUrl'] = $node->getElementsByTagName('user_url')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['authorMail'] = $node->getElementsByTagName('user_email')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['selectedVersions'] = $node->getElementsByTagName('_selectedVersionsArray')->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
			$installedItems[$itemSilexElement->id]['itemCurrentVersion'] = $node->getElementsByTagName('_itemCurrentVersion')->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
			
			// determine which image could be use as a thumb/logo for the item
			if( !empty($node->getElementsByTagName('post_thumbnail')->item(0)->nodeValue) )
				$installedItems[$itemSilexElement->id]['thumb'] = $node->getElementsByTagName('post_thumbnail')->item(0)->nodeValue;
			else if( $node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->length > 0 && !empty($node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->item(0)->nodeValue) )
				$installedItems[$itemSilexElement->id]['thumb'] = $node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
			else
				$installedItems[$itemSilexElement->id]['thumb'] = "plugins/updater/img/update_item.png";
			
			if($installedItems[$itemSilexElement->id]['version'] != $installedItems[$itemSilexElement->id]['itemCurrentVersion'] )
				$itemsToUpdate[] = $installedItems[$itemSilexElement->id];
			
		}
		closedir($dh);
	}
	
	$view->itemsToUpdate = $itemsToUpdate;
	$view->installedItems = $installedItems;
	/**************************************//**************************************//**************************************/
}

/*

*/
function errorAction()
{
	global $view, $logger;
	
	// TODO implement a versatile error action
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////					Actions of "Update Silex Server" controller									///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
	Function: checkRightsSilexServerTreeAction
	- Check READ access rights to allow the update process to parse the Silex tree.
	- And, try to delete the temp_dir (if error, ask to ajust the permissions)
*/
function checkRightsSilexServerTreeAction()
{
	global $view, $logger;
	
	// Delete the temp dir contents
	$tempDirReport = array();
	if( file_exists(ROOTPATH . TEMP_DIR_PATH) )
		delDir( ROOTPATH . TEMP_DIR_PATH, $tempDirReport, true, array('version.xml'));
			
	// Check READ access rights on Silex tree
	$silexTree = new SilexTree(); $rights = array(READ_RIGHTS);
	
	$results = $silexTree->checkRights($rights);
	
	unset($silexTree);
	
	$view->tempDirReport = $tempDirReport;
	$view->results = $results;
}

/*
	STEP 2: 
	- download distant (latest) version.xml (remote service)
	- check each file entry within the old version.xml against the local files (compare SHA1 signatures, have they been modifyied by the user?) so that we know which files have been modifyied by the user
	- check each file entry within the new version.xml against the old version.xml (compare SHA1 signatures, are the local files at their last versions?) so that we know which files are to update/delete.
	- generate pre-update report that tells which files need to be updated and propose the user to solve the eventual file conflicts (file modifyied by the user which need to be updated...)
		= For the files that have been modifyied by the user and that have "updateRequired" to false in new version.xml, print a checkbox to propose to update them or not.
		= For the files that are going to be changed (update or delete), we put a warning, and a bigger one for those which have been modifyied by the user.
*/
function generatePreSilexServerUpdateReportAction()
{
	global $view, $logger;
	
	// check each file entry within the old version.xml against the local files (compare SHA1 signatures) so that we know which files have been modifyied by the user
	$currentSilexTree = SilexTree::createFromFileTree();
	
	$userModifiedFiles = null;
	
	if(file_exists(ROOTPATH . 'version.xml'))
	{
		$oldSilexTree = SilexTree::loadVersion(ROOTPATH . 'version.xml');
		$userModifiedFiles = $oldSilexTree->diffComp($currentSilexTree);
	}
	else
	{
		$oldSilexTree = $currentSilexTree;
	}
	
	// to avoid having too many open files, garbage collect the silex file trees to free some file descriptors
	unset($currentSilexTree);
	
	$newSilexTree = SilexTree::loadVersion(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . 'version.xml');
	$itemsToUpdate = $newSilexTree->diffComp($oldSilexTree);
	
	$itemsToDelete = $oldSilexTree->diffComp($newSilexTree, false);
	
	unset($oldSilexTree);
	unset($newSilexTree);
	
	$view->itemsToUpdate = $itemsToUpdate;
	$view->userModifiedFiles = $userModifiedFiles;
	$view->itemsToDelete = $itemsToDelete;
}

/*
	
	STEP 3: 
	- downloads the files to update within an Ajax loop (period=one file download)
	- create empty directories
	- Generate and print update report
*/
function downloadSilexServerUpdateAction()
{
	global $view, $logger;
		
	$fileListSize = getParameter("file_list_size");
	$deleteListSize = getParameter("delete_list_size");
	$originalFileListSize = getParameter("original_file_list_size");
	$folderListSize = getParameter("folder_list_size");
	
	if(isset($fileListSize)) // TODO should have the possibility to dleete without downloading 
	{
		if($fileListSize > 0)
		{
			$fileUpdate = getParameter($fileListSize."_file_update");
			$filePath = getParameter($fileListSize."_file_path");
			$fileSignature = getParameter($fileListSize."_file_signature");
			
			if(isset($fileUpdate))
			{
				$updateServerAddress = urldecode(getParameter('update_server_address'));
				$request = $updateServerAddress . "/update_service.php?file_path=".urlencode(str_replace( DIRECTORY_SEPARATOR, "/", $filePath));
				
				if( !downloadFile( $request , $filePath, $fileSignature ) )
					$view->signatureMismatch = $filePath;
				else
					$fileListSize--;
			}
		}
		
		if(!isset($view->signatureMismatch) && $fileListSize <= 0)
		{
			// Here we create the empty directories that come with the update
			if(isset($folderListSize))
				for($i=1; $i<=$folderListSize; $i++)
				{
					$folderPath = getParameter($i."_folder_path");
					if(isset($folderPath))
						if( !is_dir(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $folderPath) )
							@mkdir(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $folderPath, 0777, true); // TODO manage mkdir errors
				}
		}
		
		// Keep files information between each download
		$filesInfos = array("original_file_list_size"=>$originalFileListSize, "folder_list_size"=>$folderListSize);
		
		for($i=1; $i<=$originalFileListSize; $i++)
		{
			$filesInfos[$i."_file_path"]=getParameter($i."_file_path");
			$filesInfos[$i."_file_update"]=getParameter($i."_file_update");
			$filesInfos[$i."_file_signature"]=getParameter($i."_file_signature");
		}
		
		for($u=1; $u<=$folderListSize; $u++)
			$filesInfos[$u."_folder_path"]=getParameter($u."_folder_path");

		$filesInfos['file_list_size']=$fileListSize;
		
		if(isset($deleteListSize))
		{
			$filesInfos["delete_list_size"]=$deleteListSize;
			
			for($d=1; $d<=$deleteListSize; $d++)
			{
				$filesInfos[$d."_delete_path"]=getParameter($d."_delete_path");
				$filesInfos[$d."_keep"]=getParameter($d."_keep");
			}
		}
		
		$view->fileListSize = $fileListSize;
		$view->filesInfos = $filesInfos;
		$view->originalFileListSize = $originalFileListSize;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In downloadSilexServerUpdateAction : $fileListSize not set ');
		// TODO redirect to errorAction ?
	}
}

/*

	STEP 5: 
		- check write permissions on files to update
			= if not sufficient permissions, we stop the script and invite the user to adjust the permissions. A button "re-check permissions allow to re-perform step 5 without having to re-perform previous steps
			= if permissions OK, we go to step 6
*/
function checkRightsSilexServerUpdateAction()
{
	global $view, $logger;
	
	$updateRightsReport = array(); $rightsToUpdate = array(WRITE_RIGHTS);
	
	$originalFileListSize = getParameter("original_file_list_size");
	$folderListSize = getParameter("folder_list_size");
	$deleteListSize = getParameter("delete_list_size");
	
	if( isset($originalFileListSize) )
		for($f=1 ; $f<=$originalFileListSize ; $f++)
		{
			$fileUpdate = getParameter($f."_file_update");
			if(isset($fileUpdate))
			{
				$fileModel = new FileModel(getParameter($f."_file_path"));
				$fileModel->checkRights($rightsToUpdate, $updateRightsReport);
			}
		}
	
	if( isset($folderListSize) )
		for($d=1 ; $d<=$folderListSize ; $d++)
		{
			$folderPath = getParameter($d."_folder_path");
			if(isset($folderPath))
			{
				$folderModel = new FolderModel(getParameter($d."_folder_path"));
				$folderModel->checkRights($rightsToUpdate, false, $updateRightsReport);
			}
		}
	
	// Keep files information between each download
	$filesInfos = array("original_file_list_size"=>$originalFileListSize, "folder_list_size"=>$folderListSize);
	
	for($i=1; $i<=$originalFileListSize; $i++)
	{
		$filesInfos[$i."_file_path"]=getParameter($i."_file_path");
		$filesInfos[$i."_file_update"]=getParameter($i."_file_update");
		$filesInfos[$i."_file_signature"]=getParameter($i."_file_signature");
	}
	
	for($u=1; $u<=$folderListSize; $u++)
		$filesInfos[$u."_folder_path"]=getParameter($u."_folder_path");
	
	if(isset($deleteListSize))
	{
		$filesInfos["delete_list_size"]=$deleteListSize;
		
		for($d=1; $d<=$deleteListSize; $d++)
		{
			$filesInfos[$d."_delete_path"]=getParameter($d."_delete_path");
			$filesInfos[$d."_keep"]=getParameter($d."_keep");
		}
	}
	
	$view->filesInfos = $filesInfos;
	$view->updateRightsReport = $updateRightsReport;
}

/*

	STEP 6: 
		- Update the Silex server with the files downloaded within the temporary directory
		- Delete the obsolete files
*/
function updateSilexServerAction()
{
	global $view, $logger;
	
	$deleteListSize = getParameter("delete_list_size");
	
	// Update the Silex server with the downloaded files
	$updateReport = array();
	$destinationPath = ROOTPATH; // . "plugins" . DIRECTORY_SEPARATOR . "updater" . DIRECTORY_SEPARATOR . "updated";  // for dev purposes, not actually update the silex server 
	
	updateDir( ROOTPATH . TEMP_DIR_PATH , $destinationPath, $updateReport );
	
	// deletion of obsolete files
	$deleteReport = array();
	
	if(isset($deleteListSize))
		for($d=1; $d<=$deleteListSize; $d++)
		{
			$currentDeletePath=getParameter($d."_delete_path");
			$currentKeep=getParameter($d."_keep");
			
			if(!isset($currentKeep) && isset($currentDeletePath))
			{
				if(is_dir(ROOTPATH.$currentDeletePath))
					delDir(ROOTPATH.$currentDeletePath, $deleteReport, false);
				else
					delFile(ROOTPATH.$currentDeletePath, $deleteReport);
			}
		}
	
	$view->updateReport = $updateReport;
	$view->deleteReport = $deleteReport;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////					Actions of "Download and install new items" controller								///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*

*/
function installNewItemsAction()
{
	global $view, $logger;
	
	$exchangePlatform = urldecode($_POST['exchange_platform_address']);
	
	$doc = new DOMDocument();
	//if($doc->load( $exchangePlatform . "?feed=ep_child_categories&format=rss2" ))
	if($doc->load( $exchangePlatform . "/feed/ep_child_categories/?format=rss2&cat=5314" ))
	{
		$categories = array();
		foreach ($doc->getElementsByTagName('item') as $node)
		{
			$itemRSS = array ( 
			  'id' => $node->getElementsByTagName('cat_ID')->item(0)->nodeValue,
			  'count' => $node->getElementsByTagName('category_count')->item(0)->nodeValue,
			  'description' => $node->getElementsByTagName('category_description')->item(0)->nodeValue,
			  'name' => $node->getElementsByTagName('cat_name')->item(0)->nodeValue,
			  'nicename' => $node->getElementsByTagName('category_nicename')->item(0)->nodeValue,
			  'parent' => $node->getElementsByTagName('category_parent')->item(0)->nodeValue
			);
			$categories[]=$itemRSS;
		}
		
		$view->categories=$categories;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In installNewItemsAction : cannot load xml data from '.$exchangePlatform.'/feed/ep_child_categories/?format=rss2&cat=5314');
		// TODO manage fatal case
	}
}

/*

*/
function browseCategoryAction()
{
	global $view, $logger;
	
	$currentCategory = getParameter("category");
	
	if(!empty($currentCategory))
	{
		$currentCategory = urldecodeArray(unserialize(stripslashes($currentCategory)));
		$exchangePlatform = urldecode($_POST['exchange_platform_address']);
	
		$catDoc = new DOMDocument();
		if($catDoc->load( $exchangePlatform . "/feed/ep_child_categories/?format=rss2&cat=".$currentCategory['id'] ))
		{
			$categories = array();
			foreach ($catDoc->getElementsByTagName('item') as $node)
			{
				$itemRSS = array ( 
				  'id' => $node->getElementsByTagName('cat_ID')->item(0)->nodeValue,
				  'count' => $node->getElementsByTagName('category_count')->item(0)->nodeValue,
				  'description' => $node->getElementsByTagName('category_description')->item(0)->nodeValue,
				  'name' => $node->getElementsByTagName('cat_name')->item(0)->nodeValue,
				  'nicename' => $node->getElementsByTagName('category_nicename')->item(0)->nodeValue,
				  'parent' => $node->getElementsByTagName('category_parent')->item(0)->nodeValue
				);
				$categories[]=$itemRSS;
			}
			
			$view->categories = $categories;
			$view->browseCatSucceed = true;
			
		} else {
			$view->browseCatSucceed = false;
		}
		
		$itemsPage = getParameter("items_page");
		$postsPerPage = 20;
		if(!isset($itemsPage))
			$itemsPage = 0;
		$itemsDoc = new DOMDocument();
		if($itemsDoc->load( $exchangePlatform . "/feed/ep_posts_in_category/?format=rss2&posts_per_page=".$postsPerPage."&paged=".$itemsPage."&cat=".$currentCategory['id'] ))
		{
			$items = array();
			foreach ($itemsDoc->getElementsByTagName('item') as $node)
			{
				// determine which image could be use as a thumb/logo for the item
				if( !empty($node->getElementsByTagName('post_thumbnail')->item(0)->nodeValue) )
					$itemThumb = $node->getElementsByTagName('post_thumbnail')->item(0)->nodeValue;
				else if( $node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->length > 0 && !empty($node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->item(0)->nodeValue) )
					$itemThumb = $node->getElementsByTagName('post_images')->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
				else
					$itemThumb = "plugins/updater/img/update_item.png";
					
				$itemRSS = array ( 
				  'id' => $node->getElementsByTagName('ID')->item(0)->nodeValue,
				  'title' => $node->getElementsByTagName('post_title')->item(0)->nodeValue,
				  'thumb' => $itemThumb
				);
				$items[]=$itemRSS;
			}
			
			$view->itemsPage = $itemsPage;
			$view->postsPerPage = $postsPerPage;
			$view->nbItems = $itemsDoc->getElementsByTagName('numItemsTotal')->item(0)->nodeValue;
			$view->items = $items;
			$view->browseItemsSucceed = true;
			
		} else {
			$view->browseItemsSucceed = false;
		}
		
		$view->currentCategory=$currentCategory;
		
		if(!$view->browseCatSucceed && !$view->browseItemsSucceed)
		{
			if ($logger) $logger->alert('[CRITICAL ERROR] In browseCategoryAction : item or category browsing failed');
			// TODO manage this fatal case
		}
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In browseCategoryAction : $currentCategory is empty');
		// TODO something
	}
}

/*

*/
function browseItemAction()
{
	global $view, $logger;
	
	$currentCategory = getParameter("category");
	$itemId = getParameter("item_id");
	
	if(!empty($currentCategory) && !empty($itemId))
	{
		$currentCategory = urldecodeArray(unserialize(stripslashes($currentCategory)));
		$exchangePlatform = urldecode($_POST['exchange_platform_address']);
		
		$itemsDoc = new DOMDocument();
		if($itemsDoc->load( $exchangePlatform . "?feed=ep_get_item_info&format=rss2&p=" . $itemId ))
		{
			$itemRSS = null;
			$node = $itemsDoc->getElementsByTagName('item')->item(0);
			
			$itemRSS = array ( 
			  'id' => $node->getElementsByTagName('ID')->item(0)->nodeValue,
			  'title' => $node->getElementsByTagName('post_title')->item(0)->nodeValue,
			  'postContent' => $node->getElementsByTagName('post_content')->item(0)->nodeValue,
			  'postDate' => $node->getElementsByTagName('post_date')->item(0)->nodeValue,
			  'authorName' => $node->getElementsByTagName('user_nicename')->item(0)->nodeValue,
			  'authorUrl' => $node->getElementsByTagName('user_url')->item(0)->nodeValue,
			  'authorMail' => $node->getElementsByTagName('user_email')->item(0)->nodeValue,
			  'platformLink' => $exchangePlatform . '?p=' . $itemId
			);
			
			if($selectedVersionsNode = $node->getElementsByTagName('_selectedVersionsArray'))
			{
				if($selectedVersionsNode->length > 0)
					$itemRSS['selectedVersions'] = $selectedVersionsNode->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
				else
					$itemRSS['selectedVersions'] = "";
			}
			
			if($itemCurrentVersionNode = $node->getElementsByTagName('_itemCurrentVersion') )
			{
				if($itemCurrentVersionNode->length > 0)
					$itemRSS['itemCurrentVersion'] = $itemCurrentVersionNode->item(0)->getElementsByTagName('element')->item(0)->nodeValue;
				else
					$itemRSS['itemCurrentVersion'] = "unknown";
			}
			
			$isInstallable = false;
			$itemVersionData = file_get_contents( $exchangePlatform . '?feed=ep_download&file=version.xml&p=' . $itemId );

			if ( !empty($itemVersionData) ) 
				$isInstallable = true;
			
			$view->isInstallable = $isInstallable;
			$view->item = $itemRSS;
		
		} else {
			if ($logger) $logger->alert('[CRITICAL ERROR] In browseItemAction : cannot load xml data from '.$exchangePlatform.'?feed=ep_get_item_info&format=rss2&p='.$itemId);
			// TODO manage this error case
		}
		
		$view->currentCategory = $currentCategory;
		$view->itemId = $itemId;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In browseItemAction : $currentCategory or $itemId is empty');
		// TODO something
	}
}

/*
	
	TODO vérifier droits avant de tenter d'installer ?
*/
function installNewItemAction()
{
	global $view, $logger;
	
	$currentItem = getParameter("item");
	
	if(!empty($currentItem))
	{
		$currentItem = urldecodeArray(unserialize(stripslashes($currentItem)));
		
		// Download initialization
		// we try first to delete the temp dir if already existing
		$tempDirReport = array();
		if( file_exists(ROOTPATH . TEMP_DIR_PATH) )
			delDir( ROOTPATH . TEMP_DIR_PATH, $tempDirReport, true);
		$view->tempDirReport = $tempDirReport;
			
		if(empty($tempDirReport))
		{
			$view->itemSilexElements=array();
			extractItemAndDependenciesElements( $currentItem['id'], $view->itemSilexElements );
		}
		
		$view->currentItem = $currentItem;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In installNewItemAction : $currentItem is empty');
		// TODO manage this fatal error
	}
}

/*

*/
function extractItemAndDependenciesElements($itemId, &$silexElements=array(), &$dependenciesIds=array())
{
	$exchangePlatform = urldecode($_POST['exchange_platform_address']);
	
	if( $itemVersionData = file_get_contents( $exchangePlatform . '?feed=ep_download&file=version.xml&p=' . $itemId ) )
	{
		$itemVersionDoc = new DOMDocument();
		$itemVersionDoc->loadXML($itemVersionData);
		
		$itemSilexElement = SilexElement::fromXML($itemVersionDoc);
		
		$silexElements[] = $itemSilexElement;
		
		// Here we resolve the dependencies
		foreach($itemSilexElement->dependencies as $dependency)
		{
			if(!in_array($dependency, $dependenciesIds))
			{
				extractItemAndDependenciesElements( $dependency , $silexElements , $dependenciesIds );
			}
		}
		
		// Here we save the item's version file as a randomly-named php config file
		$itemSilexConfig = new silex_config();
		$itemSilexConfig->container->createDirective("versionXml", $itemVersionData);
		
		if(!is_dir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH ))
				if(!@mkdir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH , 0777 , true ))
					exit(1); // TODO manage this fatal error
		
		$versionFileName = generateUniqueFileName(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH, ".php");
		
		$itemSilexConfig->writeConfig(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . 
			$versionFileName , "phparray");
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In extractItemAndDependenciesElements : file_get_contents( '.$exchangePlatform.'?feed=ep_download&file=version.xml&p='.$itemId.' ) failed');
		// TODO ERROR : can't download item, return to error action, we shouldn't continue here
	}
}

/*
	
	TODO vérifier droits avant de tenter d'installer ?
*/
function updateItemAction()
{
	global $view, $logger;
	
	$currentItem = getParameter("item");
	
	if(!empty($currentItem))
	{
		$currentItem = urldecodeArray(unserialize(stripslashes($currentItem)));
		$exchangePlatform = urldecode($_POST['exchange_platform_address']);
		
		// Download initialization
		// we try first to delete the temp dir if already existing
		$tempDirReport = array();
		if( file_exists(ROOTPATH . TEMP_DIR_PATH) )
			delDir( ROOTPATH . TEMP_DIR_PATH, $tempDirReport, true);
		$view->tempDirReport = $tempDirReport;
			
		if(empty($tempDirReport))
			if( $itemVersionData = file_get_contents( $exchangePlatform . '?feed=ep_download&file=version.xml&p=' . $currentItem['id'] ) )
			{
				$silexConfig = new silex_config();
				$res = $silexConfig->parseConfig(ROOTPATH . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . $currentItem['file'] , 'phparray');        
				$res = $res->toArray();
				$res = $res["root"];
				
				$itemVersionDoc = new DOMDocument();
				$itemVersionDoc->loadXML($res['versionXml']);
				
				$oldItemSilexElement = SilexElement::fromXML($itemVersionDoc);
				$userModifiedFiles = $oldItemSilexElement->compToLocalSignatures(ROOTPATH);
				
				$itemVersionDoc->loadXML($itemVersionData);
				$newItemSilexElement = SilexElement::fromXML($itemVersionDoc);
				
				$foldersAndFilesToUpdate = $newItemSilexElement->diffComp($oldItemSilexElement);
				$foldersAndFilesToDelete = $oldItemSilexElement->diffComp($newItemSilexElement, false);
				
				// save the new version file in the temp dir
				$newItemSilexConfig = new silex_config();
				$newItemSilexConfig->container->createDirective("versionXml", $itemVersionData);
				
				if(!is_dir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH ))
						if(!@mkdir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH , 0777 , true ))
							exit(1); // TODO manage this fatal error
				
				$newItemSilexConfig->writeConfig(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . 
					$currentItem['file'] , "phparray");
		
				$view->userModifiedFiles = $userModifiedFiles;
				$view->foldersAndFilesToUpdate = $foldersAndFilesToUpdate;
				$view->foldersAndFilesToDelete = $foldersAndFilesToDelete;
		
			} else {
				if ($logger) $logger->alert('[CRITICAL ERROR] In updateItemAction : file_get_contents( '.$exchangePlatform.'?feed=ep_download&file=version.xml&p='.$currentItem['id'].' ) failed');
				// TODO manage fatal error
			}
	
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In updateItemAction : $currentItem is empty');
		// TODO manage fatal error
	}
	
	$view->currentItem = $currentItem;
}

/*
	
	TODO vérifier droits avant de tenter d'installer ?
*/
function installItemAction()
{
	global $view, $logger;
	
	$currentItem = getParameter("item");
	
	if( !empty($currentItem) || !(empty($fileListSize) && empty($originalFileListSize) && empty($folderListSize) && empty($deleteListSize)) )
	{
		$currentItem = urldecodeArray(unserialize(stripslashes($currentItem)));
		$confInstall = getParameter("conf_install");
			
		$fileListSize = getParameter("file_list_size");
		$originalFileListSize = getParameter("original_file_list_size");
		$folderListSize = getParameter("folder_list_size");
		$deleteListSize = getParameter("delete_list_size");
		
		if(!empty($confInstall))
		{
			$exchangePlatform = urldecode($_POST['exchange_platform_address']);
			
			// Perform download and installation
			if(!empty($fileListSize) && $fileListSize > 0) // download the files
			{
				$nextFile = getParameter($fileListSize."_file_path");
				if( !empty( $nextFile ) )
				{
					$itemId = getParameter($fileListSize."_file_item_id");
					if(!isset($itemId))
						$itemId = $currentItem['id'];

					$request = $exchangePlatform . "?feed=ep_download&p=".$itemId."&file=".urlencode(str_replace( DIRECTORY_SEPARATOR, "/", $nextFile));
					
					if( !downloadFile($request, getParameter($fileListSize."_file_path"), getParameter($fileListSize."_file_signature")) )
						$view->signatureMismatch = getParameter($fileListSize."_file_path");
					else
						$fileListSize--;
				}
			}
			
			if(!isset($view->signatureMismatch) && is_numeric($fileListSize) && $fileListSize <= 0) // finalize the update by creating the empty directories and moving the downloaded item to its final place
			{
				// Here we create the empty directories that come with the update
				for($i=1; $i<=$folderListSize; $i++)
				{
					$nextFolderPath = getParameter($i."_folder_path");
					if( !empty( $nextFolderPath ) )
						if(!is_dir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . getParameter($i."_folder_path") ))
							@mkdir( ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . getParameter($i."_folder_path"), 0777, true );
				}
				
				// move the downloaded files to Silex root dir to finalize the installation
				$updateReport = array();
				$destinationPath = ROOTPATH; // . "plugins" . DIRECTORY_SEPARATOR . "updater" . DIRECTORY_SEPARATOR . "updated"; /* for dev purposes, not actually update the silex server */
				
				updateDir( ROOTPATH . TEMP_DIR_PATH , $destinationPath , $updateReport );
				
				$view->updateReport = $updateReport;
				
				// deletion of obsolete files & folders
				$deleteReport = array();
				for($d=1;$d<=$deleteListSize;$d++)
				{
					$itemToDeleteKeep = getParameter($d."_keep");
					$itemToDeletePath = getParameter($d."_delete_path");
					if(empty($itemToDeleteKeep) && !empty($itemToDeletePath))
					{
						if(is_dir(ROOTPATH.$itemToDeletePath))
							delDir(ROOTPATH.$itemToDeletePath, $deleteReport);
						else
							delFile(ROOTPATH.$itemToDeletePath, $deleteReport);
					}
				}
			}
			
			$view->confInstall = $confInstall;
		}
		
		$filesInfo = array();
		if(!empty($originalFileListSize))
			for($i=1; $i<=$originalFileListSize; $i++)
			{
				$filesInfo[$i."_file_path"]=getParameter($i."_file_path");
				$filesInfo[$i."_file_update"]=getParameter($i."_file_update");
				$filesInfo[$i."_file_signature"]=getParameter($i."_file_signature");
				$fileItemId = getParameter($i."_file_item_id");
				if(isset($fileItemId))
					$filesInfo[$i."_file_item_id"]=$fileItemId;
			}
		
		if(!empty($folderListSize))
			for($u=1; $u<=$folderListSize; $u++)
				$filesInfo[$u."_folder_path"]=getParameter($u."_folder_path");
		
		if(!empty($deleteListSize))
			for($d=1; $d<=$deleteListSize; $d++)
			{
				$filesInfo[$d."_delete_path"]=getParameter($d."_delete_path");
				$filesInfo[$d."_keep"]=getParameter($d."_keep");
			}
		
		$view->fileListSize = $fileListSize;
		$view->originalFileListSize = $originalFileListSize;
		$view->folderListSize = $folderListSize;
		$view->deleteListSize = $deleteListSize;
		$view->filesInfo = $filesInfo;
		
		$view->currentItem = $currentItem;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In installItemAction : initial tests failed ');
		// TODO something
	}
}

/*
	
	TODO vérifier droits avant de tenter de desinstaller ?
*/
function uninstallItemsAction()
{
	global $view, $logger;
	
	$uninstallConf = getParameter("uninstall_conf");
	$installedItems = getParameter("installed_items");
	$itemsChosen = getParameter("items_chosen");
	
	if(isset($installedItems))
	{
		if( $installedItems = unserialize(stripslashes($installedItems)) )
		{
			$installedItems = urldecodeArray($installedItems);
			
			$view->installedItems = $installedItems;
			
			if(isset($itemsChosen)) // list files of chosen items
			{
				$originalSilexTree = SilexTree::loadVersion(ROOTPATH . 'version.xml');
				
				$itemsToDelete = array(); // the files and folders to delete
				$chosenItems = array(); // the ids of the elements to delete
				
				for($i=1; $i<=count($installedItems); $i++)
				{
					$itemId = getParameter($i."_to_uninstall");
					
					if(isset($itemId))
					{
						$chosenItems[] = $itemId;
						
						$conf = new silex_config();
						$res = $conf->parseConfig( ROOTPATH . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . $installedItems[$itemId]["file"] , 'phparray' );        
						$res = $res->toArray();
						$res = $res["root"];
						
						$itemVersionDoc = new DOMDocument();
						$itemVersionDoc->loadXML($res['versionXml']);
						
						$itemSilexElement = SilexElement::fromXML($itemVersionDoc);
						
						$itemsToDelete = array_merge( $itemsToDelete , $itemSilexElement->diffComp($originalSilexTree, false) );
						
						$itemsToDelete[] = new FileModel(DIRECTORY_SEPARATOR . VERSIONS_DIR_PATH . DIRECTORY_SEPARATOR . $installedItems[$itemId]["file"]); // we also delete the version file of each item to delete
					}
				}
				
				$view->chosenItems = $chosenItems;
				$view->itemsToDelete = $itemsToDelete;
			}
			
			if(isset($uninstallConf)) // delete files and folders
			{
				$itemsToDelete = getParameter("items_to_delete");
				
				if(isset($itemsToDelete) && $itemsToDelete = unserialize(stripslashes($itemsToDelete)))
				{
					$itemsToDelete = urldecodeArray($itemsToDelete);
					$deleteReport = array();
					
					foreach($itemsToDelete as $itemToDelete)
					{
						if( is_dir( ROOTPATH . $itemToDelete ) )
							delDir( ROOTPATH . $itemToDelete , $deleteReport, false);
						else
							delFile( ROOTPATH . $itemToDelete , $deleteReport);
					}
					
					$chosenItems = getParameter("chosen_items");
					
					if(empty($deleteReport) && isset($chosenItems))
					{
						$chosenItems = urldecodeArray(unserialize(stripslashes($chosenItems)));
						foreach($chosenItems as $chosenItem)
							unset($installedItems[$chosenItem]);
					}
					
					$view->deleteReport = $deleteReport;
					
				} else {
					if ($logger) $logger->alert('[CRITICAL ERROR] In uninstallItemsAction : $itemsToDelete not set or cannot unserialize $itemsToDelete');
					// TODO manage this problematic case
				}
			}
			
		} else {
			if ($logger) $logger->alert('[CRITICAL ERROR] In uninstallItemsAction : cannot unserialize $installedItems');
			//TODO manage unserialization errors
		}
		
		$view->installedItems = $installedItems;
		$view->uninstallConf = $uninstallConf;
		$view->itemsChosen = $itemsChosen;
		
	} else {
		if ($logger) $logger->alert('[CRITICAL ERROR] In uninstallItemsAction : $installedItems not set ');
		//TODO manage critical error
	}
}

?>
