<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


set_include_path(get_include_path() . PATH_SEPARATOR . "../../");
set_include_path(get_include_path() . PATH_SEPARATOR . "../library/");
//abstraction layer for silex logging
require_once 'Zend/Log.php';
require_once "Zend/Log/Writer/Stream.php";
require_once "rootdir.php";

define("DEFAULT_LOG_SECTION", "default");
define("LOG_LEVEL","logLevel");
define("DEBUG", Zend_Log::DEBUG);
define("INFO", Zend_Log::INFO);
define("NOTICE", Zend_Log::NOTICE);
define("WARNING", Zend_Log::WARN);
define("ERR", Zend_Log::ERR);
define("CRIT", Zend_Log::CRIT);
define("ALERT", Zend_Log::ALERT);
define("EMERG", Zend_Log::EMERG);
//zend logging does not offer completely disabling the logger. We need to be able to do so because simply instanciating a Zend_Log_Writer_Stream
//creates a file, and this can cause silex to fail on some hosts(sourceforge personal page like http://arielsom.users.sourceforge.net/ for example)
//so if we find "DISABLED", the logger is not instanciated
define("DISABLED", -1);

class logger{
    var $name = null;
    var $logHandle = null;
    var $filter = null;
    function logger($loggerName){
        $this->name = $loggerName;        
        $logLevel = $this->getLogLevel($loggerName);
		if($logLevel > DISABLED){
			$this->logHandle = new Zend_Log(new Zend_Log_Writer_Stream(ROOTPATH . '/logs/'.date("Ymd")."silex.log"));
			$this->filter = new Zend_Log_Filter_Priority((int)$logLevel);
			$this->logHandle->addFilter($this->filter);
			//$this->debug("logger created with logLevel : $logLevel");

		}
    }
        
    function getLogLevel($loggerName){
        $logConfig = parse_ini_file(ROOTPATH . "/conf/log.ini", true);
        if(isset($logConfig[$loggerName])){
            $conf = $logConfig[$loggerName];    
        }else{
            $conf = $logConfig[DEFAULT_LOG_SECTION];    
        }
		//echo "logConfig : " . print_r($logConfig, true) . "<br/>";
        $level = $conf[LOG_LEVEL];
		//echo "$loggerName logLevel : $level <br/>";
        return $level;
    }
       
    function debug($message){        
        if($this->logHandle) $this->logHandle->debug($this->name." ".$message);       
		//echo $message . "<br/>";
    }

    function info($message){        
        if($this->logHandle) $this->logHandle->info($this->name." ".$message);       
		//echo $message . "<br/>";
    }


    function err($message){
        if($this->logHandle) $this->logHandle->err($this->name." ".$message);
		echo $message . "<br/>";
    }

    function crit($message){
        if($this->logHandle) $this->logHandle->crit($this->name." ".$message);
		//echo $message . "<br/>";
    }
	
    function alert($message){
        if($this->logHandle) $this->logHandle->alert($this->name." ".$message);
		//echo $message . "<br/>";
    }
	
    function emerg($message){
        if($this->logHandle) $this->logHandle->emerg($this->name." ".$message);
		//echo $message . "<br/>";
    }
	
}



?>