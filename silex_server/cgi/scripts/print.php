<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	// Require the htmlText_str parameter
	if ( !isset ( $_POST['htmlText_str']) && !isset ( $_POST['url_str']) )
	{
		?>
<h2>Print 'popup' script for Silex</h2>
<h3>About</h3>
<em>cgi/scripts/print.php</em>

This script let you display HTML formated text in a popup so that the user can print it.
<h3>How to use this script</h3>
In Silex, use the send_text action, which sends a text component’s text to a script (for printing or send by mail).

Parameters
<ul>
	<li>scriptUrl_str
<ul>
	<li>script url, here you want to use cgi/scripts/print.php</li>
</ul>
</li>
	<li>target_str
<ul>
	<li>target window, here you want to use _blank</li>
</ul>
</li>
	<li>isHtml_str
<ul>
	<li>use true if your text is HTML formated and false if you send raw text</li>
</ul>
</li>
	<li>params_str
<ul>
	<li>parameters for the script, here you can use "url_str=URL OF YOUR SILEX PAGE" where "URL OF YOUR SILEX PAGE" is the URL where is your text, url encoded</li>
</ul>
</li>
</ul>
For example
<code>onRelease send_text:cgi/script/print.php,_blank,true,&lt;&lt;a_text_component_ame.htmlText&gt;&gt;,url_str=&lt;&lt;urlencode silex.rootUrl&gt;&gt; </code>

See the <a href="http://community.silexlabs.org/silex/help/?page_id=511" target="_blank">help of the send_text action</a>
		<br /><br /><br/><br/><hr />
		<?php
		die("Help for the <a href='http://community.silexlabs.org/silex/help/?page_id=644'>PHP scripts of Silex</a>");
	}
?>
<html>
<body>
<div align='center'><a href="javascript:self.close();">Fermer</a></div>
<div align='center'><a href="javascript:self.print();">Imprimer</a></div>
<?php
//RECUPERATION des VARIABLES
$htmlText_str=stripslashes(urldecode($_POST['htmlText_str']));

echo $htmlText_str;

if (isset($_POST['url_str'])){
	$url_str=$_POST['url_str'];
	echo "<br><br><br>Source : <a href=".stripslashes($url_str).">".stripslashes($url_str)."</a><br><br>";
}
//echo "GET : ".$_GET['url_str'];
//echo "<br>POST : ".$_POST['url_str'];
//echo "&result=Done&";
?>
</body>
</html>
