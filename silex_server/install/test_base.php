<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	//needs rootdir.php in calling script
	require_once("localisation.php");
	class test_base{
		//private
		var $result = false;
		var $title = "test base, should be set in derived test class";
		var $loc = null;
		
		function test_base(){
			$this->loc = new localisation();
		}
		
		function runTest(){
			//set test result at the end of the test.
			//$this->result = true;
		}
		
		function getResult(){
			return $this->result;
		}
		
		function getTitle(){
			return $this->title;
		}
		
		function getHelp(){
			//implement in derived class. probably an included separate file. Naming convention is <testclassname>_help.php
		}
		
		//most tests are fatal for an installation, but a couple are not. override in derived class
		function isFatal(){
			return true;
		}
	}
?>