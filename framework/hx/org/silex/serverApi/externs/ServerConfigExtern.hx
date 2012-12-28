/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

/**
*  This is an extern class binded to server_config.
*/
@:native("server_config") extern class ServerConfigExtern
{
	/**
	*  Used to require_once the file where the implementation lies.
	*/
	public static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/server_config.php");
		null;
	}
	
	/**
	*  A php.NativeArray used to store the server's configuration.<br/>
	*  Used as a HashTable of String's.
	*/
	public var silex_server_ini : php.NativeArray;
	/**
	*  A php.NativeArray used to store the client's configuration. These properties are sent to the client.<br/>
	*  Used as a HashTable of String's.
	*/
	public var silex_client_ini : php.NativeArray;
	
	/**
	*  Stores a list of files and folders that can be written by a user with Admin Role.
	*/
	public var admin_write_ok : php.NativeArray;
	/**
	*  Stores a list of files and folders that can be read by a user with Admin Role.
	*/
	public var admin_read_ok : php.NativeArray;
	/**
	*  Stores a list of files and folders that can written by a user with User Role.
	*/
	public var user_write_ok : php.NativeArray;
	/**
	*  Stores a list of files and folders that can be read by a user User Role.
	*/
	public var user_read_ok : php.NativeArray;
	
	/**
	*  The character used to replace spaces in URLs.
	*/
	public var sepCharForDeeplinks : php.NativeString;
	
	/**
	*  Returns the String representing the content folder of the publication which id is given as parameter.<br/>
	*  For example it may return "contents/".<br/>
	*  Values of CONTENTS_THEMES_FOLDER, CONTENTS_UTILITIES_FOLDER and CONTENT_FOLDER are set in
	*  conf/silex_server.ini.
	*/
	public function getContentFolderForPublication(id_site : String) : String;
	
	public function new() : Void;
}