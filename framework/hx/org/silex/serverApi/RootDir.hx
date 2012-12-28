/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;
import php.Web;

class RootDir
{
	private static function __init__()
	{
		untyped __call__("require_once", "rootdir.php");
		untyped __php__("global $ROOTURL");
		untyped __php__("global $ROOTPATH");
	}
	
	/**
	*  The Root Path of the SILEX Server
	*/
	public static var rootPath(getRootPath, never) : String;
	
	public static var rootUrl(getRootUrl, never) : String;
	
	private static function getRootPath() : String
	{
		untyped __php__("global $ROOTPATH");
		// 2011-06-30 added by Raph: $ROOTPATH variable is set to ROOTPATH constant value
		// otherwise returns null when used by seo plugins & others
		untyped __php__("$ROOTPATH = ROOTPATH");
		return untyped __var__("ROOTPATH");
	}
	
	private static function getRootUrl() : String
	{
		var goodUri = "";
		var tmp = Web.getURI().split("/");
		tmp.pop();
		goodUri = tmp.join("/");

		var portString : String;
		portString = "";
		//We only want to display the port if it != from 80
		if(Std.string(untyped __var__("_SERVER", "SERVER_PORT")) != "80")
			portString = ":" + Std.string(untyped __var__("_SERVER", "SERVER_PORT"));
		return untyped "http://" + __var__("_SERVER", "SERVER_NAME") + portString + goodUri + "/";
	}
}