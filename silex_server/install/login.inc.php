<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
?>
<p><?php echo $loc->getLocalised("ACCOUNT_SERVER_ALREADY_INSTALLED")?><br />
<?php echo $loc->getLocalised("ACCOUNT_ASK_LOGIN")?></p>
<br /><br />
<form action="step3.php?langCode=<?php echo $loc->languageUsed?>" method="post">
<br />
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td align="right"><?php echo $loc->getLocalised("ACCOUNT_LOGIN"); ?></td>
			<td><input name="login"></td>
		</tr>
		<tr>
			<td align="right"><?php echo $loc->getLocalised("ACCOUNT_PASSWORD"); ?></td>
			<td><input name="password" type="password" /></td>
		</tr>
	</table>
<br /><br />
	<input type="submit" class="welcomebtn" value="<?php echo $loc->getLocalised("ACCOUNT_NEXT")?>" />
</form>