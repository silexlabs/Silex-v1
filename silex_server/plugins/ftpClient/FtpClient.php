<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	session_start();
	// pass all $_GET variables to Flash
	$str=''; while( list($k, $v) = each($_GET) ){$str.="fo.addVariable('".$k."', '".$v."');";}
?>
<html style="overflow:auto; height:100%;margin:0px;padding:0px;">
	<head>
		  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
		  <META HTTP-EQUIV="Expires" CONTENT="-1">
		<meta http-equiv="cache-control" content="must-revalidate, pre-check=0, post-check=0, max-age=0" />
		<meta http-equiv="Last-Modified" content="<?php echo gmdate('D, d M Y H:i:s').' GMT'; ?>" />
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>SILEX LIBRARY IMPORT</title>
		<script type="text/javascript" src="swfobject.js"></script>
	</head>
	<body style="overflow:auto; padding:0px;height:100%; margin-top:0; margin-left:0; margin-bottom:0; margin-right:0;">
	<div id="flashcontent" align="center">
	</div>
		<script type="text/javascript">
			var fo = new SWFObject("FtpClient.swf", "FtpClient", "100%", "100%", "8", "#FFFFFF");//"#FF6600");

			// pass all $_GET variables to Flash
			eval("<?php echo $str; ?>");

			fo.addParam("scale", "noscale");
			fo.addParam("swLiveConnect", "true");
			fo.addParam("quality", "best");
			fo.addVariable("session_id", "<?php echo session_id(); ?>");
			fo.write("flashcontent");
		</script>
	</body>
</html>
