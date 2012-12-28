/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.ServerContentExtern;

class ServerContent
{
	private var serverContentExtern : ServerContentExtern;
	
	public function new()
	{
		serverContentExtern = new ServerContentExtern();
	}
	
	/**
	*  Returns a String with all available languages separated by a comma.
	*/
	public function getLanguagesList() : String
	{
		return serverContentExtern.getLanguagesList();
	}
	/**
	*  Returns an array with all the content of the language folder.
	*/
	public function listLanguageFolderContent() : Array<FileSystemItem>
	{
			return FileSystemItem.parseFolderContent(serverContentExtern.listLanguageFolderContent());
	}
	/**
	*  Returns an array with all the content of a website's folder.
	*/
	public function listWebsiteFolderContent(id_site : String) : Array<FileSystemItem>
	{
		return FileSystemItem.parseFolderContent(serverContentExtern.listWebsiteFolderContent(id_site));
	}
	/**
	*  Returns an array with all the content of the tools' folder.
	*/
	public function listToolsFolderContent(path : String) : Array<FileSystemItem>
	{
		return FileSystemItem.parseFolderContent(serverContentExtern.listToolsFolderContent(path));
	}
	/**
	*  Returns an array with all the content of the Media folder.
	*/
	public function listFtpFolderContent(path : String, ?isRecursive : Bool) : Array<FileSystemItem>
	{
		return FileSystemItem.parseFolderContent(serverContentExtern.listFtpFolderContent(path, isRecursive));
	}
	/**
	*  Returns an array with all the content of the specified folder. Either recursive or not.
	*/
	public function listFolderContent(path : String, ?isRecursive : Bool) : Array<FileSystemItem>
	{
		return FileSystemItem.parseFolderContent(serverContentExtern.listFolderContent(path, isRecursive));
	}
}