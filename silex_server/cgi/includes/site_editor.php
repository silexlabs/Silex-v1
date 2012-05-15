<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	// Loads class which contains seo haxe project
	// if silex index haxe class is already loaded, load the corresponding library using haxe method php_Lib::loadLib
	if (class_exists('php_Lib'))
		//php_Lib::loadLib("C:\wamp\www\silex_trunk_branch_dev_seo\silex_server/framework/hx-seo");
		php_Lib::loadLib(ROOTPATH . "framework/hx-seo");
	// if not (direct access from the client or the server), load the corresponding library using native php method
	else {
		//require_once("../../framework/hx-seo/lib/php/Boot.class.php");
		require_once("framework/hx-seo/php/Boot.class.php");
	}
	
	//class to edit site data
	require_once("logger.php");
	require_once("server_config.php");
	require_once("file_system_tools.php");
	//require_once("silex_search.php");
	
	define("ACTION_DUPLICATE", "duplicate");
	define("ACTION_RENAME", "rename");
	define("ACTION_DELETE", "delete");
	define("ACTION_CREATE", "create");
	
	/**
	 * name of the XML file which contains the structure of the publication
	 */
	define("STRUCTURE_FILE_NAME", "structure.xml");
	/**
	 * name of the XML file which contains the structure of the publication, once published, i.e. without the deactivated pages
	 */
	define("PUBLISHED_STRUCTURE_FILE_NAME", "structure.published.xml");
	
	class site_editor{


		var $logger = null;
		var $fst = null;		
		var $server_config = null;
		const DEFAULT_WEBSITE_CONF_FILE = "default_website_conf.txt";
		const seoDataFilesExtension = ".seodata.xml";

		//This is going to be used only if DOMDocument is not available
		var $stack = array(); //Type : Hash<{name : String, attribs : Hash<String>}>
		
		//Arrays used by getSeoSectionData
		var $titles = array();
		var $htmlEquivalents = array();
		var $links = array();
		var $subLayers = array();
		var $tags = array();
		var $descriptions = array();
		var $urlBase = "";
		var $deeplinkPage = "";
		var $newLink = null;
		var $titleFilled = 'false';
		
		//var $haxe = null;
		
		function site_editor(){
			$this->fst = new file_system_tools();
			$this->logger = new logger("site_editor");
			$this->server_config = new server_config();
		
			//Main::main();
			//org_silex_core_seo_LayerSeo::writetest('contents/test_connector/writetest.xml');
			//if (!class_exists('php_Lib')) {
				
				//$this->haxe = new php_Boot();
			//}
			
		}

		function xml_parsing_start($parser, $name, $attribs)
		{
			// Put the xml parser in the stack
			array_push($this->stack, array("name" => $name, "attribs" => $attribs));
			
			// In case parser is corresponding to sublayer information, create newLink
			// Following line is here to avoid errors
			if(count($this->stack) >= 2)
			{
				//if grand-parent attribute name is "links", create newLink
				if($this->stack[count($this->stack)-2]["attribs"]["name_str"]=="links")
				{
					//We are beginning a new link
					$this->newLink = array("title" => "", "deeplink" => "");
				}
			}
		}
		
		function xml_character_data($parser, $data)
		{
			// Set $lastEl & $beforeLastEl counters
			$lastEl = $this->stack[count($this->stack)-1];
			$beforeLastEl = $this->stack[count($this->stack)-2];
			//echo("xml_character_data en cours - attribut: " . $lastEl["attribs"]["name_str"] . " - data: " . $data . "\n");
			
			// Test xml node values and stores them in class variables
			//Is it deeplink?
			if($lastEl["name"] == "element" && $lastEl["attribs"]["name_str"] == "deeplink")
			{
				$this->deeplinkPage = $data;
			}
			//Is it title? ("/element[@name_str='root']/element[@name_str='title']")
			if($lastEl["name"]=="element" && $lastEl["attribs"]["name_str"] == "title" && $beforeLastEl["attribs"]["name_str"]=="root")
			{
				array_push($this->titles, $data);
			}
			
			//is it description? ("//element[@name_str='description']")
			if($lastEl["name"]=="element" && $lastEl["attribs"]["name_str"]=="description")
			{
				array_push($this->descriptions, $data);
			}
			
			//Is tags? ("//element[@name_str='tags']/element[@type_str='string']")
			if($lastEl["name"]=="element" && $lastEl["attribs"]["type_str"] == "string" && $beforeLastEl["name"]=="element" && $beforeLastEl["attribs"]["name_str"]=="tags")
			{
				array_push($this->tags, $data);
			}
			
			//Is it HTMLEquivalent? ("/element/element[@name_str='content']/element/element[@name_str='htmlEquivalent']")
			if($lastEl["name"]=="element" && $lastEl["attribs"]["name_str"]=="htmlEquivalent")
			{
				array_push($this->htmlEquivalents, preg_replace('/\[\[open:([^\]\|]*)\|([^\]\|]*)\]\]/','<a href="'.$this->urlBase.$this->deeplinkPage.'/'.'\1">\2</a>', $data));
			}
			
			//Is it a sublayer? 
			// In case parser is corresponding to sublayer information (cf. xml_parsing_start), fill newLink
			if($this->newLink != null)
			{
				// Fill sublayer title information
				if($lastEl["attribs"]["name_str"] == "title")
				{
					$this->newLink["title"] = $data;
				}
				// Fill sublayer deeplink information
				else if($lastEl["attribs"]["name_str"] == "link")
				{
					$this->newLink["deeplink"] = $data;
				}
			}
		}
		
		function xml_parsing_end($parser, $name)
		{
			// In case sublayer title information is already existing, fill deeplink if existing, push sublayer and reset it
			if ($this->titleFilled == 'true')
			{
				//print_r($this->newLink);
				// In case no deeplink is defined, use page title as deeplink
				if ($this->newLink["deeplink"] != null) {
					$subLayerDeeplink = $this->newLink["deeplink"];
				} else {
					$subLayerDeeplink = $this->newLink["title"];
				}
				array_push($this->subLayers, $this->newLink);
				array_push($this->links, '<A HREF="'.$this->urlBase.$this->deeplinkPage.'/'.$subLayerDeeplink.'">'.$this->newLink["title"].'</A>');
				// Reset newLink containing sublayer information
				$this->newLink = null;
				$this->titleFilled = 'false';
			}
			// In case newLink has been filled with sublayer title information, set $this->titleFilled to true 
			if ($this->newLink["title"] != null) {
				$this->titleFilled = 'true';
			}
			array_pop($this->stack);	
		}

		/**
		*  Find and return a page's SEO information.
		*  Depending on the version of the start seo file, calls getSectionSeoDataV1 or getSectionSeoDataV2
		*  Assumption is that all seo files should be the same format than start page
		*
		*  @param $id_site: Id of the Website
		*  @param $deeplink Either the full deeplink of the layer (used by SilexIndex.hx), either the layer title (used by sitemap.php)
		*  @param $urlBase: Website's base URL 
		*  @return: hash("title", "deeplink", "htmlEquivalent", "links", "subLayers", "tags", "description")
		*/
		function getSectionSeoData($id_site, $deeplink, $urlBase = "")
		{
			//print_r('-' . $id_site . '-' . $deeplink . '-' . $urlBase);
			$path = ROOTPATH . $this->server_config->getContentFolderForPublication($id_site);
			$websiteContentFolderPath = "$path$id_site/";
			
			//Get the list of "layers" from the deeplink and iterate over them
			$layers = preg_split("/\//", $deeplink);
			$layerCleanID = $layers[0];
			
			$pageSeoData = Array();
			
			// build layer seo file path
			$seoFilePath = $websiteContentFolderPath . $layerCleanID . self::seoDataFilesExtension;
						
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
					$pageSeoData = $this->getSectionSeoDataV1($id_site,$deeplink,$urlBase);
				}
				// seo xml file is V2
				else
				{
					$pageSeoData = org_silex_core_seo_Utils::getPageSeoDataAsPhpArray($id_site, $deeplink, $urlBase);
				}
			}
			
			return $pageSeoData;
		}
	
		/**
		*  Find and return a page's SEO information. 
		*  @param $id_site: Id of the Website
		*  @param $deeplink Either the full deeplink of the layer (used by SilexIndex.hx), either the layer title (used by sitemap.php)
		*  @param $urlBase: Website's base URL 
		*  @return: hash("title", "deeplink", "htmlEquivalent", "links", "subLayers", "tags", "description")
		*/
		function getSectionSeoDataV1($id_site,$deeplink,$urlBase=""){
	
			//if ($this->logger) $this->logger->debug("getSectionSeoData($id_site,$layerName,$urlBase)");
			
			// Set urlBase values 
			$this->urlBase = $urlBase;
			
			// Create/reset the array to be returned (and all the hashes)
			$toReturn = array();
			$toReturn["title"]="";
			$toReturn["deeplink"]="";
			$toReturn["description"] = "";
			$toReturn["tags"] = "";
			$toReturn["htmlEquivalent"] = "";
			$toReturn["links"] = "";
			
			// Create/reset Temporary variables used to ease the retrieval and formating of datas
			$this->titles = array();
			$this->deeplinkPage = "";
			$this->htmlEquivalents = array();
			$this->links = array();
			$this->subLayers = array();
			$this->tags = array();
			$this->descriptions = array();
			
			//Get the list of "layers"(here called pages) from the deeplink and iterate over them
			$pages = preg_split("/\//", $deeplink);
			$layerCleanID = $pages[0];
			for($i=0; $i<count($pages); $i++)
			{
				for ($j=0; $j<count($this->subLayers); $j++)
				{
					if ($this->subLayers[$j]['deeplink'] != '') {
						$pageSeoDeeplink = $this->subLayers[$j]['deeplink'];
					}
					else {
						$pageSeoDeeplink = $this->subLayers[$j]['title'];
					}
					if ($pages[$i] == $pageSeoDeeplink) {
						$layerCleanID = $this->subLayers[$j]['title'];
					}
				}
						
				// Construct xml's path
				$xmlPath = ROOTPATH.$this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site."/".$layerCleanID.self::seoDataFilesExtension;

				// If xml exists, parse it
				if(file_exists($xmlPath))
				{
					// Create xml parser
					$xmlParser = xml_parser_create();
					// Set xml parse options
					xml_parser_set_option($xmlParser, XML_OPTION_CASE_FOLDING, "UTF-8");
					// Set up start and end handlers
					xml_set_element_handler($xmlParser, array($this, "xml_parsing_start"), array($this,"xml_parsing_end"));
					// Set up character handler 
					xml_set_character_data_handler($xmlParser, array($this,"xml_character_data"));
					
					$fp = fopen($xmlPath, "r");
					
					// check if seo file is v2 format
					//$fileContent = fread($fp, 50);
					//print_r($fileContent);
					
					// takes only 2MB of the file, to limit the memory usage if file is too big.
					while ($fdata = fread($fp, 2048))
					{
						// check if seo file is not v2 format (i.e. v1 format), otherwise creates an error
						if (strpos($fdata, '<seoData version="2">') == false)
						{
							xml_parse($xmlParser, $fdata, feof($fp));
							/*xml_parse($xmlParser, $fdata, feof($fp)) or die(
							sprintf("Erreur XML : %s à la ligne %d\n",
							xml_error_string(xml_get_error_code($xmlParser)),
							xml_get_current_line_number($xmlParser))
							);*/
						}
					}
					
				}	
			}

			//Format and put data from temporary variables to the array to be returned
			$toReturn["title"] = implode(" - ",$this->titles);
			$toReturn["deeplink"] = urldecode($this->deeplinkPage);
			$toReturn["htmlEquivalent"] = urldecode(implode("",$this->htmlEquivalents));
			// Format links as html links within html list
			if (isset($this->links[0])) {
				$toReturn["links"] = "<ul><li>" . urldecode(implode("</li><li>", $this->links)) . "</li></ul>";
				}
			$toReturn["subLayers"] = $this->subLayers;
			$toReturn["tags"] = implode(",",$this->tags);
			$toReturn["description"] = htmlentities(urldecode(implode("", $this->descriptions)));
			//print_r("getSectionSeoData\n");
			//print_r($toReturn);
			//print_r("\n\n");

			if ($this->logger) $this->logger->debug(print_r($toReturn,true));
			return $toReturn;
		}
		
		// **
		// write xml data into a file
		function writeSectionData($xmlData, $xmlFileName,$sectionName, $id_site, $seoObject='', $domObject=null)
		{
			if ($this->logger) $this->logger->debug("writeSectionData($xmlData, $xmlFileName,$sectionName, $id_site,$seoObject)");
			if ($this->logger) $this->logger->debug(print_r($seoObject,true));
			
			$path = ROOTPATH . $this->server_config->getContentFolderForPublication($id_site);
			// check rights
			if ($this->fst->checkRights($this->fst->sanitize($path),file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION)){
				if ($this->logger) $this->logger->debug("writeSectionData rights OK, call fopen:".$path.$xmlFileName);
				//  open file
				$fileHandle=fopen($path."/".$xmlFileName,"w");
				if (!$fileHandle){
					if ($this->logger) $this->logger->debug("writeSectionData error opening file ".$fileHandle);
					return "error opening file ".$fileHandle;
				}
				if ($this->logger) $this->logger->debug("writeSectionData open ok (".$path."/".$xmlFileName.")");

				// add UTF-8 header
				$xmlData="\xEF\xBB\xBF".$xmlData; 

				// write data
				if (!fputs ($fileHandle,$xmlData)){
					if ($this->logger) $this->logger->emerg("writeSectionData error writing to file ".$fileHandle);
					return "error writing to file ".$fileHandle;
				}
				if ($this->logger) $this->logger->debug("writeSectionData close ok");

				// close
				fclose($fileHandle);

				// deprecated, remove AMF FORMAT
					// retrieve file extension
					$amfExt = '.amf';
					if (isset($this->server_config->silex_client_ini["AMF_FILE_EXTENSION"]))
						$amfExt = $this->server_config->silex_client_ini["AMF_FILE_EXTENSION"];
					// build file name
					$amfFileName = $path."/".$id_site."/".$sectionName.$amfExt;
					//  remove file
					if (is_file($amfFileName))
						unlink($amfFileName);
				
				// write data AMF FORMAT
/*				if (isset($domObject))
				{
					include_once("../amf-core/io/AMFSerializer.php");
					include_once("../amf-core/util/AMFHeader.php");
					include_once("../amf-core/util/AMFBody.php");
					include_once("../amf-core/util/AMFObject.php");
					$amfSerializer = new AMFSerializer();
					$amfObject = new AMFObject($domObject);
					//$amfObject->outputStream = $domObject;
					$amfBody = new AMFBody('',"/1","onResult");
					$amfBody->setResults($domObject);
					$amfObject->addBody($amfBody);
					$outHeader = new AMFHeader("AppendToGatewayUrl", false, "?" . ini_get('session.name') . "=" . $session_id);
					$amfObject->addOutgoingHeader($outHeader);
					$amfData = $amfSerializer->serialize($amfObject);
					
					// retrieve file extension
					$amfExt = '.amf';
					if (isset($this->server_config->silex_client_ini["AMF_FILE_EXTENSION"]))
						$amfExt = $this->server_config->silex_client_ini["AMF_FILE_EXTENSION"];
					// build file name
					$fileHandle=fopen($path."/".$id_site."/".$sectionName.$amfExt,"w");
					//  open file
					if (!$fileHandle){
						if ($this->logger) $this->logger->debug("writeSectionData error opening file ".$fileHandle);
						return "error opening file ".$fileHandle;
					}
					if ($this->logger) $this->logger->debug("writeSectionData open ok (".$path."/".$id_site."/".$sectionName.'.amf'.")");

					// write data
					if (!fputs ($fileHandle,$amfData)){
						if ($this->logger) $this->logger->emerg("writeSectionData error writing to file ".$fileHandle);
						return "error writing to file ".$fileHandle;
					}
					if ($this->logger) $this->logger->debug("writeSectionData close ok");

					// close
					fclose($fileHandle);
				}
*/				if ($sectionName && $seoObject)
					return $this->storeSeoData("$path/$id_site/",$sectionName,$seoObject);
				else
					return '';
			}
			else{
				if ($this->logger) $this->logger->emerg("writeSectionData no rights to write data : $xmlFileName, $sectionName, $id_site, $seoObject");
				return "no rights to write data : $xmlFileName, $sectionName, $id_site, $seoObject";
			}
			return '';
		}

		/**
		 * Stores layer seo data into layer.seodata.xml
		 * 
		 * @inputs	website content folder path, section name (= layer clean id), seo object
		 * @return	'' if there is no error, or error message otherwise
		 */
		function storeSeoData($websiteContentFolderPath,$sectionName,$seoObject){
			if ($this->logger) $this->logger->debug("seoObject:" . print_r($seoObject,true));
			//if ($this->logger) $this->logger->debug("silex_search.php storeSeoData($websiteContentFolderPath,$sectionName,".print_r($seoObject,true).") ");
			
			///////////////////////////////////////////////////////////
			// write V2 seo file using php script generated via Haxe //
			///////////////////////////////////////////////////////////

			// store html data in xml file
			// build seo file name
			$seoFileName = $websiteContentFolderPath . $sectionName . self::seoDataFilesExtension;
			//if ($this->logger) $this->logger->debug("silex_search.php storeSeoData open file: $seoFileName");
	
			// get indent config parameter
			if(array_key_exists("INDENT_LAYER_XML_FILE", $this->server_config->silex_server_ini))
				$indent = strtolower($this->server_config->silex_server_ini["INDENT_LAYER_XML_FILE"]);
			else
				$indent = true;
			
			// write V2 seo file using Haxe generated script
			org_silex_core_seo_LayerSeo::write($seoFileName, '', $seoObject, $indent);
			
			///////////////////////////////////////////////////
			// write V1 seo file using php script - OBSOLETE //
			///////////////////////////////////////////////////
			// open seo file
			/*$xmlFile=@fopen($seoFileName,"w");
			if (!$xmlFile) return "error opening file ".$seoFileName." - Section data was saved anyway";
	
			// build xml data
			$seoData_xml = arrayToXML($seoObject);
			
			// write xml data
			if ($seoData_xml){
				// add UTF-8 header
				$seoData_xml="\xEF\xBB\xBF".$seoData_xml; 
				if (!fputs($xmlFile,$seoData_xml)) return "error writing to file ".$seoFileName." - Section data was saved anyway";
			}
			// close seo file
			fclose($xmlFile);*/
	
			// generate the index
			//if ($this->silex_server_ini["AUTOMATIC_INDEX_CREATION_ON_SAVE"]=="true")
			//	$this->createIndex($websiteContentFolderPath,$startSectionName);
			return '';
		}
		
		/**
		* select files corresponding to $oldSectionName and do an action on it<br />
		* selection is oldSectionName.xml, oldSectionName.seodata.xml, oldSectionName.amf.php, oldSectionName.jpg, oldSectionName.png
		* private, puts code in common for rename and duplicate section<br />
		* does nothing if the section or site doesn't exist<br />
		* @example	call renameSection("start", "cv") renames all files that fit the pattern start.* to cv.*
		*/		
		function operateSection($siteName, $oldSectionName, $newSectionName, $action){
			$this->logger->debug("operateSection($siteName, $oldSectionName, $newSectionName)");
			$siteFolderPath = ROOTPATH . $this->server_config->getContentFolderForPublication($siteName) . $siteName . "/";
			$filesToRename = Array();
			if ($handle = opendir($siteFolderPath)) {
				while (false !== ($file = readdir($handle))) {
					if($file == "$oldSectionName.xml" || $file == "$oldSectionName.seodata.xml" || $file == "$oldSectionName.png" || $file == "$oldSectionName.jpg" || $file == "$oldSectionName.amf.php"){
						array_push($filesToRename, $file);
					}
				}
				closedir($handle);
			}		
			foreach($filesToRename as $fileName){
				$sanitizedFilePath = $this->fst->sanitize($siteFolderPath . $fileName);
				if ($this->fst->checkRights($sanitizedFilePath, file_system_tools::ADMIN_ROLE, file_system_tools::WRITE_ACTION)){
					//note if duplicate should only need read, but too complicated for now. @Todo A.S.K.
					$newFileName = str_replace($oldSectionName, $newSectionName, $fileName);
					if(file_exists($siteFolderPath . $newFileName)){
						$this->logger->err("$siteFolderPath/$newFileName already exists");
						// throw new Exception("$siteFolderPath/$newFileName already exists");
						return "$siteFolderPath/$newFileName already exists";
					}else{
						switch ($action){
							case ACTION_RENAME:
								if (!rename($siteFolderPath . $fileName, $siteFolderPath . $newFileName))
									return "impossible to rename $siteFolderPath$fileName in $siteFolderPath$newFileName";
								break;
							case ACTION_DUPLICATE:
								if(!copy($siteFolderPath . $fileName, $siteFolderPath . $newFileName))
									return "impossible to copy $siteFolderPath$fileName in $siteFolderPath$newFileName";
								break;
							case ACTION_DELETE:
								if(!unlink($siteFolderPath . $fileName))
									return "impossible to delete $siteFolderPath$fileName";
								break;
//							case ACTION_CREATE:
//								$this->writeSectionData('<xml />', "$siteName/$newSectionName",'', '');
//								break;
						}
						$this->logger->debug($action . " $siteName/$fileName to $siteName/$newFileName");
					}
				}else{
					$this->logger->err("modifying $siteFolderPath/$fileName not allowed");
					return "modifying $siteFolderPath/$fileName not allowed";
				}
			}
			return "";
		}
		/**
		 * rename a page and its preview
		 */
		function renameSection($siteName, $oldSectionName, $newSectionName){
			return $this->operateSection($siteName, $oldSectionName, $newSectionName, ACTION_RENAME);
		}
		/**
		 * Duplicate a page<br/>
		 * duplicate the preview of the page if there is one (jpg or png)
		 */
		function duplicateSection($siteName, $oldSectionName, $newSectionName){
			return $this->operateSection($siteName, $oldSectionName, $newSectionName, ACTION_DUPLICATE);
		}
		/**
		 * create an empty xml file or duplicate from existing template
		 */
		function createSection($siteName, $newSectionName){	
//			$this->operateSection($siteName, $newSectionName, $newSectionName, ACTION_CREATE);
			
			$xmlData = '';
			$xmlFileName = $newSectionName.'.xml';
			$path = ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"]."$siteName/";
			// check rights
			if ($this->fst->checkRights($this->fst->sanitize($path),file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION)){
				if ($this->logger) $this->logger->debug("createSection rights OK, call fopen:".$path.$xmlFileName);
				
				if (!is_file ($path."/".$xmlFileName)){
					//  open file
					$fileHandle=fopen($path."/".$xmlFileName,"w");
					if (!$fileHandle){
						if ($this->logger) $this->logger->debug("createSection error opening file ".$fileHandle);
						return "error opening file ".$fileHandle;
					}
					if ($this->logger) $this->logger->debug("createSection open ok (".$path."/".$xmlFileName.")");
	
					// write data
					if (!fputs ($fileHandle,$xmlData)){
						if ($this->logger) $this->logger->emerg("createSection error writing to file ".$fileHandle);
						return "error writing to file ".$fileHandle;
					}
					if ($this->logger) $this->logger->debug("createSection close ok");
	
					// close
					fclose($fileHandle);
				}
			}
		}
		/**
		 * delete a page<br />
		 * delete the preview of the page if there is one (jpg or png)
		 */
		function deleteSection($siteName, $sectionName){
			$this->operateSection($siteName, $sectionName, NULL, ACTION_DELETE);
		}
		/**
		 * save the structure of the publication
		 * usually XML data comes from the PublicationStructureEditor (flex) directly
		 * save a .draft.xml (structure with the deactivated pages) and a .xml (structure without the deactivated pages)
		 * @return	'' if there is no error - the error message otherwise
		 */
		function savePublicationStructure($siteName, $xmlContent, $xmlContentPublished){	
			if ($this->logger) $this->logger->debug("savePublicationStructure($siteName, xmlContent, xmlContentPublished)");
			
			$path = ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$siteName.'/';
			// check rights
			$folder = $this->fst->sanitize($path, TRUE);
			if ($this->fst->checkRights($folder,file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION)){
				if ($this->logger) $this->logger->debug("savePublicationStructure rights OK");
				// write data to file
				$errmsg = $this->fst->writeToFile ($path . STRUCTURE_FILE_NAME, $xmlContent);
				if ($errmsg != '') $errmsg .= " - ";
				// write data to file
				$errmsg .= $this->fst->writeToFile ($path . PUBLISHED_STRUCTURE_FILE_NAME, $xmlContentPublished);
				if ($errmsg != '')
					return '<ps error="true" errorMsg="Error: can not write to file ('.$errmsg.')" />';
				else
					return '<ps error="false" />';
			}
			return '<ps error="true" errorMsg="Permission denied (write '.$path.')" />';
		}
		/**
		 * returns the .xml corresponding to the structure of the given publcation (with the deactivated pages)
		 */
		function loadPublicationStructure($siteName,$isPublishedVersion = FALSE){
			// build path
			$filename = ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"] . $siteName . '/';
			// choose version of file 
			if ($isPublishedVersion == FALSE)
				$filename .= STRUCTURE_FILE_NAME;
			else
				$filename .= PUBLISHED_STRUCTURE_FILE_NAME;
			
			$folder = $this->fst->sanitize($filename, TRUE);
			//
			if ($this->fst->checkRights($folder,file_system_tools::USER_ROLE,file_system_tools::READ_ACTION)){
				if (is_file($filename)){
					// open file
					$handle = fopen($filename, "r");
					if (!$handle){
						if ($this->logger) $this->logger->debug("loadPublicationStructure error opening file : $fileName");
						return '<ps error="true" errorMsg="Error: can not open file '.$filename.'" />';
					}
					// return content
					if(filesize($filename) >0)
						return fread($handle, filesize($filename));
					else
						return "";
				}
				return '<ps error="true" creation="true" errorMsg="Error: can not open file '.$filename.'" />';
			}
			return '<ps error="true" errorMsg="Permission denied (read '.$filename.')" />';
		}
					
		//todo : get rid of this function
		function parse_client_side_ini_file($filePath){
			// check rights
			$res = null;
			if ($this->fst->checkRights($this->fst->sanitize($filePath),file_system_tools::USER_ROLE,file_system_tools::READ_ACTION)){
				$conf = new silex_config;
				$res = $conf->parseConfig($filePath, 'flashvars');        
				$res = $res->toArray();
				$res = $res["root"];
			}
			else{
				if ($this->logger) $this->logger->emerg("parse_client_side_ini_file no rights to read $filePath");
			}		
			return $res;
		}
					
		function getWebsiteConfig($id_site,$mergeWithServerConfig=false){
			if ($this->logger) $this->logger->debug("getWebsiteConfig, id_site : $id_site"); 

			$filePath=ROOTPATH . $this->server_config->getContentFolderForPublication($id_site).$id_site."/".$this->server_config->silex_server_ini["WEBSITE_CONF_FILE"];
			if ($this->logger) $this->logger->debug("getWebsiteConfig - file path = $filePath"); 

			$res=$this->parse_client_side_ini_file($filePath);
			if ($this->logger) $this->logger->debug("getWebsiteConfig returns ".print_r($res,true)); 
			
			if ($mergeWithServerConfig==true)
			{
				try
				{
					$res = array_merge($res,$this->silex_client_ini,$this->server_config->silex_server_ini);
				}
				catch (Exception $e) 
				{
					//var_dump($e->getTrace());
				}
			}
			
			return $res;
		}		
		
		/** 
		 * delete a website
		 */
		function deleteWebsite($id_site){
			$id_site = str_replace(array('/', '\\'), '', htmlentities(strip_tags($id_site)));
			$path=ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site;

			if ($this->logger) $this->logger->debug("writeWebsiteConfig delete website (data empty) ".$path." renamed -> ".ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_deleted_".date('Y-m-d_H-i-s'));

			return rename($path,ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_deleted_".date('Y-m-d_H-i-s'));
		}
		/** 
		 * create a website
		 */
		function createWebsite($id_site)
		{
			// sanitize
			$id_site = str_replace(array('/', '\\'), '', htmlentities(strip_tags($id_site)));
			$path = ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site;
			if ($this->logger) $this->logger->debug("createWebsite ".$id_site);
			if (is_dir($path))
				return false;
			else
			{
				// **
				// website creation
				if(!mkdir($path, 0755)){
					throw new Exception("couldn't create folder at $path");
				}
				if ($this->logger) $this->logger->info("createWebsite mkdir(".$path.")");
				// check rights
				if ($this->fst->checkRights($this->fst->sanitize($path),file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION))
				{
					$source = ROOTPATH . $this->server_config->silex_server_ini["CONF_FOLDER"].self::DEFAULT_WEBSITE_CONF_FILE;
					$dest = $path . "/" . $this->server_config->silex_server_ini["WEBSITE_CONF_FILE"];
					return copy($source, $dest);
				}
				else
				{
					rmdir($path);
					return false;
				}
			}
		}
		/** 
		 * rename a website
		 */
		function renameWebsite($id_site,$newId)
		{
			// sanitize
			$id_site = str_replace(array('/', '\\'), '', htmlentities(strip_tags($id_site)));
			$newId = str_replace(array('/', '\\'), '', htmlentities(strip_tags($newId)));

			$path=ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site;
			$newPath=ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newId;

			if (!is_dir($newPath))
			{
				if ($this->logger) $this->logger->debug("renameWebsite rename website ".$path." renamed -> ".$newPath);

				return rename($path,$newPath);
			}
			return FALSE;
		}
		/**
		* deprecated. this is still used by the website config tool, and createWebsite so leave it for now.
		*/
		function writeWebsiteConfig($websiteInfo,$id_site){
			if ($this->logger) $this->logger->debug("writeWebsiteConfig($websiteInfo,$id_site) ");
			if (!$id_site || $id_site=='')
				return false;
				
			$path=realpath(ROOTPATH . $this->server_config->getContentFolderForPublication($id_site).$id_site);

			// **
			// website creation
			// check existance
			$initial_path=$path;
			if (!$this->fst->sanitize($path)){
				if ($this->logger) $this->logger->info("writeWebsiteConfig mkdir(".$initial_path.")");
				mkdir($initial_path);
				$path=$this->fst->sanitize($initial_path);
			}
			
			// check rights
			if ($this->fst->checkRights($path,file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION)){

				// **
				// write data into the file

				// build data string
				$data='';
				foreach ($websiteInfo as $key => $value) {
					$data.=$key."=".$value."&\n";
				}

				// delete website or write data?
				if ($data==''){
					if ($this->logger) $this->logger->debug("writeWebsiteConfig delete website (data empty) ".$path." renamed -> ".ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_deleted_".date('Y-m-d_H-i-s'));
					// not empty! - return rmdir($this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site);
					return rename($path,ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_deleted_".date('Y-m-d_H-i-s'));
				}
				else{
					// open
					$fileName=$path."/conf.txt";
					$fileHandle=fopen($fileName,"w");
					if (!$fileHandle){
						if ($this->logger) $this->logger->debug("writeWebsiteConfig error opening file : $fileName");
						return false;
					}
					// add UTF-8 header
					$data="\xEF\xBB\xBF".$data; 
					// write
					$isOk=fputs ($fileHandle,$data);
					if (!$isOk){
						if ($this->logger) $this->logger->debug("writeWebsiteConfig error writing data : $data in $fileName");
						return false;
					}
					// close
					fclose($fileHandle);
				}
				// return no-error state
				return true;
			}
			else{
				if ($this->logger) $this->logger->debug("writeWebsiteConfig no rights to write data : $data in $fileName");
			}
			return false;
		}
		function duplicateWebsite($id_site,$newName){
			if ($this->logger) $this->logger->debug("duplicateWebsite($id_site,$newName) ");

			$path=ROOTPATH . $this->server_config->getContentFolderForPublication($id_site).$id_site;
			$newPath=ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newName;

			if (is_dir(ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newName)==TRUE){
				return "This website already exist";
			}
			if (!$newName || $newName==''){
				return "No name specified";
			}
			mkdir($newPath);
			$this->fst->sanitize($newPath);

			// check rights
			if ($this->fst->checkRights($this->fst->sanitize($path),file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION)){
				// do the copy
				if ($this->doDuplicateWebsite($path."/",$newPath."/")==TRUE)
					return '';
				else{
					// delete partially copyed folder
					if (is_dir(ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newName))
						rename(ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newName,ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_".$newName."_rename-error_".date('Y-m-d_H-i-s'));
					if ($this->logger) $this->logger->emerg("duplicateWebsite error : Unknown error - rename(".ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$newName." becomes -> ".ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_".$newName."_rename-error_".date('Y-m-d_H-i-s').")");
					return "Unknown error";
				}
			}
			else{
				if ($this->logger) $this->logger->emerg("duplicateWebsite no rights to duplicate website : $id_site to $newName");
				return "no rights to duplicate website : $id_site to $newName";
			}		
		}
		/*
		Function: moveWebsiteInThemes
		Creates a theme from an existing website
		
		Parameters:
			$id_site - id of the site to copy
			$themeName - name of the theme to create
		
		Author: Thomas Fétiveau, http://www.tofee.fr/ or thomas.fetiveau.tech [at] gmail.com
		*/
		function moveWebsiteInThemes($id_site,$themeName)
		{
			if ($this->logger) $this->logger->debug("moveWebsiteInThemes($id_site,$themeName) ");
			
			// get the path of the site to move in themes (not very clean but it's how it's done now for website duplication)
			$path = ROOTPATH . $this->server_config->getContentFolderForPublication($id_site).$id_site;
			// compute the path of the desired theme
			$newPath = ROOTPATH . $this->server_config->silex_server_ini["CONTENTS_THEMES_FOLDER"].$themeName;
			
			if(is_dir($newPath))
			{
				return "This theme already exists";
			}
			if (!$themeName || $themeName=='')
			{
				return "No theme name specified";
			}
			
			mkdir($newPath);
			
			// check rights
			if ($this->fst->checkRights($this->fst->sanitize($path),file_system_tools::ADMIN_ROLE,file_system_tools::WRITE_ACTION))
			{
				// do the copy
				if ($this->doDuplicateWebsite($path."/",$newPath."/")==TRUE)
					return '';
				else
				{
					// delete partially copied folder
					if (is_dir($newPath))
						rename($newPath,ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_".$themeName."_moves-to-themes-error_".date('Y-m-d_H-i-s'));
					if ($this->logger)
						$this->logger->emerg("moveWebsiteInThemes error : Unknown error - rename(".$newPath." becomes -> ".ROOTPATH . $this->server_config->silex_server_ini["TRASH_FOLDER"].$id_site."_".$themeName."_moves-to-themes-error_".date('Y-m-d_H-i-s').")");
					
					return "Unknown Error";
				}
			}
			else
			{
				if ($this->logger) $this->logger->emerg("moveWebsiteInThemes no rights to move website $id_site to theme $themeName");
				return "no rights to move website $id_site to theme $themeName";
			}
		}
		// do the copy
		function doDuplicateWebsite($folder,$newFolder){
			if ($this->logger) $this->logger->debug("doDuplicateWebsite($folder,$newFolder)");

			// list folder and copy
			$tmpFolder = opendir($folder);
			while ($tmpFile = readdir($tmpFolder)) {
				if ($tmpFile != "." && $tmpFile != ".."){
					if (is_file($folder.$tmpFile)){
						if (!copy($folder.$tmpFile,$newFolder.$tmpFile)){
							if ($this->logger) $this->logger->emerg("doDuplicateWebsite error while copying file "+$folder.$tmpFile." to ".$newFolder.$tmpFile);
							return FALSE;
						}
					}
				}
			}
			return TRUE;
		}
		/**
		* function getSiteThumb($siteName)
		* Choose the most appropriate image to serve as a preview for the selected site.  The single input parameter is the name of the site.
		* Output parameters : 
		*	<br>		- title = file name
		*	<br>		- extension = file extension
		*	<br>		- name = file name without extension
		*	<br>		- pubDate = file last modification date
		*   <br>               - path : relative path from silex root
		*	<br>		- fileSize
		*	<br>               - type= (e.g. image/jpeg) 
		*	<br>               - width
		*	<br>               - height
		*	<br>               - url;
		*/
		function getSiteThumb($siteName)
		{
			if ($this->logger) $this->logger->debug("getSiteThumb($siteName) ");
			
			$contentFolder = $this->server_config->getContentFolderForPublication($siteName);
			$path = $this->fst->sanitize(ROOTPATH . "/$contentFolder/$siteName");
			
			if ($this->fst->checkRights($path,file_system_tools::USER_ROLE,file_system_tools::READ_ACTION))
			{
				// compute url base
				$scriptUrl = $_SERVER['SERVER_NAME'] . ':' . $_SERVER['SERVER_PORT'] . $_SERVER['REQUEST_URI'] ;
				$lastSlashPos = strrpos( $scriptUrl , "cgi/gateway.php" ) ;
				$urlBase = "http://" . substr( $scriptUrl , 0 , $lastSlashPos ) ;
				
				$resArray = array() ;
				
				// We search for a preview.png or preview.jpg file in the site's content directory
				if( is_file( "$path/preview.png" ) || is_file( "$path/preview.jpg" ) )
				{
					if( is_file( "$path/preview.png" ) ) $ext = "png" ; else $ext = "jpg" ;
					
					$resArray["title"] = "preview.$ext" ;
					$resArray["name"] = "preview" ;
					$resArray["pubDate"] = date ("Y-m-d\H:i:s", filemtime($path."/preview.$ext")) ;
					$resArray["fileSize"] = $this->fst->readableFormatFileSize(filesize($path."/preview.$ext")) ;
					$imageSize = getimagesize ($path."/preview.$ext") ;
					$resArray["width"] = $imageSize[0] ;
					$resArray["height"] = $imageSize[1] ;
					$resArray["type"] = $imageSize["mime"] ;
					$resArray["extension"] = "$ext" ;
					$resArray["path"] = "/$contentFolder/$siteName/preview.$ext" ;
					$resArray["url"] = "$urlBase/$contentFolder/$siteName/preview.$ext" ;
				}
				else
				{
					$files = $this->fst->listFolderContent($path, false, array('jpg', 'png'), file_system_tools::itemModifDateField , true ) ;
					
					if(isset($files[0])) // We search for the last modified image file in the site's content directory
					{
						$resArray["title"] = $files[0][file_system_tools::itemNameField] ;
						$resArray["name"] = $files[0][file_system_tools::itemNameNoExtField] ;
						$resArray["pubDate"] = $files[0][file_system_tools::itemModifDateField] ;
						$resArray["fileSize"] = $files[0][file_system_tools::itemReadableSizeField] ;
						$resArray["width"] = $files[0][file_system_tools::itemWidthField] ;
						$resArray["height"] = $files[0][file_system_tools::itemHeightField] ;
						$resArray["type"] = $files[0][file_system_tools::itemImageTypeField] ;
						$resArray["extension"] = $files[0]["ext"] ;
						$resArray["path"] = "/$contentFolder/$siteName/".$files[0][file_system_tools::itemNameField] ;
						$resArray["url"] = "$urlBase/$contentFolder/$siteName/".$files[0][file_system_tools::itemNameField] ;
					}
					else // No image available in site's content directory thus we return the default generic preview image
					{
						if ( is_null ( $this->fst->server_config ) )
						{
							$this->fst->server_config = new server_config();
						}
						
						$preview = $this->fst->server_config->silex_server_ini['PREVIEW_DEFAULT_IMAGE'] ;
						
						$path = realpath(ROOTPATH . "/$preview" ) ;
						
						if( is_file ( $path ) )
						{
							$resArray["title"] = substr ( strrchr ( $preview , "/" ) , 1 ) ;
							$resArray["extension"] = substr ( strrchr ( $preview , "." ) , 1 ) ;
							$resArray["name"] =  str_ireplace  (  ".".$resArray["extension"]  ,  ''  ,  $resArray["title"] ) ;
							$resArray["pubDate"] = date ("Y-m-d\H:i:s", filemtime($path)) ;
							$resArray["fileSize"] = $this->fst->readableFormatFileSize(filesize($path)) ;
							$imageSize = getimagesize ($path) ;
							$resArray["width"] = $imageSize[0] ;
							$resArray["height"] = $imageSize[1] ;
							$resArray["type"] = $imageSize["mime"] ;
							$resArray["path"] = "/$preview" ;
							$resArray["url"] = "$urlBase/$preview" ;
						}
					}
				}
				
				return $resArray ;
			}
			
			return "FORBIDDEN";
		}
		/**
		* function getPagePreview($siteName,$pageName)
		* Retrieve the preview image for a given page, i.e. the png or jpg image with the same name.
		* Output parameters : 
		*	<br>		- title = file name
		*	<br>		- extension = file extension
		*	<br>		- name = file name without extension
		*	<br>		- pubDate = file last modification date
		*   <br>               - path : relative path from silex root
		*	<br>		- fileSize
		*	<br>               - type= (e.g. image/jpeg) 
		*	<br>               - width
		*	<br>               - height
		*	<br>               - url;
		*/
		function getPagePreview($siteName,$pageName)
		{
			if ($this->logger) $this->logger->debug("getPagePreview($siteName,$pageName) ");
			
			$contentFolder = $this->server_config->getContentFolderForPublication($siteName);
			$path = $this->fst->sanitize(ROOTPATH . "/$contentFolder/$siteName");
			
			if ($this->fst->checkRights($path,file_system_tools::USER_ROLE,file_system_tools::READ_ACTION))
			{
				// compute url base
				$scriptUrl = $_SERVER['SERVER_NAME'] . ':' . $_SERVER['SERVER_PORT'] . $_SERVER['REQUEST_URI'] ;
				$lastSlashPos = strrpos( $scriptUrl , "cgi/gateway.php" ) ;
				$urlBase = "http://" . substr( $scriptUrl , 0 , $lastSlashPos ) ;
				
				$resArray = array() ;

				// We search for a preview.png or preview.jpg file in the site's content directory
				if( is_file( "$path/$pageName.png" ) || is_file( "$path/$pageName.jpg" ) )
				{
					if( is_file( "$path/$pageName.png" ) ) $ext = "png" ; else $ext = "jpg" ;
					
					$resArray["title"] = $pageName.$ext ;
					$resArray["name"] = $pageName ;
					$resArray["pubDate"] = date ("Y-m-d\H:i:s", filemtime($path."/$pageName.$ext")) ;
					$resArray["fileSize"] = $this->fst->readableFormatFileSize(filesize($path."/$pageName.$ext")) ;
					$imageSize = getimagesize ($path."/$pageName.$ext") ;
					$resArray["width"] = $imageSize[0] ;
					$resArray["height"] = $imageSize[1] ;
					$resArray["type"] = $imageSize["mime"] ;
					$resArray["extension"] = "$ext" ;
					$resArray["path"] = "/$contentFolder/$siteName/$pageName.$ext" ;
					$resArray["url"] = "$urlBase/$contentFolder/$siteName/$pageName.$ext" ;
				}
				else // No image available in site's content directory thus we return the default generic preview image
				{
					if ( is_null ( $this->fst->server_config ) )
					{
						$this->fst->server_config = new server_config();
					}
					
					$preview = $this->fst->server_config->silex_server_ini['PAGE_PREVIEW_DEFAULT_IMAGE'] ;
					
					$path = realpath(ROOTPATH . "/$preview" ) ;
					
					if( is_file ( $path ) )
					{
						$resArray["title"] = substr ( strrchr ( $preview , "/" ) , 1 ) ;
						$resArray["extension"] = substr ( strrchr ( $preview , "." ) , 1 ) ;
						$resArray["name"] =  str_ireplace  (  ".".$resArray["extension"]  ,  ''  ,  $resArray["title"] ) ;
						$resArray["pubDate"] = date ("Y-m-d\H:i:s", filemtime($path)) ;
						$resArray["fileSize"] = $this->fst->readableFormatFileSize(filesize($path)) ;
						$imageSize = getimagesize ($path) ;
						$resArray["width"] = $imageSize[0] ;
						$resArray["height"] = $imageSize[1] ;
						$resArray["type"] = $imageSize["mime"] ;
						$resArray["path"] = "/$preview" ;
						$resArray["url"] = "$urlBase/$preview" ;
					}
				}
				
				return $resArray ;
			}
			
			return "FORBIDDEN";
		}
		
	}
?>