<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	set_include_path(get_include_path() . PATH_SEPARATOR . "../");
	set_include_path(get_include_path() . PATH_SEPARATOR . "../cgi/includes/");
	set_include_path(get_include_path() . PATH_SEPARATOR . "../cgi/library/");
	require_once("password_manager.php");
	require_once("localisation.php");
	require_once("config_editor.php");
	
	$loc = new localisation();
	$p = new password_manager();
	$password = $_POST["password"];
	$login = $_POST["login"];
	$isFirstTime = false;
	
	if($p->isAuthenticationFileAvailable()){
		if(!$p->authenticate($login, $password)){
			echo "password invalid";
			exit(-1);
		}
	}else{
		if($password && $password != ''){
			$p->createFile($login, $password);
			$confEditor = new config_editor();
			$dataToMerge = Array();
			$dataToMerge["SILEX_ADMIN_DEFAULT_LANGUAGE"] = $loc->languageUsed;
			$confEditor->updateConfigFile("conf/silex_server.ini", "inicommented", $dataToMerge);
		}
		$isFirstTime = true;
	}

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><?php echo $loc->getLocalised("TITLE")?> &gt; <?php echo $loc->getLocalised("STEP3")?></title>

	<link rel="icon" type="image/png" href="images/favicon.png" />
	<!--[if IE]><link rel="shortcut icon" type="image/x-icon" href="images/favicon.ico" /><![endif]-->

	<link rel="stylesheet" type="text/css" href="install.css">
</head>

<body>

<div id="page">

	<div id="header">
		<h1><?php echo $loc->getLocalised("TITLE"); ?></h1>
	</div>
	
			
	<div id="steps">
		<div id="step3">
			<table width="870" border="0" cellspacing="0" cellpadding="0">
				<tr>		
					<td width="320"><div align="center"><?php echo $loc->getLocalised("STEP1")?></div></td>
					<td width="260"><div align="center"><?php echo $loc->getLocalised("STEP2")?></div></td>
					<td width="290"><div align="center"><?php echo $loc->getLocalised("STEP3")?></div></td>
				</tr>
			</table>
		</div>
	</div>
	
	<div id="content">
	
	<div id="cadre">
	<br />
		<p>
			<?php
				if($isFirstTime){
					?>
						<?php echo $loc->getLocalised("ACCOUNT_CREATED")?><br />
						<?php echo $loc->getLocalised("SERVER_INSTALLED")?><br />
					<?php
				}
				?>
			<?php echo $loc->getLocalised("THATS_IT")?>
        </p>
		<br /><br />
		<form action='../' method="GET">
			<input type="hidden" name="autologin" value="1" /> 
			<input type='submit' class="welcomebtn" value='<?php echo $loc->getLocalised("GOTO_MANAGER")?>'/>
		</form>
	</div>
	
	</div>
  
	<div id="footer" class="footerstep3">
	</div>
	
</div>

</body>
</html>
