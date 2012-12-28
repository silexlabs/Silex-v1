<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
set_include_path(get_include_path() . PATH_SEPARATOR . "../../");
set_include_path(get_include_path() . PATH_SEPARATOR . "../library/");

require_once("cgi/includes/domxml.php");
require_once("logger.php");
/** Zend_Debug */
require_once 'Zend/Debug.php';
//Config
require_once("silex_config.php");
require_once("rootdir.php");
require_once("consts.php");
	

class password_manager
{
	/**
	* access to passwords should only be through this class.
	* on the format choices: we want the file to be in php to protect it from reading.
	* phpconstants doesn't parse properly, at least in the cases I tried, so use phparray
	* the extra 'logins' section seems a bit unnecessary, but I could't get it to work without
	* A.S.
	*/
	// ***********
	// attributes
	var $logger=null;
	var $serverRootPath;
		
	const FILE_FORMAT = "phparray";
	const SECTION_LOGINS = "LOGINS";
	var $authenticationFilePath = null;
	var $options = null; 
	
	// ***********
	// constructor
	function password_manager(){
		$this->options = array('name' => 'authentication');
		$this->authenticationFilePath = ROOTPATH . "/conf/pass.php";
		$this->logger = new logger("password_manager");
		$this->logger->debug("password_manager constructor");
	}
	
	//note: a config file can't be empty, at least with phparrays, so give original values
	function createFile($originalLogin, $originalPassword){
		$confContainer = new Config_Container('section', self::SECTION_LOGINS);
		$confContainer->setDirective($originalLogin, sha1($originalPassword));
		// set this container as our root container child in Config
		$config = new silex_config();
		$config->setRoot($confContainer);
		// write the container
		$config->writeConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);
	}
	
	//returns true if file exists, false if not
	function isAuthenticationFileAvailable(){
		//echo $this->authenticationFilePath . file_exists($this->authenticationFilePath);
		return file_exists($this->authenticationFilePath);
	}
	/**
	* creates or updates login/password pair and writes it to the password file
	*/
	function setPassword($login, $password){
		$conf = new silex_config;
		$confContainer = $conf->parseConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);        
		$loginsSection = $confContainer->getItem('section', self::SECTION_LOGINS);
		//print_r($confContainer->toArray());
		$loginsSection->setDirective($login, sha1($password));
		$conf->writeConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);
	}
	
	function deleteAccount($login){
		$conf = new silex_config;
		$confContainer = $conf->parseConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);        
		$loginsSection = $confContainer->getItem('section', self::SECTION_LOGINS);
		//print_r($loginsSection->toArray());
		//$account = $loginSection->getItem(null, $login);
		$path = array(self::SECTION_LOGINS, $login);
		$account = $confContainer->searchPath($path);
		print_r($account->toArray());
		$account->removeItem();
		$conf->writeConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);
	}
	/**
	* checks if login info is valid, returns true or false
	*/

//creates some serious problems when logging out, not ready to do this yet. 
/*	
	function mergeRole($role){
		if(isset($_SESSION['amfphp_roles'])){
			$currentRoles = $_SESSION['amfphp_roles'];
			$this->logger->debug("current roles : $currentRoles");
			if(strpos($currentRoles, $role) === false){
				return $currentRoles . "," . $role;
			}else{
				return $currentRole;
			}
		}else{	
			return $role;
		}
	
	}
	*/
	function authenticate($login, $password){
		$this->logger->debug("authenticate($login, $password)");
		if(!$login || ($login == "")){
			return false;
		}
		if(!$password || ($password == "")){
			return false;
		}
		$conf = new silex_config();
		$confContainer = $conf->parseConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);   
		//$this->logger->debug("confContainer / " . print_r($confContainer->toArray(), true));
		$loginsSection = $confContainer->getItem('section', self::SECTION_LOGINS);		
		$a = $loginsSection->toArray();
		$role = '';
		if($a[self::SECTION_LOGINS][$login] === sha1($password) || $a[self::SECTION_LOGINS][$login] === $password){ //We test against the password as sha1 and as plain-text (retro-compatibility)
			$role = AUTH_ROLE_USER;
		}else{
			return false;
		}
		
		return $role;
		
	}
	/**
	* helper function that returns an array formatted as a data provider for a Flash list, containing only logins
	*/
	function getLogins(){
		$conf = new silex_config;
		$confContainer = $conf->parseConfig($this->authenticationFilePath, self::FILE_FORMAT, $this->options);   
		$loginsSection = $confContainer->getItem('section', self::SECTION_LOGINS);		
		$a = $loginsSection->toArray();
//		print_r($a);
		$ret = array();
		foreach ($a[self::SECTION_LOGINS] as $key => $value) {
			array_push($ret, array("label"=> $key));
		}
//		print_r($ret);
		return $ret;
	}

}