/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.ServerConfigExtern;

class ServerConfig
{
	private var serverConfigInstance : ServerConfigExtern;
	
	public function new()
	{
		serverConfigInstance = new ServerConfigExtern();
	}
	
	/**
	*  Stores the server's configuration.<br/>
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var silexServerIni(getSilexServerIni, null) : Hash<String>;
	/**
	*  Stores the client's configuration. These properties are sent to the client.<br/>
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var silexClientIni(getSilexClientIni, null) : Hash<String>;
	
	/**
	*  Stores a list of files and folders that can be written by a user with Admin Role.<br/>
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var adminWriteOk(getAdminWriteOk, null) : Array<String>;
	/**
	*  Stores a list of files and folders that can be read by a user with Admin Role.
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var adminReadOk(getAdminReadOk, null) : Array<String>;
	/**
	*  Stores a list of files and folders that can written by a user with User Role.
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var userWriteOk(getUserWriteOk, null) : Array<String>;
	/**
	*  Stores a list of files and folders that can be read by a user User Role.
	*  Changes in it won't be reflected. (Consider it immutable.)
	*/
	public var userReadOk(getUserReadOk, null) : Array<String>;
	
	/**
	*  The character used to replace spaces in URLs.
	*/
	public var sepCharForDeeplinks(getSepCharForDeeplinks, null) : String;
	
	private function getSilexServerIni() : Hash<String>
	{
		return php.Lib.hashOfAssociativeArray(serverConfigInstance.silex_server_ini);
	}
	
	private function getSilexClientIni() : Hash<String>
	{
		return php.Lib.hashOfAssociativeArray(serverConfigInstance.silex_client_ini);
	}
	
	private function getAdminWriteOk() : Array<String>
	{
		return untyped php.Lib.toHaxeArray(serverConfigInstance.admin_write_ok);
	}
	
	private function getAdminReadOk() : Array<String>
	{
		return untyped php.Lib.toHaxeArray(serverConfigInstance.admin_read_ok);
	}
	
	private function getUserWriteOk() : Array<String>
	{
		return untyped php.Lib.toHaxeArray(serverConfigInstance.user_write_ok);
	}
	
	private function getUserReadOk() : Array<String>
	{
		return untyped php.Lib.toHaxeArray(serverConfigInstance.user_read_ok);
	}
	
	private function getSepCharForDeeplinks() : String
	{
		return untyped serverConfigInstance.sepCharForDeeplinks;
	}
	
	/**
	*  Returns the String representing the content folder of the publication which id is given as parameter.<br/>
	*  For example it may return "contents/".<br/>
	*  Values of CONTENTS_THEMES_FOLDER, CONTENTS_UTILITIES_FOLDER and CONTENT_FOLDER are set in
	*  conf/silex_server.ini.
	*/
	public function getContentFolderForPublication(id_publication : String) : String
	{
		return serverConfigInstance.getContentFolderForPublication(id_publication);
	}
}