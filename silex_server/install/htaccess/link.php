<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once("../../rootdir.php");
	require_once("../localisation.php");
	$loc = new localisation();
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<style type="text/css">
		<!--
		body,td,th {
			font-family: Arial, Helvetica, sans-serif;
			font-size: 12px;
			background-color: white;

		}
		.style2 {
			font-size: 19px;
			color: #FFFFFF;
		}
		.style5 {color: #FF9900; font-size: 17px; }
		.style6 {font-size: 17px}
		.style7 {font-size: 16px}
		.style8 {color: #666666}
		-->
		</style>
	</head>
<body>
<?php echo $loc->getLocalised("URL_REWRITING_NOK")?>
<br/>
<span class="style8"><?php echo $loc->getLocalised("URL_REWRITING_NOK_SO_WHAT")?></span><br />