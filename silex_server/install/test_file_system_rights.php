<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once("test_base.php");
	class test_file_system_rights extends test_base{

		function test_file_system_rights(){
			parent::test_base();
			$this->title = "test file system rights";
		}
		
		function checkRights($filename, $giveUserFeedback){
			//echo "<H2>".$filename." check</H2><br>";
			if(is_executable($filename) && is_writable($filename)){
				if($giveUserFeedback){
					echo "<b>" . $filename . "</b> " . $this->loc->getLocalised("TEST_RIGHTS_HAS_RIGHTS");
				}
			}
			else{
				if($giveUserFeedback){
					echo "<b>" . $filename . "</b> " . $this->loc->getLocalised("TEST_RIGHTS_HAS_NO_RIGHTS");
				}
				if (chmod ($filename, 0755)){
					if($giveUserFeedback){
						echo "<b>" . $filename . "</b> " . $this->loc->getLocalised("TEST_RIGHTS_CHMOD_OK") . "<br>";
					}
				}
				else{
					if($giveUserFeedback){
						echo "<b>" . $filename . "</b>" . $this->loc->getLocalised("TEST_RIGHTS_CHMOD_NOK") . "<br>";
					}
					return false;
				}
			}
			return true;
		}
		
		function runTest(){
			$giveUserFeedback = false; //true;
			$res1 = $this->checkRights("../media", $giveUserFeedback);
			$res2 = $this->checkRights("../contents", $giveUserFeedback);
			$this->result = $res1 && $res2;
		}

		
		function getHelp(){
			include("test_file_system_rights_help.php");
		}

	}
?>