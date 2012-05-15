<?php
// +----------------------------------------------------------------------+
// | PHP Version 4                                                        |
// +----------------------------------------------------------------------+
// | Copyright (c) 1997-2003 The PHP Group                                |
// +----------------------------------------------------------------------+
// | This source file is subject to version 2.0 of the PHP license,       |
// | that is bundled with this package in the file LICENSE, and is        |
// | available at through the world-wide-web at                           |
// | http://www.php.net/license/2_02.txt.                                 |
// | If you did not receive a copy of the PHP license and are unable to   |
// | obtain it through the world-wide-web, please send a note to          |
// | license@php.net so we can mail you a copy immediately.               |
// +----------------------------------------------------------------------+
// | Authors: Phillip Oertel <me@phillipoertel.com>                       |
// +----------------------------------------------------------------------+
//
// $Id: PHPConstants.php,v 1.3 2005/12/24 02:24:30 aashley Exp $

/**
* Config parser for Flashvars files. does not support sections
*
* @author      Ariel Sommeria-klein <ariel.publique@gmail.com>
* @package     Config
* @version     0.1 (not submitted)
*/

require_once ROOTPATH . 'cgi/includes/Config/Container.php';

class Config_Container_FlashVars extends Config_Container {

    /**
    * This class options
    * Not used at the moment
    *
    * @var  array
    */
    var $options = array();

    /**
    * Constructor
    *
    * @access public
    * @param    string  $options    (optional)Options to be used by renderer
    */
    function Config_Container_FlashVars($options = array())
    {
        $this->options = $options;
    } // end constructor

    /**
    * Parses the data of the given configuration file
    *
    * @access public
    * @param string $datasrc    path to the configuration file
    * @param object $configType        reference to a config object
    * @return mixed    returns a PEAR_ERROR, if error occurs or true if ok
    */
    function &parseDatasrc($datasrc, &$configType)
    {
        $return = true;

        if (!file_exists($datasrc)) {
            //return PEAR::raiseError("Datasource file does not exist.", null,                PEAR_ERROR_RETURN);
			throw new Exception("Datasource file does not exist.");
				
        }
        
        $fileContent = file_get_contents($datasrc, true);
        
        if (!$fileContent) {
            //return PEAR::raiseError("File '$datasrc' could not be read.", null,                PEAR_ERROR_RETURN);
			throw new Exception("File '$datasrc' could not be read.");
        }

        // remove bom, flash doesn't like it
        if(substr($fileContent, 0,3) == pack("CCC",0xef,0xbb,0xbf)) {
            $fileContent=substr($fileContent, 3);
        }        
        
        $rows = explode("\n", $fileContent);
        for ($i=0, $max=count($rows); $i<$max; $i++) {
            $line = $rows[$i];
	    
            //echo "<br/>line : " . $line. "<br/>\n";
            
            //blanks
            if($line == ""){
				//echo "blank" . "<br/>\n";
				$configType->container->createBlank();
                continue;
            }
            
            // comments
            if (strpos($line, ';') !== false)  //line contains with a ";"
            {
                $comment = trim(substr($line, strpos($line, ';') + 1));
                $configType->container->createComment($comment);
                //echo "comment" . strpos($line, ';') . "<br/>\n";
            }else{
                
                // directives
                $equalPos = strPos($line, '=');
                $andPos = strPos($line, '&');
                if(($andPos !== false) && ($andPos !== false)){
                    $key = trim(substr($line, 0, $equalPos));
                    $value = trim(substr($line, $equalPos + 1, $andPos - $equalPos - 1));
                    //echo "key :" . $key. ", value :" . $value ."<br/>\n";
                    $configType->container->createDirective($key, $value);
                }
            }
        }
	
        return $return;
        
    } // end func parseDatasrc

    /**
    * Returns a formatted string of the object
    * @param    object  $configType    Container object to be output as string
    * @access   public
    * @return   string
    */
     function toString(&$configType, $options = array())
     {
         $string = '';

         switch ($configType->type) 
         {
             case 'blank':
                 $string = "\n";
                 break;
                 
             case 'comment':
                 $string = '; '.$configType->content."\n";
                 break;
                 
             case 'directive':
                 $content = $configType->content;
                 $string = $configType->name.'=' . $content . '&' . chr(10);
                 break;
                 
             case 'section':
                 if (!$configType->isRoot()) {
                     $string  = chr(10);
                     $string .= ';'.chr(10);
                     $string .= '; '.$configType->name.chr(10);
                     $string .= ';'.chr(10);
                 }
                 if (count($configType->children) > 0) {
                     for ($i = 0, $max = count($configType->children); $i < $max; $i++) {
                         $string .= $this->toString($configType->getChild($i));
                     }
                 }
                 break;
             default:
                 $string = '';
         }
         return $string;
     } // end func toString

    /**
    * Writes the configuration to a file
    *
    * @param  mixed  datasrc    info on datasource such as path to the file
    * @param  string configType     (optional)type of configuration
    * @access public
    * @return string
    */
    function writeDatasrc($datasrc, &$configType, $options = array())
    {
        $fp = @fopen($datasrc, 'w');
        if ($fp) {
            $string = $this->toString($configType);
            // add UTF-8 header. Not sure why this is necessary, but probably for other editors
            $string = "\xEF\xBB\xBF" . $string;             
            $len = strlen($string);
            @flock($fp, LOCK_EX);
            @fwrite($fp, $string, $len);
            @flock($fp, LOCK_UN);
            @fclose($fp);
            
            // need an error check here
            
            return true;
        } else {
            //return PEAR::raiseError('Cannot open datasource for writing.', 1,                 PEAR_ERROR_RETURN);
			throw new Exception('Cannot open datasource for writing.');
        }
    } // end func writeDatasrc

     
} // end class Config_Container_PHPConstants

?>
