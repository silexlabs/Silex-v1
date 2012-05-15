<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
//class to be used by installer for localisation
/**
notes:
choix langue auto? deviner selon langue nav (drugbox). defaut anglais
proposer choix langue 
tests tout est présent sur chaque page: liste constantes dont on a besoin pour la page
fonction: loadLocalizedText($langCode: 2 letter country code, neededConsts:Array of string)
pas de sessions parce qu'on ne sait pas encopre si c supporté
*/
	define("FORMAT", "flashvars");
	define("CODE_ENGLISH", "en");
	define("LANGCODE_GET_PARAM", "langCode");
	//needs rootdir.php in calling script
	class localisation{
		var $languageUsed;
		var $localisedData;
		var $availableLanguages;
		var $absoluteLocalisedFileFolder; 
		var $relativeLocalisedFileFolder; 
		function localisation(){
			$this->relativeLocalisedFileFolder = "lang/install/";
			$this->absoluteLocalisedFileFolder = ROOTPATH . $this->relativeLocalisedFileFolder;
			$this->loadAvailableLanguages();
			$this->useDefaultLanguage();
		}
		
		//sets the language to the default. uses the one pased in the GET if available, the navigator language if available, otherwise uses English
		function useDefaultLanguage(){
			$langCode = null;
			if(isset($_GET[LANGCODE_GET_PARAM])){
				$langCode = $_GET[LANGCODE_GET_PARAM];
			}
			if(!$langCode){
				$langCode = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
			}
			if($this->isLanguageAvailable($langCode)){
				$this->setLanguage($langCode);
			}else{
				$this->setLanguage(CODE_ENGLISH);
			}
		}
		
		function loadAvailableLanguages(){
			$filesInFolder = Array();
			if ($handle = opendir($this->absoluteLocalisedFileFolder)) {
				while (false !== ($file = readdir($handle))) {
					if(strpos($file, ".") !== 0){
						array_push($filesInFolder, $file);
					}
				}
				closedir($handle);
			}
			$this->availableLanguages = array();
			//print_r($filesInFolder);
			foreach($filesInFolder as $localisationFile){
				$langCode = substr($localisationFile, 0, 2);
				array_push($this->availableLanguages, $langCode);
			}
			//print_r($this->availableLanguages);
		}
		
		//@param lang : use a 2 letter country code.
		function isLanguageAvailable($langCode){
			//echo "isLanguageAvailable : $langCode";
			foreach($this->availableLanguages as $code){
				if($langCode == $code){
					return true;
				}
			}
			return false;
		}
		
		function loadLanguage($langCode){
			$this->localisedData = array();
			$path = $this->absoluteLocalisedFileFolder . $langCode . ".txt";
			//echo "path : $path";
			$lines = file($path);
			foreach($lines as $line){
				//echo "<br/>$line";

				if(trim($line) == ""){
					//skip blanks
					continue;
				}
				if(strpos($line, ";") === 0){
					//skip comments
					continue;
				}
				$explodedLine = explode("=", $line);
				
				//get rid of the "&" at the end
				if(isset($explodedLine[1])){
					$explodedLine[1] = substr($explodedLine[1], 0, strpos($explodedLine[1] ,"&"));
					//echo $explodedLine[0] . "<br/>";
					$this->localisedData[$explodedLine[0]] = $explodedLine[1];
				}
			}
			
			//print_r($this->localisedData);
		
		}
		//sets the language to be used during installation. 
		//@param lang : use a 2 letter country code.
		function setLanguage($langCode){
			//echo $langCode;
			$this->languageUsed = $langCode;
			$this->loadLanguage($langCode);
		}
		
		//returns localised string corresponding to key
		function getLocalised($key){
			$value = $this->localisedData[$key];
			if($value == null){
				$value = "value for ". $key . " not found in lang/install/" . $this->languageUsed . ".txt";
			}
			return $value;
		}
	
	}
	
?>