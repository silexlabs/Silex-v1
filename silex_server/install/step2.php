<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	// no, uses php5 : require_once("../rootdir.php");
	define( 'ROOTPATH', '..' . DIRECTORY_SEPARATOR);
	require_once("localisation.php");
	$loc = new localisation();
	
	require_once("all_tests.php");
	$allTests = new all_tests();
	$allTests->runTest();
	$testsOk = $allTests->getResult();
	$serverAlreadyInstalled = false;
	if($testsOk){
		set_include_path(get_include_path() . PATH_SEPARATOR . "../");
		set_include_path(get_include_path() . PATH_SEPARATOR . "../cgi/includes/");
		set_include_path(get_include_path() . PATH_SEPARATOR . "../cgi/library/");
		require_once("password_manager.php");
		$p = new password_manager();
		
		if($p->isAuthenticationFileAvailable()){
			$serverAlreadyInstalled = true;
		}
	
	}
	
	//server is ok, ask for login if no account available, ask for account creation otherwise
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	
	<title><?php echo $loc->getLocalised("TITLE")?> &gt; <?php echo $loc->getLocalised("STEP2")?></title>

	<link rel="icon" type="image/png" href="images/favicon.png" />
	<!--[if IE]><link rel="shortcut icon" type="image/x-icon" href="images/favicon.ico" /><![endif]-->

	<link rel="stylesheet" type="text/css" href="install.css" />
</head>

<body>
<div id="page">

	<div id="header">
		<h1><?php echo $loc->getLocalised("TITLE"); ?></h1>
	</div>
	
	<div id="steps">
		<div id="step2">
			<table width="870" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="320"><div align="center"><?php echo $loc->getLocalised("STEP1"); ?></div></td>
					<td width="260"><div align="center"><?php echo $loc->getLocalised("STEP2"); ?></div></td>
					<td width="290"><div align="center"><?php echo $loc->getLocalised("STEP3"); ?></div></td>
				</tr>
			</table>
		</div>
	</div>
	
	<div id="content">
	
	<div id="cadre">
		<?php
			$allTests->getHelp();	
			if($testsOk){
			
				if($serverAlreadyInstalled){
					require_once("login.inc.php");
				}else{
					require_once("create_account.inc.php");
				}
				
			}
		?>
	</div>
	
	</div>

	<div id="footer" class="footerstep2">
	</div>
	
</div>
</body>
</html>