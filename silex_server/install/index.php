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
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

	<title><?php echo $loc->getLocalised("TITLE")?> &gt; <?php echo $loc->getLocalised("STEP1")?></title>

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
		<div id="step1">			
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
			<?php echo $loc->getLocalised("WELCOME_INTRO_1"); ?> <span class="textsilex">silex</span> <?php echo $loc->getLocalised("WELCOME_INTRO_2"); ?><br />
			<?php echo $loc->getLocalised("WELCOME_RUN_TESTS"); ?>
		</p>
	<br />
		<form action="step2.php?langCode=<?php echo $loc->languageUsed; ?>" method="post">
			<input name="Submit" class="welcomebtn" type="submit" value="<?php echo $loc->getLocalised("WELCOME_LABEL_BUTTON"); ?>" />
		</form>
	<br /><br />
		<div id="selectlang">
		<?php echo $loc->getLocalised("WELCOME_CHOOSE_LANGUAGE_DESCRIPTION"); ?>
			<select id="langSelect" onchange="window.location.href='index.php?langCode=' + getElementById('langSelect').value;">
				<?php 
					foreach($loc->availableLanguages as $langCode){
						if($langCode == $loc->languageUsed){
							echo "<option selected='yes' value='" . $langCode . "'>" . $langCode . "</option>\n";
						}else{
							echo "<option value='" . $langCode . "'>" . $langCode . "</option>\n";
						}
					}
				?>
			</select>
		</div>
	</div>
	
	</div>
	
	</div>
	
	<div id="footer" class="footerstep1">
	</div>


<?php
	if (version_compare(PHP_VERSION,'5','<')){
?>
<!--
		//tests for different ways to force php 5
	//the closing </iframe> tags is so that firefox shows all the iframes and not just the first
-->
	<iframe src="./php_version_test/setenv/" frameborder="0" width="0" height="0"></iframe>
	<iframe src="./php_version_test/addtype/" frameborder="0" width="0" height="0"></iframe>	
	<iframe src="./php_version_test/addtype2/" frameborder="0" width="0" height="0"></iframe>	

<?php
	}
?>

</body>
</html>