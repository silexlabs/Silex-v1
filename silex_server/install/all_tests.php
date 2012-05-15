<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once("test_base.php");
	require_once("test_php_version.php");
	require_once("test_file_system_rights.php");
	require_once("test_session.php");
	require_once("test_set_include_path.php");
//	require_once("test_rewrite.php");
	/**
	* instanciate this class and call runTest to run all the tests on the server. 
	* it stops at the first failed test.
	*/
	class all_tests extends test_base{
		
		var $failedTests;
		
		function all_tests(){
			parent::test_base();
			$this->title = "all tests";
		}
		
		function runTest(){
			$tests = array();
			array_push($tests, new test_php_version());
			array_push($tests, new test_file_system_rights());
			array_push($tests, new test_set_include_path());
			array_push($tests, new test_session());
//			array_push($tests, new test_rewrite());
			$this->failedTests = array();
			foreach($tests as $test){
				$test->runTest();
				//echo $test->getTitle() . "<br/>";
				if(!$test->getResult()){
					array_push($this->failedTests, $test);
					if($test->isFatal()){
						$this->result = false;
						return;
					}
				}
			}
			$this->result = true;
		}
		
		function getHelp(){
			$ret = "";
			foreach($this->failedTests as $test){
				$test->getHelp();
				echo "<br/>";
			}
		}
		
	}
?>
